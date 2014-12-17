
%done(1,B,-1).

% possible experiments
exp(1..X) :- pexperiment(X).

% keep isolated vertices
vertex(N,X) :- net(N), vertex(M,X).


% check if a node has influence on a readout in a network
hasinfl(X) :- preadout(Z), obs_elabel(N,X,Z,S).
hasinfl(X) :- hasinfl(Z), obs_elabel(N,X,Z,S).


has_pred(X)  :- vertex(N,X), obs_elabel(N,Y,X,S), Y!=X.
must_zero(X) :- vertex(N,X), not has_pred(X).
one_predessor_not_zero(X) :- obs_elabel(N,Y,X,S), not must_zero(Y).
must_zero(X) :- vertex(N,X), not one_predessor_not_zero(X).
% forbid 0-pertubations in nodes which must be zero anyway
forbidden_pert(G,0) :- pperturb(G,0), must_zero(G).

% choose experimental pertubations, filter those which have no influence on a readout
{pert(E,G,S)} :- hasinfl(G), pperturb(G,S), exp(E).
%{pert(E,G,S)} :- hasinfl(G), pperturb(G,S), not forbidden_pert(G,S), exp(E). 
pert(E,G) :- pert(E,G,S).



% no two pertubations in the same node
:- pert(E,G,S1),pert(E,G,S2),S1!=S2.


is_perturbed1(X) :- pperturb(X,S).
is_perturbed1(Y) :- is_perturbed1(X), obs_elabel(N,X,Y,S).


% check if a node has at least one pertubator in a network in an experiment
is_pertubed(E,X) :- is_perturbed1(X), pert(E,X).
is_pertubed(E,Y) :- is_perturbed1(Y), is_pertubed(E,X), obs_elabel(N,X,Y,S).


% choose experimental readouts (take all)
readout(E,G) :- is_perturbed1(G), is_pertubed(E,G), preadout(G). 
%{readout(E,G)} :- preadout(G), exp(E). 



npert(E,G,S) :- pperturb(G,S), exp(E), not pert(E,G,S).

% not two times the same experiment
%allpert(E2,E1) :- pert(E2,G,S) : pert(E1,G,S); exp(E1), exp(E2), E1 < E2.
%allnpert(E2,E1) :- npert(E2,G,S) : npert(E1,G,S); exp(E1), exp(E2), E1 < E2.
%:- allpert(E1,E2), allnpert(E1,E2), E1 < E2.

% force an order among the experiments, the first experiment has the least pertubations
countpert(E,Z) :- Z = #count{ pert(E,G)}, exp(E).
:- countpert(E1,Z1), countpert(E1+1,Z2), Z1>Z2.

% force total order biggest different pertubation last
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), pert(E1,G,S),  npert(E1+1,G,S).
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), npert(E1,G,S), pert(E1+1,G,S).
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G<G2.
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G==G2, S<S2.
biggestdiffpert(G,S,E1,E2) :- diffpert(G,S,E1,E2) , not hasbiggerdiffpert(G,S,E1,E2).
:- exp(E1),exp(E2), E1<E2, biggestdiffpert(G,S,E1,E2), pert(E1,G,S), npert(E2,G,S).



% compute labeling
getspos(E,N,X) :- vertex(N,X), pert(E,X,1).
getspos(E,N,X) :- getspos(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,1).
getspos(E,N,X) :- getsneg(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,-1).

getsneg(E,N,X) :- vertex(N,X), pert(E,X,-1).
getsneg(E,N,X) :- getsneg(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,1).
getsneg(E,N,X) :- getspos(E,N,Y), not pert(E,X), obs_elabel(N,Y,X,-1).

vlabel(E,N,G,am) :- readout(E,G), getspos(E,N,G), getsneg(E,N,G).
vlabel(E,N,G,1)  :- readout(E,G), getspos(E,N,G), not getsneg(E,N,G).
vlabel(E,N,G,-1) :- readout(E,G), getsneg(E,N,G), not getspos(E,N,G).
vlabel(E,N,G,0)  :- readout(E,G), not getsneg(E,N,G), not getspos(E,N,G), exp(E), vertex(N,G).


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
diff(N1,N2) :- diff(E,N1,N2).
countdiff(Z) :- Z = #count{diff(N1,N2)}.


net(N) :- vertex(N,X).

same(N1,N2) :- net(N1), net(N2), N1<N2, not diff(N1,N2).
%same(E,N1,N2) :- net(N1), net(N2),N1<N2, exp(E), not diff(E,N1,N2).


% every experiment must distinguish atleast 2 network classes
:- exp(E), not diff(E).

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

% maximize network clusters
%#maximize[ not false, eqclass(X) @4 ].
% maximize differences
#maximize[ not false, diff(N1,N2) @3 ].
%#minimize[ exp(X) @ 2 ].
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
%#show vlabel/4.
#show difflabel/4.