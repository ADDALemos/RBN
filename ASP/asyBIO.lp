#include <incmode>.

#program base.
isRepair(U):-vertex(U), not repairable(_), not isTemp(U,_).
isRepair(U):-repairable(U), not isTemp(U,_).
timeStep(T):-obs_vlabel(_,_,_,T).
vertex(V,0):-edge(V,_,0).
vertex(V,0):-edge(_,V,0).
input(P,V) :- exp(P), vertex(V,0), not function(_,V,0),not edge(U,V,0) : edge(U,V,0), U != V.
%goal(V,TI) :- TI=#max{T:obs_vlabel(P,V,_,T)},vertex(V,0),exp(P), not isTemp(V,_).

sign(0;1).
complement(T,S) :- sign(S),sign(T),T!=S.
function(V,0) :- functionOr(V,0).
function(V,0) :- functionAnd(V,0).
function(V,0) :- functionU(V,0).
functionU(V,0) :- functionId(V,0).
functionU(V,0) :- functionNot(V,0).
isTemp(temporary(V),0):-vertex(temporary(V),0).
isFunction(W,O):-regulator(O,W),function(O,_), not isTemp(O,_).
isFunction(W,O):-regulator(V,W),function(V,_),isTemp(V,0), V!=O,isFunction(V,O).
plusinfluence(O,0):- edge(V,O,_), edge(W,O,_), W!=O,W!=V,V!=O.

#program step(t).
1{visit(P,V,TS,t): vertex(V,_),timeStep(TS),exp(P), not isTemp(V,_)}1.
1{vlabel(P,V,1,TS,t);vlabel(P,V,0,TS,t)}1:-visit(P,V,TS,t).
isVisited(P,V,t):-function(V,_),exp(P),visit(P,O,_,_),isFunction(V,O).

current_vlabel(P,O,1,t):- isVisited(P,O,_),functionAnd(O,_),isTemp(O,_), noneNegative(O,P,t), vertex(O,_), exp(P), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t):- isVisited(P,O,_),functionAnd(O,_),isTemp(O,_), not noneNegative(O,P,t), vertex(O,_), exp(P), timeStep(TI), not repairSign(P,O,_,t).

current_vlabel(P,O,1,t):- isVisited(P,O,_),functionOr(O,_),isTemp(O,_),not nonePositive(O,P,t), vertex(O,_), exp(P),timeStep(TI), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t):- isVisited(P,O,_),functionOr(O,_),isTemp(O,_),nonePositive(O,P,t), vertex(O,_), exp(P), not repairSign(P,O,_,t).

current_vlabel(P,O,S,t):- isVisited(P,O,_),functionNot(O,_),isTemp(O,_), regulatorSign(P,V,T, t), complement(S,T),vertex(O,_), exp(P), not removeRegulator(O,V,_), not repairSign(P,O,_,t).
current_vlabel(P,O,S,t):- isVisited(P,O,_),functionId(O,_),isTemp(O,_), regulatorSign(P,V,S,t), vertex(O,_), exp(P), not removeRegulator(O,V,_), not repairSign(P,O,_,t).

current_vlabel(P,O,1,t) :- isVisited(P,O,_),not function(_,O,_),isTemp(O,_),vertex(O,_), exp(P), not current_vlabel(P,O,0,t),timeStep(TI), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t) :- isVisited(P,O,_),not function(_,O,_),isTemp(O,_),vertex(O,_), exp(P), not current_vlabel(P,O,1,t),timeStep(TI), not repairSign(P,O,_,t),function(_,F),not consistentFunction(P,F,t).

current_vlabel(P,O,1,t) :- isVisited(P,N,_),vertex(O,_),isTemp(O,_), exp(P), not current_vlabel(P,O,0,t), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t) :- isVisited(P,N,_),vertex(O,_),isTemp(O,_), exp(P), not current_vlabel(P,O,1,t), not repairSign(P,O,_,t),function(F,_),not consistentFunction(P,F,t).
current_vlabel(P,O,S,t):- repairSign(P,O,S,t).
:-vlabel(P,V,S,TS,t),obs_vlabel(P,V,T,TS), complement(S,T).

