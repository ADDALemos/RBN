#include <incmode>.

#program base.

timeStep(T):-obs_vlabel(_,_,_,T).
vertex(V,0):-edge(V,_,0).
vertex(V,0):-edge(_,V,0).
input(P,V) :- exp(P), vertex(V,0), not function(_,V,0),not edge(U,V,0) : edge(U,V,0), U != V.
%goal(V,TI) :- TI=#max{T:obs_vlabel(P,V,_,T)},vertex(V,0),exp(P), not isTemp(V,_).

sign(0;1).
complement(T,S) :- sign(S),sign(T),T!=S.
function(N,V,0) :- functionOr(N,V,0).
function(N,V,0) :- functionAnd(N,V,0).
function(N,V,0) :- functionU(N,V,0).
functionU(N,V,0) :- functionId(N,V,0).
functionU(N,V,0) :- functionNot(N,V,0).
isTemp(temporary(V),0):-vertex(temporary(V),0).
isFunction(W,O):-regulator(N,W),function(N,O,_), not isTemp(O,_).
isFunction(W,O):-regulator(N,W),function(N,V,_),isTemp(V,0), V!=O,isFunction(V,O).
plusinfluence(O,0):- edge(V,O,_), edge(W,O,_), W!=O,W!=V,V!=O.

#program step(t).
1{visit(P,V,TS,t): vertex(V,_),timeStep(TS),exp(P), not isTemp(V,_)}1.
1{vlabel(P,V,1,TS,t);vlabel(P,V,0,TS,t)}1:-visit(P,V,TS,t).
isVisited(P,N,t):-function(N,V,_),exp(P),visit(P,O,_,_),isFunction(V,O).

current_vlabel(P,O,1,t):- isVisited(P,N,_),functionAnd(N,O,_),isTemp(O,_), noneNegative(O,N,P,t), vertex(O,_), exp(P), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t):- isVisited(P,N,_),functionAnd(N,O,_),isTemp(O,_), not noneNegative(O,N,P,t), vertex(O,_), exp(P), timeStep(TI), not repairSign(P,O,_,t).

current_vlabel(P,O,1,t):- isVisited(P,N,_),functionOr(N,O,_),isTemp(O,_),not nonePositive(O,N,P,t), vertex(O,_), exp(P),timeStep(TI), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t):- isVisited(P,N,_),functionOr(N,O,_),isTemp(O,_),nonePositive(O,N,P,t), vertex(O,_), exp(P), not repairSign(P,O,_,t).

current_vlabel(P,O,S,t):- isVisited(P,N,_),functionNot(N,O,_),isTemp(O,_), regulatorSign(P,N,V,T, t), complement(S,T),vertex(O,_), exp(P), not removeRegulator(N,V,_), not repairSign(P,O,_,t).
current_vlabel(P,O,S,t):- isVisited(P,N,_),functionId(N,O,_),isTemp(O,_), regulatorSign(P,N,V,S,t), vertex(O,_), exp(P), not removeRegulator(N,V,_), not repairSign(P,O,_,t).

current_vlabel(P,O,1,t) :- isVisited(P,N,_),not function(_,O,_),isTemp(O,_),vertex(O,_), exp(P), not current_vlabel(P,O,0,t),timeStep(TI), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t) :- isVisited(P,N,_),not function(_,O,_),isTemp(O,_),vertex(O,_), exp(P), not current_vlabel(P,O,1,t),timeStep(TI), not repairSign(P,O,_,t),function(_,F),not consistentFunction(P,F,t).

current_vlabel(P,O,1,t) :- isVisited(P,N,_),vertex(O,_),isTemp(O,_), exp(P), not current_vlabel(P,O,0,t), not repairSign(P,O,_,t).
current_vlabel(P,O,0,t) :- isVisited(P,N,_),vertex(O,_),isTemp(O,_), exp(P), not current_vlabel(P,O,1,t), not repairSign(P,O,_,t),function(_,F),not consistentFunction(P,F,t).
current_vlabel(P,O,S,t):- repairSign(P,O,S,t).
:-vlabel(P,V,S,TS,t),obs_vlabel(P,V,T,TS), complement(S,T).

