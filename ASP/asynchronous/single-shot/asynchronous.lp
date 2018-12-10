% - at each time T for a time series P some node N must be visited at a step S

{visit(P,N,S,T) : node(N), step(P,S), time(P,T+K-S), S <= T} = 1 :- time(P,T), max_step(P,K).

% - an atom of the form visited(P,N,S,T) tells that node N at step S for time series P
%   has been visited at some time before T, where T+length(P)-S-1 yields a time for P

visited(P,N,S,T+1) :- visit(P,N,S,T).
visited(P,N,S,T+1) :- visited(P,N,S,T), max_step(P,K), time(P,T+K-S).

% - a node N at step S for time series P must not be visited at multiple times for P

:- visit(P,N,S,T), visited(P,N,S,T).

% - visits of a node N at several steps for a time series P must be in order of steps

:- visit(P,N,S,T), 1 < S, not visited(P,N,S-1,T).

% - redundant constraint asserting that any node-step pair must eventually be visited

:- node(N), step(P,S), max_step(P,K), time(P,T), not time(P,T+1), not visited(P,N,S,T+S+1-K).

% - any node N having itself as a regulator must be visited at the very first time,
%   as the observed value would be inconsistent otherwise

:- time(P,1), has_regulator(N,N), not visit(P,N,1,1).

% - it is impossible to visit a (non-input) node N that cannot have itself as a
%   regulator for two steps at the very beginning, as the observed value would be
%   inconsistent for the second step

:- visit(P,N,2,2), function(N,_), not regulator(N,N,_).

% - it is impossible to visit a node N having some regulator M distinct from itself
%   for two steps at the very beginning, as the observed value would be inconsistent
%   for the second step

:- visit(P,N,2,2), regulator(N,N,_), has_regulator(N,M), M != N.

% - if a node N is visited at a step S for time series P at some time T such that the
%   observed value has to be consistent, then any regulator M distinct from N must
%   have been visited at some time before T at least at step 1

:- visit(P,N,S,T), S < 3, S < T, has_regulator(N,M), M != N, max_step(P,K), time(P,T+2*K-S),
   not visited(P,M,1,T).

% REMARKS
% - the four previous constraints assert that, except for the node visited first,
%   regulators of a (non-input) node must be visited before the node, at least at
%   step 1
% - it remains to check the consistency of observed values

% - if not predefined by a time series P, the observed value of the node visited first
%   as well as visited input nodes N can be chosen in order to evaluate functions at
%   later times T, where an atom of the form curr_vlabel(P,N,T) expresses that the
%   value of N at T for P is 1

{curr_vlabel(P,N,2)} :- time(P,2), visit(P,N,1,1), not obs_vlabel(P,N,_,1).
{curr_vlabel(P,N,T)} :- time(P,T), visit(P,N,S,T-1), not obs_vlabel(P,N,_,S),
                        not function(N,_).

% - if not predefined by a time series P, the observed value of a non-input node N
%   visited at time T-1 for some T > 2 matches the evaluation of the function for N

curr_vlabel(P,N,T)   :- time(P,T), visit(P,N,S,T-1), not obs_vlabel(P,N,_,S),
                        eval_vlabel(P,N,T-1).

% - if the observed value 1 is predefined by a time series P for a node N visited at
%   time T-1, it is indicated by an atom of the form curr_vlabel(P,N,T)

curr_vlabel(P,N,T)   :- time(P,T), visit(P,N,S,T-1), obs_vlabel(P,N,1,S).

% - observed values propagate on to time T for nodes not visited at T-1

curr_vlabel(P,N,T)   :- time(P,T), curr_vlabel(P,N,T-1), not visit(P,N,_,T-1).

% - for nodes N such that the observed value 1 is predefined at each step for a time
%   series P, we statically derive curr_vlabel(P,N,T) for each time T at which some
%   node's function may need to be evaluated

curr_vlabel(P,N,T)   :- time(P,T), 1 < T, node(N), obs_vlabel(P,N,1,S) : step(P,S). % Performance

% - for a (nested) function labeled M associated with a node N whose logical
%   connective is either X=1 for "&" or operator substitution is a possibly applicable
%   repair, an atom of the form none_vlabel(P,N,M,T) indicates that some argument L to
%   M (either a node or a nested subfunction) evaluates to false relative to the
%   observed values for a time series P at time T > 1, so that the conjunction of
%   arguments L to M does not hold

none_vlabel(P,N,M,T) :- operator(N,M,X), argument(N,M,L), has_influence(N,L,0),
                        curr_vlabel(P,L,T), possible(N,M,s) : X = 0.
none_vlabel(P,N,M,T) :- operator(N,M,X), argument(N,M,L), has_influence(N,L,1),
                        time(P,T), 1 < T, not curr_vlabel(P,L,T), possible(N,M,s) : X = 0.
