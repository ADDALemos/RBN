sign(0;1).
complement(T,S) :- sign(S),sign(T),T!=S.
% Make unreached vertices inputs
input(P,V) :- exp(P), vertex(V), not function(_,V),not edge(U,V) : edge(U,V), U != V.
isRepair(U):-vertex(U), not repairable(_), not isTemp(U).
isRepair(U):-repairable(U), not isTemp(U).
timeStep(TI):-obs_vlabel(_,_,_,TI). 
1{vlabel(P,V,1,TI);vlabel(P,V,0,TI)}1:-vertex(V),exp(P),timeStep(TI).
:-vlabel(P,V,S,TI), obs_vlabel(P,V,T,TI),complement(S,T).
a(O):-vlabel(P,O,0,TI),functionAnd(N,O), noneNegative(O,N,P,TI), vertex(O), exp(P), not repair(functionOr(N,O)).
a(O):-vlabel(P,O,1,TI),functionAnd(N,O), oneNegative(O,N,P,TI), vertex(O), exp(P),timeStep(TI), not repair(functionOr(N,O)).
a(O):-vlabel(P,O,0,TI),repair(functionAnd(N,O)), noneNegative(O,N,P,TI), vertex(O), exp(P), not repair(functionOr(N,O)).
a(O):-vlabel(P,O,1,TI),repair(functionAnd(N,O)), oneNegative(O,N,P,TI), vertex(O), exp(P),timeStep(TI), not repair(functionOr(N,O)).
a(O):-vlabel(P,O,1,TI),functionOr(N,O), nonePositive(O,N,P,TI), vertex(O), exp(P), not repair(functionAnd(N,O)).
a(O):-vlabel(P,O,0,TI),functionOr(N,O), onePositive(O,N,P,TI), vertex(O), exp(P),timeStep(TI), not repair(functionAnd(N,O)).
a(O):-vlabel(P,O,1,TI),repair(functionOr(N,O)), nonePositive(O,N,P,TI), vertex(O), exp(P), not repair(functionAnd(N,O)).
a(O):-vlabel(P,O,0,TI),repair(functionOr(N,O)), onePositive(O,N,P,TI), vertex(O), exp(P),timeStep(TI), not repair(functionAnd(N,O)).
a(O):-vlabel(P,O,T,TI),functionId(N,O), not repaired(N,O), regulatorSign(P,N,O,S,TI), vertex(O), exp(P),complement(S,T),not removeRegulator(N,O).
a(O):-vlabel(P,O,T,TI),repair_functionNot(N,O), regulatorSign(P,N,O,S,TI), vertex(O), exp(P),complement(S,T),not removeRegulator(N,O).
:-vertex(V), exp(P), timeStep(T),not vlabel(P,V,_,T).
a(O):-vlabel(P,O,S,TI),functionNot(N,O), regulatorSign(P,N,O,S,TI), not repair_functionNot(N,O),not removeRegulator(N,O).
b(O):-a(O),not isTemp(O).
#show b/1.
%Regulators, check if edge is removed
isRegulator(N,V) :- regulator(N,V), not removeRegulator(N,V), not negReapir(N,V).
negReapir(N,V):- repaired(N,V), not functionNot(N,_).
removeRegulator(N,V) :- function(N,U), repair(rEdge(V,U)).%, not functionNot(N,_).
removeRegulator(N,V) :- function(N,U), removeEdge(V,U).%, not functionNot(N,_).
isRegulator(N,temporary(regulator(N,V))) :- repaired(N,V), not removeRegulator(N,V), not functionNot(N,_).
isRegulator(temporary(regulator(N,V)),V):-repaired(N,V), function(temporary(regulator(N,V)),U), not removeEdge(V,U), not functionNot(N,_).

%Auxiliar functions
%At least one positive and none negative
noneNegative(V,N,P,TI) :- not oneNegative(V,N,P,TI), onePositive(V,N,P,TI).
%At least one negative and none positive
nonePositive(V,N,P,TI) :- oneNegative(V,N,P,TI), not onePositive(V,N,P,TI).
%Time only matters to none temporary nodes.
oneNegative(V,N,P,TI):-function(N,V),isRegulator(N,U), vlabel(P,U,0,TI-1), not isTemp(V),timeStep(TI).
oneNegative(V,N,P,TI):-function(N,V),isRegulator(N,U), vlabel(P,U,0,TI), isTemp(V),timeStep(TI).
onePositive(V,N,P,TI):-function(N,V),isRegulator(N,U), vlabel(P,U,1,TI-1), not isTemp(V),timeStep(TI).
onePositive(V,N,P,TI):-function(N,V),isRegulator(N,U), vlabel(P,U,1,TI), isTemp(V),timeStep(TI).
regulatorSign(P,N,V,1,TI):- onePositive(V,N,P,TI),timeStep(TI),functionU(N,V).
regulatorSign(P,N,V,0,TI):- oneNegative(V,N,P,TI),timeStep(TI),functionU(N,V).
:-vlabel(P,U,S,TI),obs_vlabel(P,U,T,TI),S!=T.