current_vlabel(P,V,S,t):-T=#max{TS:visit(P,V,TS,_)},vlabel(P,V,S,T,_),not isTemp(V,_).

%current_vlabel(P,V,S,t):-visit(P,V,TS,t),vlabel(P,V,S,TS,_),not isTemp(V,_).

isTemp(temporary(V),t):-vertex(temporary(V),t).
function(N,V,t) :- functionOr(N,V,t).
function(N,V,t) :- functionAnd(N,V,t).
function(N,V,t) :- functionU(N,V,t).
functionU(N,V,t) :- functionId(N,V,t).
functionU(N,V,t) :- functionNot(N,V,t).
%Auxiliar functions
%At least one positive and none negative
noneNegative(V,N,P,t) :- not oneNegative(V,N,P,t), onePositive(V,N,P,t).
%At least one negative and none positive
nonePositive(V,N,P,t) :- oneNegative(V,N,P,t), not onePositive(V,N,P,t).
%Time only matters to none temporary nodes.
oneNegative(V,N,P,t):-oneSign(V,N,P,0,t-1), not isTemp(V,_).
oneNegative(V,N,P,t):-oneSign(V,N,P,0,t), isTemp(V,_).
onePositive(V,N,P,t):-oneSign(V,N,P,1,t-1), not isTemp(V,_).
onePositive(V,N,P,t):-oneSign(V,N,P,1,t), isTemp(V,_).
oneSign(V,N,P,S,t):- function(N,V,_),isRegulator(N,U,t), current_vlabel(P,U,S,t),not repairSign(P,U,_,t).%,query(T),T!=0.
oneSign(V,N,P,S,t):- function(N,V,_),isRegulator(N,U,t), repairSign(P,U,S,t),current_vlabel(P,U,_,t).%,query(T),T!=0.
oneSign(V,N,P,0,t):- function(N,V,_),isRegulator(N,U,t),visit(P,V,_,_),not visit(P,U,_,_),not consistentFunction(P,V,t).
oneSign(V,N,P,1,t):- function(N,V,_),isRegulator(N,U,t),visit(P,V,_,_),not visit(P,U,_,_).

regulatorSign(P,N,V,1,t):- onePositive(V,N,P,t),functionU(N,V,_).
regulatorSign(P,N,V,0,t):- oneNegative(V,N,P,t),functionU(N,V,_).

isRegulator(N,V,t) :- regulator(N,V), not removeRegulator(N,V,_), not negRepair(N,V,_).
negRepair(N,V,t):- repaired(N,V,_), not functionNot(N,_,_).
removeRegulator(N,V,t) :- function(N,U,_), repair(rEdge(V,U),_), not functionNot(N,_,_).
removeRegulator(N,V,t) :- function(N,U,_), removeEdge(V,U,_), not functionNot(N,_,_).
isRegulator(N,temporary(regulator(N,V)),t) :- repaired(N,V,_), not removeRegulator(N,V,_), not functionNot(N,_,_).
isRegulator(temporary(regulator(N,V)),V,t):-repaired(N,V,_), function(temporary(regulator(N,V)),U,_), not removeEdge(V,U,_), not functionNot(N,_,_).

consistentFunction(P,O,t) :- functionAnd(N,O,_), noneNegative(O,N,P,t), current_vlabel(P,O,1,t), not repair(functionOr(N,O,_),_).
consistentFunction(P,O,t) :- functionAnd(N,O,_), not noneNegative(O,N,P,t), current_vlabel(P,O,0,t),not repair(functionOr(N,O,_),_).
consistentFunction(P,O,t) :- repair(functionAnd(N,O),_), noneNegative(O,N,P,t), current_vlabel(P,O,_,t),repairSign(P,O,1,t), not repair(functionOr(N,O,_),_).
consistentFunction(P,O,t) :- repair(functionAnd(N,O),_), not noneNegative(O,N,P,t), current_vlabel(P,O,_,t),repairSign(P,O,0,t),not repair(functionOr(N,O,_),_).

