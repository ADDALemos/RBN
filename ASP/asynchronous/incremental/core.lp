#include <incmode>.

#program base.

can_repair(U):-node(U), not repairable(_).
can_repair(U):-repairable(U).
timeStep(T):-obs_vlabel(_,_,_,T).

input(V) :- node(V), not function(V).


function(V) :- functionOr(V).
function(V) :- functionAnd(V).
function(V) :- functionId(V).
function(V) :- functionNot(V).


#program step(t).
1{visit(P,V,TS,t): node(V),timeStep(TS),exp(P)}1.


current_vlabel(P,O,t):- visit(P,O,_,t),functionAnd(O), noneNegative(P,O,t-1), not repair(functionAnd(O),_), t>1.

current_vlabel(P,O,t):- visit(P,O,_,t),functionOr(O),not nonePositive(P,O,t-1), t>1, not repair(functionOr(O),_).

current_vlabel(P,O,t):- visit(P,O,_,t),functionId(O),oneSign(P,V,1,t-1), t>1.

current_vlabel(P,O,t):- visit(P,O,_,t), t>1,input(O), current_vlabel(P,O,t-1).

current_vlabel(P,O,t):- not visit(P,O,_,t), current_vlabel(P,O,t-1), t>1.

{current_vlabel(P,O,1)}:- visit(P,O,_,t),t=1.

current_vlabel(P,O,t):- not node(O),functionAnd(O), noneNegative(P,O,t),not repair(functionAnd(O),_).
current_vlabel(P,O,t):- not node(O), exp(P),functionOr(O),not nonePositive(P,O,t),not repair(functionOr(O),_).
current_vlabel(P,O,t):- not node(O),functionId(O), oneSign(P,O,1,t), exp(P).

:-visit(P,O,TS,t),current_vlabel(P,O,t),obs_vlabel(P,V,0,TS), node(O).
:-visit(P,O,TS,t),not current_vlabel(P,O,t),obs_vlabel(P,V,1,TS), node(O).


%Auxiliar functions
%At least one positive and none negative
noneNegative(P,V,t) :- not oneNegative(P,V,t), onePositive(P,V,t).
%At least one negative and none positive
nonePositive(P,V,t) :- oneNegative(P,V,t), not onePositive(P,V,t).

oneNegative(P,V,t):-oneSign(P,V,0,t).
onePositive(P,V,t):-oneSign(P,V,1,t).
oneSign(P,V,1,t):- function(V),has_influence(V,U,1,_), current_vlabel(P,U,t).
oneSign(P,V,1,t):- exp(P),function(V),has_influence(V,U,0,_), not current_vlabel(P,U,t).
oneSign(P,V,0,t):- exp(P),function(V),has_influence(V,U,1,_), not current_vlabel(P,U,t).
oneSign(P,V,0,t):- function(V),has_influence(V,U,0,_), current_vlabel(P,U,t).

:-node(U),not has_regulator(U,_,t), not input(U).


has_regulator(N,M,t)     :- regulator(N,M,_), not repair(removeRegulator(N,M),t).
has_influence(N,M,1-X,t) :- regulator(N,M,X), has_regulator(N,M,_), repair(negRegulator(N,M),t).
has_influence(N,M,X,t)   :- regulator(N,M,X), has_regulator(N,M,_), not repair(negRegulator(N,M),t).


pos(functionAnd(N),t) :- repair_s, can_repair(N), functionAnd(N).
pos(functionOr(N),t) :- repair_s, can_repair(N), functionOr(N).
pos(negRegulator(N,M),t) :- repair_n, can_repair(N), regulator(N,M,_).
pos(removeRegulator(N,M),t) :- repair_r, can_repair(N), regulator(N,M,_), regulator(N,L,_), M != L.


{ repair(R,t) : pos(R,t) }.


:-visit(P,V,TS,t),visit(P,V,TS,T),T!=t.

%Visit the node in time step TS-1 before visiting in time step TS
:-visit(P,V,TS,t), not visit(P,V,TS-1,_),timeStep(TS),timeStep(TS-1).

%Ensure we visit the regulators before hand
:-visit(P,V,_,t),has_regulator(V,A,_),not visit(P,A,_,_).

:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},TI>T,TI-T>M,max(M),timeStep(T),timeStep(TI).
:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},T>TI,T-TI>M,max(M),timeStep(T),timeStep(TI).

max(3).


%#show current_vlabel/3.
%#show visit/4.

#minimize { 1@1, R,T:repair(R,T) }.


#program check(t).
:-query(t),t!=9.%timeStep(S), not visit(_,W,S,_),node(W).
