% - repairable (non-input) nodes N are indicated by atoms of the form can_repair(N)
% - the applicability of a repair of type 's' (operator substitution) to a function
%   labeled M for node N is expressed by an atom of the form possible(N,M,s); as
%   suggested by the example for operator substitution in Figure 2(D), nested
%   subfunctions, if any, are considered too, while the literal "not isTemp(N,0)" in
%   rules of Listing 5 has apparently the purpose of excluding operator substitution
% - the applicability of a repair of type 'n' (regulator negation) to a regulator M
%   of node N is expressed by an atom of the form possible(N,M,n)
% - the applicability of a repair of type 'r' (regulator removal) to a regulator M
%   of node N is expressed by an atom of the form possible(N,M,r)

can_repair(N)   :- function(N,_), repairable(N).
can_repair(N)   :- function(N,_), not repairable(_).
possible(N,M,s) :- repair_s, can_repair(N), operator(N,M,_). % , function(N,M). % Add to body?
possible(N,M,n) :- repair_n, can_repair(N), regulator(N,M,_).
possible(N,M,r) :- repair_r, can_repair(N), regulator(N,M,_), regulator(N,L,_), M != L.

% - atoms of the form repair(N,M,R) represent the applied repairs

{repair(N,M,R)} :- possible(N,M,R).

% - it is not allowed to remove all regulators of a (non-input) node N

:- can_repair(N), repair(N,M,r) : regulator(N,M,_).

% - the cardinality of the applied repairs shall be minimized

#minimize{1,N,M,R : repair(N,M,R)}.

% - an atom of the form has_regulator(N,M) expresses that a regulator M of node N is
%   not removed by any applied repair
% - an atom of the form has_influence(N,M,X) reflects the "polarity" X=0 or X=1
%   associated with a regulator M of node N that is not removed by any applied repair
% - an atom of the form has_operator(N,M,X) indicates the connective X=0 for "v" or
%   X=1 for "&" associated with a function labeled M defining the value of node N

has_regulator(N,M)     :- regulator(N,M,_), not repair(N,M,r).
has_influence(N,M,1-X) :- regulator(N,M,X), has_regulator(N,M), repair(N,M,n).
has_influence(N,M,X)   :- regulator(N,M,X), has_regulator(N,M), not repair(N,M,n).
has_operator(N,M,1-X)  :- operator(N,M,X), repair(N,M,s).
has_operator(N,M,X)    :- operator(N,M,X), not repair(N,M,s).

% - the times for asynchronous dynamics are indicated by atoms of the form time(P,T),
%   where P identifies a time series and T ranges from 1 to #nodes*length(P)

nodes(C)      :- C = #count{N : node(N)}. % é dispendioso 
step(P,S)     :- obs_vlabel(P,_,_,S).
max_step(P,S) :- step(P,S), not step(P,S+1).
time(P,S*C-I) :- step(P,S), nodes(C), I = 0..C-1.