none_vlabel(P,N,M,T) :- operator(N,M,X), argument(N,M,L), operator(N,L,_),
                        time(P,T), 1 < T, not func_vlabel(P,N,L,T), possible(N,M,s) : X = 0.

% - a (nested) function labeled M associated with a node N whose logical connective is
%   X=1 for "&" holds for a time series P at time T > 1 if no argument to M evaluates
%   to false, or some argument L to M must evaluate to true if the logical connective
%   is X=0 for "v", where in each case an atom of the form func_vlabel(P,N,M,T)
%   indicates that M holds

func_vlabel(P,N,M,T) :- has_operator(N,M,1), time(P,T), 1 < T, not none_vlabel(P,N,M,T).
func_vlabel(P,N,M,T) :- has_operator(N,M,0), argument(N,M,L), has_influence(N,L,0),
                        time(P,T), 1 < T, not curr_vlabel(P,L,T).
func_vlabel(P,N,M,T) :- has_operator(N,M,0), argument(N,M,L), has_influence(N,L,1),
                        curr_vlabel(P,L,T).
func_vlabel(P,N,M,T) :- has_operator(N,M,0), argument(N,M,L), func_vlabel(P,N,L,T).

% - the function M associated with a (non-input) node N, where M is either a single
%   regulator or a function label, makes the node evaluate to 1 if the polarity and
%   observed value of the regulator fit or the function evaluates to true for a time
%   series P at time T > 1, where an atom of the form eval_vlabel(P,N,T) indicates
%   that N evaluates to 1

eval_vlabel(P,N,T) :- function(N,M), has_influence(N,M,0),
                      time(P,T), 1 < T, not curr_vlabel(P,M,T).
eval_vlabel(P,N,T) :- function(N,M), has_influence(N,M,1),
                      curr_vlabel(P,M,T).
eval_vlabel(P,N,T) :- function(N,M), func_vlabel(P,N,M,T).

% - whenever a non-input node N whose observed value is predefined for a time series P
%   at step S is visited at some time T > 1, the observed value must match the
%   evaluation of N relative to the observed values for its regulators

:- visit(P,N,S,T), obs_vlabel(P,N,0,S), eval_vlabel(P,N,T).
:- visit(P,N,S,T), obs_vlabel(P,N,1,S), function(N,_), 1 < T, not eval_vlabel(P,N,T).

% - for symmetry breaking regarding the order of node visits, an atom of the form
%   open_input(P,T) indicates that there is some input node N for a time series P at
%   time T > 1 such that N has not been visited at any step before T

open_input(P,T) :- time(P,T), 1 < T, max_step(P,K), time(P,T+2*K-1), node(N), not function(N,_),
                   not visited(P,N,1,T).

% - a yet unvisited input node can always come before the first visit of a non-input
%   node for a time series P at time T > 1

:- open_input(P,T), visit(P,N,1,T), function(N,_).

% - if the same observed value is predefined for a node N by time series P at steps S
%   as well as S+1, and if N is visited at time T > 1, then the observed value is
%   still consistent at time T+1, unless N regulates itself with the polarity 0

:- obs_vlabel(P,N,X,S), obs_vlabel(P,N,X,S+1), max_step(P,K), time(P,T+K+1-S), 1 < T,
   visit(P,N,S,T), not visit(P,N,S+1,T+1), not has_influence(N,N,0).

% - if the same observed value is predefined for an input node N by time series P at
%   steps 1 as well as 2, and if N is visited at time 1, N can be revisited at time 2

:- obs_vlabel(P,N,X,1), obs_vlabel(P,N,X,2), max_step(P,K), time(P,K+1), not function(N,_),
   visit(P,N,1,1), not visit(P,N,2,2).

% REMARKS
% - the conditions specified from the rule for open_input(P,T) on serve symmetry
%   breaking regarding the times at which nodes are visited
% - these conditions are ad hoc and not formally proven, neither regarding soundness
%   nor completeness

% - #show instructions giving applied repairs and visited nodes with observed values

#show curr_vlabel/3.
#show visit/4.
#show obs_vlabel/4.
%#show vlabel(P,N,X,S,T) : visit(P,N,S,T), obs_vlabel(P,N,X,S).
%#show vlabel(P,N,1,S,T) : visit(P,N,S,T), curr_vlabel(P,N,T+1),
 %                         not obs_vlabel(P,N,_,S), T = 1 : function(N,_).
%#show vlabel(P,N,0,S,T) : visit(P,N,S,T), not curr_vlabel(P,N,T+1),
 %                         not obs_vlabel(P,N,_,S), T = 1 : function(N,_).
%#show vlabel(P,N,1,S,T) : visit(P,N,S,T), eval_vlabel(P,N,T),
 %                         not obs_vlabel(P,N,_,S).
%#show vlabel(P,N,0,S,T) : visit(P,N,S,T), function(N,_), 1 < T, not eval_vlabel(P,N,T),
 %                         not obs_vlabel(P,N,_,S).