current_vlabel(P,V,S,t):-T=#max{TS:visit(P,V,TS,_)},vlabel(P,V,S,T,_),not isTemp(V,_).

%current_vlabel(P,V,S,t):-visit(P,V,TS,t),vlabel(P,V,S,TS,_),not isTemp(V,_).



isTemp(temporary(V),t):-vertex(temporary(V),t).
function(V,t) :- functionOr(V,t).
function(V,t) :- functionAnd(V,t).
function(V,t) :- functionU(V,t).
functionU(V,t) :- functionId(V,t).
functionU(V,t) :- functionNot(V,t).
%Auxiliar functions
%At least one positive and none negative
noneNegative(V,P,t) :- not oneNegative(V,P,t), onePositive(V,P,t).
%At least one negative and none positive
nonePositive(V,P,t) :- oneNegative(V,P,t), not onePositive(V,P,t).
%Time only matters to none temporary nodes.
oneNegative(V,P,t):-oneSign(V,P,0,t-1), not isTemp(V,_).
oneNegative(V,P,t):-oneSign(V,P,0,t), isTemp(V,_).
onePositive(V,P,t):-oneSign(V,P,1,t-1), not isTemp(V,_).
onePositive(V,P,t):-oneSign(V,P,1,t), isTemp(V,_).
oneSign(V,P,S,t):- function(V,_),isRegulator(V,U,t), current_vlabel(P,U,S,t),not repairSign(P,U,_,t).%,query(T),T!=0.
oneSign(V,P,S,t):- function(V,_),isRegulator(V,U,t), repairSign(P,U,S,t),current_vlabel(P,U,_,t).%,query(T),T!=0.
oneSign(V,P,0,t):- function(V,_),isRegulator(V,U,t),visit(P,V,_,_),not visit(P,U,_,_),not consistentFunction(P,V,t).
oneSign(V,P,1,t):- function(V,_),isRegulator(V,U,t),visit(P,V,_,_),not visit(P,U,_,_).

regulatorSign(P,V,1,t):- onePositive(V,P,t),functionU(V,_).
regulatorSign(P,V,0,t):- oneNegative(V,P,t),functionU(V,_).

isRegulator(U,V,t) :- regulator(U,V), not removeRegulator(U,V,_), not negRepair(U,V,_).
negRepair(N,V,t):- repaired(N,V,_), not functionNot(N,_).
removeRegulator(N,V,t) :- function(N,_), repair(rEdge(V,N),_), not functionNot(N,_).
removeRegulator(N,V,t) :- function(N,_), removeEdge(V,N,_), not functionNot(N,_).
isRegulator(N,temporary(regulator(N,V)),t) :- repaired(N,V,_), not removeRegulator(N,V,_), not functionNot(N,_).
isRegulator(temporary(regulator(N,V)),V,t):-repaired(N,V,_), function(N,_), not removeEdge(V,N,_), not functionNot(N,_).

consistentFunction(P,O,t) :- functionAnd(O,_), noneNegative(O,P,t), current_vlabel(P,O,1,t), not repair(functionOr(O,_),_).
consistentFunction(P,O,t) :- functionAnd(O,_), not noneNegative(O,P,t), current_vlabel(P,O,0,t),not repair(functionOr(O,_),_).
consistentFunction(P,O,t) :- repair(functionAnd(O),_), noneNegative(O,P,t), current_vlabel(P,O,_,t),repairSign(P,O,1,t), not repair(functionOr(O,_),_).
consistentFunction(P,O,t) :- repair(functionAnd(O),_), not noneNegative(O,P,t), current_vlabel(P,O,_,t),repairSign(P,O,0,t),not repair(functionOr(O,_),_).