consistentFunction(P,O,t) :- functionOr(N,O,_), not nonePositive(O,N,P,t), current_vlabel(P,O,1,t), not repair(functionAnd(N,O,_),_).
consistentFunction(P,O,t) :- functionOr(N,O,_), nonePositive(O,N,P,t),current_vlabel(P,O,0,t), not repair(functionAnd(N,O,_),_).
consistentFunction(P,O,t) :- repair(functionOr(N,O,_),_), not nonePositive(O,N,P,t), repairSign(P,O,1,t),current_vlabel(P,O,_,t), not repair(functionAnd(N,O,_),_).
consistentFunction(P,O,t) :- repair(functionOr(N,O,_),_), nonePositive(O,N,P,t),current_vlabel(P,O,_,t),repairSign(P,O,0,t), not repair(functionAnd(N,O,_),_).

consistentFunction(P,O,t) :- functionNot(N,O,_),regulatorSign(P,N,O,S,t),current_vlabel(P,O,T,t),complement(S,T), not repair_functionNot(N,O,_).
consistentFunction(P,O,t) :- repair_functionNot(N,O,_),regulatorSign(P,N,O,S,t),current_vlabel(P,O,_,t),repairSign(P,O,S,t).
consistentFunction(P,O,t) :- functionId(N,O,_),regulatorSign(P,N,O,S,t),current_vlabel(P,O,S,t).%, not repair_functionNot(N,O,_).


:-repairSign(P,U,S,t),vlabel(P,U,S,TI,t),obs_vlabel(P,U,T,TI),complement(S,T).
repairSign(P,U,S,t):-repairSign1(P,U,S,t), isTemp(U,_).
repairSign(P,U,S,t):-repairSign1(P,U,S,t), not isTemp(U,_).
repairSign1(P,U,1,t) :- repair(functionOr(N,U,_),_),not nonePositive(U,N,P,t),exp(P), not repair(functionAnd(N,U,_),_) , not repair_functionNot(N,U,_),timeStep(TI).
repairSign1(P,U,0,t) :- repair(functionOr(N,U,_),_), nonePositive(U,N,P,t),exp(P), not repair(functionAnd(N,U,_),_) , not repair_functionNot(N,U,_).
repairSign1(P,U,1,t) :- repair(functionAnd(N,U,_),_), noneNegative(U,N,P,t), exp(P), not repair(functionOr(N,U,_),_) , not repair_functionNot(N,U,_).
repairSign1(P,U,0,t) :- repair(functionAnd(N,U,_),_), not noneNegative(U,N,P,t), exp(P), not repair(functionOr(N,U,_),_) , not repair_functionNot(N,U,_),timeStep(TI).
repairSign1(P,U,S,t) :- repair_functionNot(N,U,_), functionNot(N,U,_),isRegulator(N,V,t),current_vlabel(P,V,S,t-1),exp(P), not repair(functionAnd(N,U,_),_) , not repair(functionOr(N,U,_),_),t-1!=0.


%Possible repairs
pos(functionOr(N,O,0),t) :-   repair_g, not nonePositive(O,N,P,t),not functionOr(N,O,0),functionAnd(N,O,0),exp(P),plusinfluence(O,t),timeStep(TI).
pos(functionOr(N,O,0),t) :-   repair_g, nonePositive(O,N,P,t),not functionOr(N,O,0),functionAnd(N,O,0),plusinfluence(O,t).

pos(functionAnd(N,O,0),t) :-  repair_g, noneNegative(O,N,P,t),not functionAnd(N,O,0),functionOr(N,O,0),plusinfluence(O,t).
pos(functionAnd(N,O,0),t) :-  repair_g, not noneNegative(O,N,P,t),not functionAnd(N,O,0),functionOr(N,O,0),exp(P),plusinfluence(O,t),timeStep(TI).

plusinfluence(O,t):- edge(V,O,_), edge(W,O,_), W!=O,W!=V,V!=O, not repair(rEdge(V,O),_), not repair(rEdge(W,O),_),not removeEdge(V,O,_),not removeEdge(W,O,_).