function(N,V) :- functionOr(N,V).
function(N,V) :- functionAnd(N,V).
function(N,V) :- functionU(N,V).
functionU(N,V):- functionNot(N,V).
functionU(N,V):- functionId(N,V).
%Possible repairs
pos(functionOr(N,O)) :-   repair_g, not obs_vlabel(P,O,_,TI),not nonePositive(O,N,P,TI),not functionOr(N,O),functionAnd(N,O),exp(P),plusinfluence(O),timeStep(TI), isRepair(O).
pos(functionOr(N,O)) :-   repair_g, not obs_vlabel(P,O,_,TI),nonePositive(O,N,P,TI),not functionOr(N,O),functionAnd(N,O),plusinfluence(O), isRepair(O).

pos(functionOr(N,O)) :-   repair_g, obs_vlabel(P,O,1,TI),not nonePositive(O,N,P,TI),not functionOr(N,O),functionAnd(N,O),exp(P),plusinfluence(O), isRepair(O).
pos(functionOr(N,O)) :-   repair_g, obs_vlabel(P,O,0,TI),nonePositive(O,N,P,TI),not functionOr(N,O),functionAnd(N,O),plusinfluence(O), isRepair(O).

pos(functionAnd(N,O)) :-  repair_g, not obs_vlabel(P,O,_,TI),noneNegative(O,N,P,TI),not functionAnd(N,O),functionOr(N,O),plusinfluence(O), isRepair(O).
pos(functionAnd(N,O)) :-  timeStep(TI),repair_g, not obs_vlabel(P,O,_,TI),not noneNegative(O,N,P,TI),not functionAnd(N,O),functionOr(N,O),exp(P),plusinfluence(O), isRepair(O).

pos(functionAnd(N,O)) :-  repair_g, obs_vlabel(P,O,1,TI),noneNegative(O,N,P,TI),not functionAnd(N,O),functionOr(N,O),plusinfluence(O), isRepair(O).
pos(functionAnd(N,O)) :-  repair_g, obs_vlabel(P,O,0,TI),not noneNegative(O,N,P,TI),not functionAnd(N,O),functionOr(N,O),exp(P),plusinfluence(O), isRepair(O).

plusinfluence(O):- edge(V,O), edge(W,O), W!=O,W!=V,V!=O, not repair(rEdge(V,O)), not repair(rEdge(W,O)),not removeEdge(V,O),not removeEdge(W,O).


pos(rEdge(U,V)) :- repair_e, regulator(N,U), function(N,V), regulator(N,W), not removeEdge(W,V),not isTemp(V), not isTemp(U), isRepair(V).
pos(rEdge(U,D)) :- repair_e, regulator(N,U), regulator(N,W), function(N,V),isTemp(V),isFunction(V,D), not isTemp(D), not isTemp(U), isRepair(D).
removeEdge(U,W):-repair(rEdge(U,D)),regulator(N,U), function(N,W), isTemp(W),isFunction(W,D), not isTemp(D).
removeEdge(U,D):-repair(rEdge(U,D)),regulator(N,U), function(N,D),regulator(N,W), not removeEdge(W,D), not isTemp(D).
removeEdge(W,D):-removeEdge(U,W),regulator(N,U),functionU(N,W),regulator(M,W),function(M,D),D!=U,W!=D,M!=N.

pos(regulator(O,V)):- repair_i, regulator(N,V), function(N,O), not isTemp(O), not isTemp(V),not removeRegulator(N,V), isRepair(O).
pos(regulator(O,V)):- repair_i, regulator(N,V), function(N,W), isTemp(W),isFunction(W,O), not isTemp(O), not isTemp(V),not removeRegulator(N,V), isRepair(O).
isFunction(W,O):-regulator(N,W),function(N,O), not isTemp(O).
isFunction(W,O):-regulator(N,W),function(N,V),isTemp(V), V!=O,isFunction(V,O).


repaired(N,V):- repair(regulator(O,V)),regulator(N,V), function(N,W), isTemp(W),isFunction(W,O), not isTemp(O).

%Negate regulators
repaired(N,V):-repair(regulator(O,V)),regulator(N,V),function(N,O).

%Check if it is possible to apply it
functionNot(temporary(regulator(N,V)),temporary(regulator(N,V))):-repaired(N,V), not functionNot(N,_).
vertex(temporary(regulator(N,V))):-repaired(N,V), not functionNot(N,_).
edge(temporary(regulator(N,V)),O):- repaired(N,V),function(N,O), not functionNot(N,_).
edge(V,temporary(regulator(N,V))):- repaired(N,V), not functionNot(N,_).
repair_functionNot(N,V):-functionNot(N,V), repaired(N,W),regulator(N,W).

{ repair(R) : pos(R) }.
%#show repair/1.
vertex(V):-edge(V,_).
vertex(V):-edge(_,V).
isTemp(temporary(V)):-vertex(temporary(V)).
#minimize { 1, R:repair(R) }.