consistentFunction(P,O,t) :- functionOr(O,_), not nonePositive(O,P,t), current_vlabel(P,O,1,t), not repair(functionAnd(O,_),_).
consistentFunction(P,O,t) :- functionOr(O,_), nonePositive(O,P,t),current_vlabel(P,O,0,t), not repair(functionAnd(O,_),_).
consistentFunction(P,O,t) :- repair(functionOr(O,_),_), not nonePositive(O,P,t), repairSign(P,O,1,t),current_vlabel(P,O,_,t), not repair(functionAnd(O,_),_).
consistentFunction(P,O,t) :- repair(functionOr(O,_),_), nonePositive(O,P,t),current_vlabel(P,O,_,t),repairSign(P,O,0,t), not repair(functionAnd(O,_),_).

consistentFunction(P,O,t) :- functionNot(O,_),regulatorSign(P,O,S,t),current_vlabel(P,O,T,t),complement(S,T), not repair_functionNot(O,_).
consistentFunction(P,O,t) :- repair_functionNot(O,_),regulatorSign(P,O,S,t),current_vlabel(P,O,_,t),repairSign(P,O,S,t).
consistentFunction(P,O,t) :- functionId(O,_),regulatorSign(P,O,S,t),current_vlabel(P,O,S,t).%, not repair_functionNot(O,_).


:-repairSign(P,U,S,t),vlabel(P,U,S,TI,t),obs_vlabel(P,U,T,TI),complement(S,T).
repairSign(P,U,S,t):-repairSign1(P,U,S,t), isTemp(U,_).
repairSign(P,U,S,t):-repairSign1(P,U,S,t), not isTemp(U,_).
repairSign1(P,U,1,t) :- repair(functionOr(U,_),_),not nonePositive(U,P,t),exp(P), not repair(functionAnd(U,_),_) , not repair_functionNot(U,_),timeStep(TI).
repairSign1(P,U,0,t) :- repair(functionOr(U,_),_), nonePositive(U,P,t),exp(P), not repair(functionAnd(U,_),_) , not repair_functionNot(U,_).
repairSign1(P,U,1,t) :- repair(functionAnd(U,_),_), noneNegative(U,P,t), exp(P), not repair(functionOr(U,_),_) , not repair_functionNot(U,_).
repairSign1(P,U,0,t) :- repair(functionAnd(U,_),_), not noneNegative(U,P,t), exp(P), not repair(functionOr(U,_),_) , not repair_functionNot(U,_),timeStep(TI).
repairSign1(P,U,S,t) :- repair_functionNot(U,_), functionNot(U,_),isRegulator(V,t),current_vlabel(P,V,S,t-1),exp(P), not repair(functionAnd(U,_),_) , not repair(functionOr(U,_),_),t-1!=0.


%Possible repairs
pos(functionOr(O,0),t) :-   repair_g, not nonePositive(O,P,t),not functionOr(O,0),functionAnd(O,0),exp(P),plusinfluence(O,t),timeStep(TI),isRepair(O).
pos(functionOr(O,0),t) :-   repair_g, nonePositive(O,P,t),not functionOr(O,0),functionAnd(O,0),plusinfluence(O,t),isRepair(O).

pos(functionAnd(O,0),t) :-  repair_g, noneNegative(O,P,t),not functionAnd(O,0),functionOr(O,0),plusinfluence(O,t),isRepair(O).
pos(functionAnd(O,0),t) :-  repair_g, not noneNegative(O,P,t),not functionAnd(O,0),functionOr(O,0),exp(P),plusinfluence(O,t),timeStep(TI),isRepair(O).

plusinfluence(O,t):- edge(V,O,_), edge(W,O,_), W!=O,W!=V,V!=O, not repair(rEdge(V,O),_), not repair(rEdge(W,O),_),not removeEdge(V,O,_),not removeEdge(W,O,_).


