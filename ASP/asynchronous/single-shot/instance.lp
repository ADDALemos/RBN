% EXAMPLE CALL
% $ clingo instance.lp repair.lp asynchronous.lp --opt-mode=optN --quiet=1,0
% Answer: 1
% repair(b,cd,s) \
% vlabel(ts1,b,0,1,1) vlabel(ts1,d,1,1,2)  vlabel(ts1,d,1,2,3)  vlabel(ts1,d,1,3,4) \
% vlabel(ts1,a,0,1,5) vlabel(ts1,c,0,1,6)  vlabel(ts1,c,0,2,7)  vlabel(ts1,b,1,2,8) \
% vlabel(ts1,b,1,3,9) vlabel(ts1,a,1,2,10) vlabel(ts1,a,1,3,11) vlabel(ts1,c,1,3,12)

node(a). regulator(a,b,1).                   function(a,b).  % K(a) = b
node(b). regulator(b,c,1). regulator(b,d,1). function(b,cd). % K(b) = c & d
node(c). regulator(c,a,1).                   function(c,a).  % K(c) = a
node(d).                                                     % input
operator(b,cd,1). argument(b,cd,c). argument(b,cd,d).        % representation of "c & d"
%why b in there argument
% ALTERNATIVE EXAMPLE: K(b) = neg(c) v d
%*
node(b). regulator(b,c,0). regulator(b,d,1). function(b,cd).
operator(b,cd,0). argument(b,cd,c). argument(b,cd,d).
*%

% ANOTHER EXAMPLE: K(b) = a & (neg(c) v d)
%*
node(b). regulator(b,a,1). regulator(b,c,0). regulator(b,d,1). function(b,acd).
operator(b,acd,1). argument(b,acd,a). argument(b,acd,cd).
operator(b,cd,0).  argument(b,cd,c).  argument(b,cd,d).%How to neg a function ? Why b in operator?
*%

% REMARKS
% - a regulator M of a node N is associated with a "polarity" X=0 or X=1 in regulator(N,M,X)
% - each non-input node N is associated with a single regulator or a function label M
%   in function(N,M), where node names and function labels are assumed to be disjoint
% - an input node N has no fact of the form function(N,M) (and neither regulator(N,M,X))
% - the logical connective for a function label M associated with a node N is either
%   X=0 for "v" or X=1 for "&" in operator(N,M,X)
% - the nodes or (nested) function labels L contributing to a function labeled M for node N
%   are specified by facts of the form argument(N,M,L), where the "polarity" is determined
%   by regulator(N,L,X) in case L is a node, or otherwise the function labeled L for node N
%   is described by facts of the form operator(N,L,X) and argument(N,L,L')

experiment(ts1). % label identifying a time series
obs_vlabel(ts1,a,0,1). obs_vlabel(ts1,a,1,2). obs_vlabel(ts1,a,1,3). % observations for
obs_vlabel(ts1,b,0,1). obs_vlabel(ts1,b,1,2). obs_vlabel(ts1,b,1,3). % three time points
obs_vlabel(ts1,c,0,1). obs_vlabel(ts1,c,0,2). obs_vlabel(ts1,c,1,3). % (missing values
obs_vlabel(ts1,d,1,1). obs_vlabel(ts1,d,1,2). obs_vlabel(ts1,d,1,3). %  would be ok too)

repair_s. % repairs of type 's' (operator substitution) are applicable
