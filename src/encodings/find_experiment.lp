
% possible experiments
cexperiment(1..X) :- pexperiment(X).
%:- cexperiment(X), pexperiment(X-1), not cexperiment(X-1).
%cexperiment(X-1) :- cexperiment(X), pexperiment(X-1).

%maximal 4 experiments
%expmax(10).
%:- cexperiment(X), expmax(M), X>M.


% check if a pert has influence on a readout in a network
hasinfl(X) :- preadout(R), obs_elabel(N,X,R,S).
hasinfl(X) :- hasinfl(R), obs_elabel(N,X,R,S).


% choose experimental pertubations, filter those which have no influence on a readout
{pert(E,G,S)} :- hasinfl(G), pperturb(G,S), cexperiment(E). 
pert(E,G) :- pert(E,G,S).

% no two pertubations in the same node
:- pert(E,G,S1),pert(E,G,S2),S1!=S2.

% choose experimental readouts (take all)
readout(E,G) :- preadout(G), cexperiment(E). 
%{readout(E,G)} :- preadout(G), cexperiment(E). 



npert(E,G,S) :- pperturb(G,S), cexperiment(E), not pert(E,G,S).

% not two times the same experiment
%allpert(E2,E1) :- pert(E2,G,S) : pert(E1,G,S); cexperiment(E1), cexperiment(E2), E1 < E2.
%allnpert(E2,E1) :- npert(E2,G,S) : npert(E1,G,S); cexperiment(E1), cexperiment(E2), E1 < E2.
%:- allpert(E1,E2), allnpert(E1,E2), E1 < E2.

% force an partial order among the experiments, the first experiment has the least pertubations
countpert(E,Z) :- Z = #count{ pert(E,G)}, cexperiment(E).
:- countpert(E1,Z1), countpert(E1+1,Z2), Z1>Z2.


% force total order biggest different pertubation last
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), pert(E1,G,S),  npert(E1+1,G,S).
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), npert(E1,G,S), pert(E1+1,G,S).
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G<G2.
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G==G2, S<S2.
biggestdiffpert(G,S,E1,E2) :- diffpert(G,S,E1,E2) , not hasbiggerdiffpert(G,S,E1,E2).
:- exp(E1),exp(E2), E1<E2, biggestdiffpert(G,S,E1,E2), pert(E1,G,S), npert(E2,G,S).


% choose labeling
1{vlabel(E,NET,G,-1), vlabel(E,NET,G,0), vlabel(E,NET,G,1), vlabel(E,NET,G,am)}1 :- vertex(NET,G), cexperiment(E).

vlabel(E,N,G,1) :- vertex(N,G), pert(E,G,1).
vlabel(E,N,G,-1):- vertex(N,G), pert(E,G,-1).
vlabel(E,N,G,0) :- vertex(N,G), pert(E,G,0).


infl(E,N,G,1)  :- obs_elabel(N,A,G,1),  vlabel(E,N,A,1).
infl(E,N,G,1)  :- obs_elabel(N,A,G,-1), vlabel(E,N,A,-1).
infl(E,N,G,1)  :- edge(N,A,G), vlabel(E,N,A,am).

infl(E,N,G,-1) :- obs_elabel(N,A,G,-1), vlabel(E,N,A,1).
infl(E,N,G,-1) :- obs_elabel(N,A,G,1),  vlabel(E,N,A,-1).
infl(E,N,G,-1) :- edge(N,A,G), vlabel(E,N,A,am).

:- vlabel(E,N,G,0),     not pert(E,G), infl(E,N,G,S).
:- vlabel(E,N,G,1),     not pert(E,G), not infl(E,N,G,1).
:- vlabel(E,N,G,1),     not pert(E,G), infl(E,N,G,-1).
:- vlabel(E,N,G,-1),    not pert(E,G), not infl(E,N,G,-1).
:- vlabel(E,N,G,-1),    not pert(E,G), infl(E,N,G,1).
:- vlabel(E,N,G,am), not pert(E,G), not infl(E,N,G,1).
:- vlabel(E,N,G,am), not pert(E,G), not infl(E,N,G,-1).


getspos(E,N,X) :- vertex(N,X), pert(E,X,1).
getspos(E,N,X) :- getspos(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,1).
getspos(E,N,X) :- getsneg(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,-1).

getsneg(E,N,X) :- vertex(N,X), pert(E,X,-1).
getsneg(E,N,X) :- getsneg(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,1).
getsneg(E,N,X) :- getspos(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,-1).

% founded 1
founded(E,N,X) :- vlabel(E,N,X, 1), getspos(E,N,X).
% founded -1
founded(E,N,X) :- vlabel(E,N,X,-1), getsneg(E,N,X).
% founded am
founded(E,N,X) :- vlabel(E,N,X,am), getspos(E,N,X), getsneg(E,N,X).

:- vlabel(E,N,X, 1), not founded(E,N,X).
:- vlabel(E,N,X,-1), not founded(E,N,X).
:- vlabel(E,N,X,am), not founded(E,N,X).


% define when two signs are different
uneq(1,0).
uneq(1,-1).
uneq(0,1).
uneq(0,-1).
uneq(-1,1).
uneq(-1,0).
uneq(am,1).
uneq(am,0).
uneq(am,-1).
uneq(1,am).
uneq(0,am).
uneq(-1,am).


% check whether labelings are different
difflabel(E,N1,G,S1) :- readout(E,G), vlabel(E,N1,G,S1), vlabel(E,N2,G,S2), N1!=N2, uneq(S1,S2).
diff(E,N1,N2) :- readout(E,G), vlabel(E,N1,G,S1), vlabel(E,N2,G,S2), N1<N2, uneq(S1,S2).
diff(E) :- diff(E,N1,N2).
:- cexperiment(E), not diff(E).
diff :- diff(E).
diff(N1,N2) :- diff(E,N1,N2).
countdiff(Z) :- Z = #count{diff(N1,N2)}.


net(N) :- vertex(N,X).

same(N1,N2) :- net(N1), net(N2), N1<N2, not diff(N1,N2).
%same(E,N1,N2) :- net(N1), net(N2),N1<N2, exp(E), not diff(E,N1,N2).


% the first experiment must distinguish atleast 2 network classes
exp(E) :- pert(E,G).
:- exp(1) , not diff(1).

% each further experiment must distinguish atleast 1 more network class
sdiff(E,N1,N2) :- exp(E), exp(E2), E2<=E, diff(E2,N1,N2).
newdiff(E) :-  exp(E), exp(E2), E2<E, diff(E,N1,N2), not sdiff(E2,N1,N2).
:- exp(E1), exp(E2), E2>E1, not newdiff(E2).



has_smaller_same(Y) :- same(X,Y).
notunique(X) :- same(X,Y).
notunique(Y) :- same(X,Y).
eqclass(X) :- same(X,Y), not has_smaller_same(X).
eqclass(X) :- net(X) , not notunique(X).
counteqclasses(Z) :- Z = #count{eqclass(X)}.
:- not diff.

% maximize network clusters
%#maximize[ not false, eqclass(X) @4 ].
% maximize differences
#maximize[ not false, diff(N1,N2) @3 ].
%#minimize[ cexperiment(X) @ 2 ].
#minimize[ false, pert(E,G) @1 ].
#hide.

% #show exp/1.

#show pert/3.
% #show readout/2.

% #show diff/2.
% #show sameclass/1.
% #show eqclass/1.
#show counteqclasses/1.
#show countdiff/1.

#show difflabel/4.