:-vertex(U,_),plusinfluence(U,0), not plusinfluence(U,t).
pos(rEdge(U,V),t) :- repair_e, regulator(V,U), function(V,_), regulator(W), not removeEdge(W,V,_),not isTemp(V,_), not isTemp(U,_),isRepair(V).
pos(rEdge(U,D),t) :- repair_e, regulator(V,U), regulator(V,W), function(V,_),isTemp(V,_),isFunction(V,D), not isTemp(D,_), not isTemp(U,_),isRepair(D).
removeEdge(U,W,t):-repair(rEdge(U,D),t),regulator(W,U), function(W,_), isTemp(W,_),isFunction(W,D), not isTemp(D,_).
removeEdge(U,D,t):-repair(rEdge(U,D),t),regulator(D,U), function(D,_),regulator(W), not removeEdge(W,D,_), not isTemp(D,_).
removeEdge(W,D,t):-removeEdge(U,W,_),regulator(W,U),functionU(W,_),regulator(D,W),function(D,_),D!=U,W!=D.

pos(regulator(O,V),t):- repair_i, regulator(O,V), function(O,_), not isTemp(O,_), not isTemp(V,_),not removeRegulator(O,V,_),isRepair(O).
pos(regulator(O,V),t):- repair_i, regulator(W,V), function(W,_), isTemp(W,_),isFunction(W,O), not isTemp(O,_), not isTemp(V,_),not removeRegulator(W,V,_),isRepair(O).


repaired(W,V,t):- repair(regulator(O,V),_),regulator(W,V), function(W,_), isTemp(W,_),isFunction(W,O), not isTemp(O,_).

%Negate regulators
repaired(O,V,t):-repair(regulator(O,V),_),regulator(O,V),function(O,_).
%Check if it is possible to apply it
functionNot(temporary(regulator(N,V)),t):-repaired(N,V,_), not functionNot(N,_).
vertex(temporary(regulator(N,V)),t):-repaired(N,V,_), not functionNot(N,_).
edge(temporary(regulator(O,V)),O,t):- repaired(O,V,_),function(O,_), not functionNot(O,_).
edge(V,temporary(regulator(N,V)),t):- repaired(N,V,_), not functionNot(N,_).
repair_functionNot(V,t):-functionNot(V,_), repaired(V,W,_),regulator(V,W).
{ repair(R,t) : pos(R,t) }.
:-visit(P,V,TS,t),visit(P,V,TS,T),T!=t.
:-visit(P,V,TS,t), not visit(P,V,TS-1,_),timeStep(TS),timeStep(TS-1).
:-not consistentFunction(P,O,t),visit(P,O,_,t), not input(P,O),t!=1.
:-not consistentFunction(P,O,t),vertex(O,_),isTemp(O,_),t!=1,exp(P), not input(P,O),isVisited(P,O,_).
%infl(V,t):-visit(P,V,0,t),edge(A,V,_),not isV(P,A,t-1).
:-visit(P,V,TS,t),edge(A,V,_),not isV(P,A,t-1),TS!=0.
max(3).
isV(P,O,t):-visit(P,O,_,_),not isTemp(O,_).
isV(P,O,t):-visit(P,W,_,_),isTemp(O,_),isFunction(O,W).
end(V,t,T):-not visit(P,V,T,_),vertex(V,_),exp(P),timeStep(T),not isTemp(V,_).
%Debug
%svlabel(P,V,S,T,t):-not end(_,t,_),visit(P,V,T,_),vlabel(P,V,S,T,_), not isTemp(V,_).
%status(T,TI,t):-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W}.
%:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},T>TI,T-TI>M,max(M),timeStep(T),timeStep(TI).
%:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},TI>T,TI-T>M,max(M),timeStep(T),timeStep(TI).
#show repair/2.
#show visit/4.
#minimize { 1@1, R,T:repair(R,T) }.
%Dectetion cycle
%#minimize { 1@2, R,T:infl(R,T) }.