:-vertex(U,_),plusinfluence(U,0), not plusinfluence(U,t).
pos(rEdge(U,V),t) :- repair_e, regulator(N,U), function(N,V,_), regulator(N,W), not removeEdge(W,V,_),not isTemp(V,_), not isTemp(U,_).
pos(rEdge(U,D),t) :- repair_e, regulator(N,U), regulator(N,W), function(N,V,_),isTemp(V,_),isFunction(V,D), not isTemp(D,_), not isTemp(U,_).
removeEdge(U,W,t):-repair(rEdge(U,D),t),regulator(N,U), function(N,W,_), isTemp(W,_),isFunction(W,D), not isTemp(D,_).
removeEdge(U,D,t):-repair(rEdge(U,D),t),regulator(N,U), function(N,D,_),regulator(N,W), not removeEdge(W,D,_), not isTemp(D,_).
removeEdge(W,D,t):-removeEdge(U,W,_),regulator(N,U),functionU(N,W,_),regulator(M,W),function(M,D,_),D!=U,W!=D,M!=N.

pos(regulator(O,V),t):- repair_i, regulator(N,V), function(N,O,_), not isTemp(O,_), not isTemp(V,_),not removeRegulator(N,V,_).
pos(regulator(O,V),t):- repair_i, regulator(N,V), function(N,W,_), isTemp(W,_),isFunction(W,O), not isTemp(O,_), not isTemp(V,_),not removeRegulator(N,V,_).


repaired(N,V,t):- repair(regulator(O,V),_),regulator(N,V), function(N,W,_), isTemp(W,_),isFunction(W,O), not isTemp(O,_).

%Negate regulators
repaired(N,V,t):-repair(regulator(O,V),_),regulator(N,V),function(N,O,_).
%Check if it is possible to apply it
functionNot(temporary(regulator(N,V)),temporary(regulator(N,V)),t):-repaired(N,V,_), not functionNot(N,_,_).
vertex(temporary(regulator(N,V)),t):-repaired(N,V,_), not functionNot(N,_,_).
edge(temporary(regulator(N,V)),O,t):- repaired(N,V,_),function(N,O,_), not functionNot(N,_,_).
edge(V,temporary(regulator(N,V)),t):- repaired(N,V,_), not functionNot(N,_,_).
repair_functionNot(N,V,t):-functionNot(N,V,_), repaired(N,W,_),regulator(N,W).
{ repair(R,t) : pos(R,t) }.
:-visit(P,V,TS,t),visit(P,V,TS,T),T!=t.
:-visit(P,V,TS,t), not visit(P,V,TS-1,_),timeStep(TS),timeStep(TS-1).
:-not consistentFunction(P,O,t),visit(P,O,_,t), not input(P,O),t!=1.
:-not consistentFunction(P,O,t),vertex(O,T),isTemp(O,_),t!=1,exp(P), not input(P,O),timeStep(t),isVisited(N,O,_),function(N,_,_).
infl(V,t):-visit(P,V,0,t),edge(A,V,_),not isV(P,A,t-1).
:-visit(P,V,TS,t),edge(A,V,_),not isV(P,A,t-1),TS!=0.
max(3).
isV(P,O,t):-visit(P,O,_,_),not isTemp(O,_).
isV(P,O,t):-visit(P,W,_,_),isTemp(O,_),isFunction(O,W).
end(V,t,T):-not visit(P,V,T,_),vertex(V,_),exp(P),timeStep(T),not isTemp(V,_).
svlabel(P,V,S,T,t):-not end(_,t,_),visit(P,V,T,_),vlabel(P,V,S,T,_), not isTemp(V,_).
status(T,TI,t):-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W}.
:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},T>TI,T-TI>M,max(M),timeStep(T),timeStep(TI).
:-visit(P,W,TI,t),T=#max{TS:visit(P,V,TS,_),V!=W},TI>T,TI-T>M,max(M),timeStep(T),timeStep(TI).
#show repair/2.
#show visit/4.
#minimize { 1@1, R,T:repair(R,T) }.
#minimize { 1@2, R,T:infl(R,T) }.
