
done(1,gen("B"),-1).
done(2,gen("R"),1).
done(3,gen("E"),-1).
done(4,gen("B"),-1).
done(4,gen("E"),-1).

donexp(DE) :- done(DE,G,S).

ndone(DE,G,S) :- done(DE,G2,S2), pperturb(G,S), not done(DE,G,S).

one_undone(E,DE) :- done(DE,X,S), npert(E,X,S).
one_new(E,DE) :- ndone(DE,X,S), pert(E,X,S).

:- not one_new(E,DE), not one_undone(E,DE), exp(E),donexp(DE).


% possible experiments
exp(1..X) :- pexperiment(X).

% keep isolated vertices
vertex(N,X) :- obs_elabel(N,Y,X,S).
vertex(N,Y) :- obs_elabel(N,Y,X,S).
vertex(X) :- vertex(N,X).
vertex(N,X) :- net(N), vertex(X).


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
%{pert(E,G,S)} :- hasinfl(G), pperturb(G,S), exp(E).
{pert(E,G,S)} :- hasinfl(G), pperturb(G,S), not forbidden_pert(G,S), exp(E). 
pert(E,G) :- pert(E,G,S).

%exp(1..1).
%pert(1,gen("R"),-1).

%pert(1,gen("A"),-1).
%pert(2,gen("R"),1).

%pert(3,gen("E"),-1).
%pert(3,gen("R"),1).




% no two pertubations in the same node
:- pert(E,G,S1), pert(E,G,S2),S1!=S2.


is_perturbed1(X) :- pperturb(X,S).
is_perturbed1(Y) :- is_perturbed1(X), obs_elabel(N,X,Y,S).


% check if a node has at least one pertubator in a network in an experiment
is_pertubed(E,X) :- is_perturbed1(X), pert(E,X).
is_pertubed(E,Y) :- is_perturbed1(Y), is_pertubed(E,X), obs_elabel(N,X,Y,S).


% choose experimental readouts (take all)
readout(E,G) :- is_perturbed1(G), is_pertubed(E,G), preadout(G). 
%{readout(E,G)} :- preadout(G), exp(E). 


npert(E,G,S) :- pperturb(G,S), exp(E), not pert(E,G,S).



% force total order biggest different pertubation last
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), pert(E1,G,S),  npert(E1+1,G,S).
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), npert(E1,G,S), pert(E1+1,G,S).
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G<G2.
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G,S2,E1,E2),  S<S2.
biggestdiffpert(G,S,E1,E2) :- diffpert(G,S,E1,E2) , not hasbiggerdiffpert(G,S,E1,E2).
:- exp(E1),exp(E2), E1<E2, biggestdiffpert(G,S,E1,E2), pert(E1,G,S), npert(E2,G,S).



% compute labeling

wtoreadout(X) :- preadout(X), is_perturbed1(X).
wtoreadout(X) :- obs_elabel(N,X,Y,S), wtoreadout(Y).

frompert(X) :- pperturb(X,S), hasinfl(X).
frompert(X) :- obs_elabel(N,Y,X,S), frompert(Y).

both(X) :- wtoreadout(X), frompert(X).

count_edges(N,Z) :-  Z = #count{obs_elabel(N,X,Y,S)}, net(N).

path(E,N,X,Y, l(X,Y),1) :- pert(E,X),      obs_elabel(N,X,Y, S), npert(E,Y).
path(E,N,X,Y, l(PXZ,Y),C+1) :- path(E,N,X,Z,PXZ,C), obs_elabel(N,Z,Y, S), npert(E,Y), count_edges(N,C2), C+1<C2.

path(PATH) :- path(E,N,X,Y, PATH,C).
npert(E,X) :-  vertex(X), exp(E), not pert(E,X).

pos_path(E,N,X,Y, l(X,Y) ) :- pert(E,X),      obs_elabel(N,X,Y, 1), npert(E,Y).
neg_path(E,N,X,Y, l(X,Y) ) :- pert(E,X),      obs_elabel(N,X,Y,-1), npert(E,Y).

pos_path(E,N,X,Y, l(PXZ,Y)) :- pos_path(E,N,X,Z,PXZ), obs_elabel(N,Z,Y, 1), npert(E,Y), notin(Y,PXZ).
pos_path(E,N,X,Y, l(PXZ,Y)) :- neg_path(E,N,X,Z,PXZ), obs_elabel(N,Z,Y,-1), npert(E,Y), notin(Y,PXZ).

neg_path(E,N,X,Y, l(PXZ,Y)) :- neg_path(E,N,X,Z,PXZ), obs_elabel(N,Z,Y, 1), npert(E,Y), notin(Y,PXZ).
neg_path(E,N,X,Y, l(PXZ,Y)) :- pos_path(E,N,X,Z,PXZ), obs_elabel(N,Z,Y,-1), npert(E,Y), notin(Y,PXZ).

notin(X, Y) :- X!=Y, both(X), both(Y),pperturb(Y,S).
notin(X, l(Y,Z)) :- X!=Z, notin(X,Y), notin(Z,Y),path(l(Y,Z)).


getspos(E,N,Y) :- pert(E,X, 1), readout(E,Y), pos_path(E,N,X,Y,PATH).
getspos(E,N,Y) :- pert(E,X,-1), readout(E,Y), neg_path(E,N,X,Y,PATH).

getsneg(E,N,Y) :- pert(E,X, 1), readout(E,Y), neg_path(E,N,X,Y,PATH).
getsneg(E,N,Y) :- pert(E,X,-1), readout(E,Y), pos_path(E,N,X,Y,PATH).


vlabel(E,N,G,am) :- readout(E,G), getspos(E,N,G), getsneg(E,N,G).
vlabel(E,N,G,1)  :- readout(E,G), getspos(E,N,G), not getsneg(E,N,G).
vlabel(E,N,G,-1) :- readout(E,G), getsneg(E,N,G), not getspos(E,N,G).

vlabel(E,N,G,0)  :- readout(E,G), not getsneg(E,N,G), not getspos(E,N,G), exp(E), vertex(N,G).
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
difflabel(E,N1,G,S1) :- vlabel(E,N1,G,S1), vlabel(E,N2,G,S2), N1!=N2, uneq(S1,S2).
diff(E,N1,N2)        :-  vlabel(E,N1,G,S1), vlabel(E,N2,G,S2), N1<N2, uneq(S1,S2).
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

countpert(E,Z) :- Z = #count{ pert(E,G)}, exp(E).

has_smaller_same(Y) :- same(X,Y).
notunique(X) :- same(X,Y).
notunique(Y) :- same(X,Y).
eqclass(X) :- same(X,Y), not has_smaller_same(X).
eqclass(X) :- net(X) , not notunique(X).
counteqclasses(Z) :- Z = #count{eqclass(X)}.

% maximize network clusters
#maximize[ not false, eqclass(X) @4 ].
% maximize differences
#maximize[ not false, diff(N1,N2) @3 ].
%#minimize[ exp(X) @ 2 ].
#minimize[ false, pert(E,G) @1 ].
#hide.

% #show exp/1.

#show pert/3.
%#show pert/2.
% #show readout/2.
%#show notin/2.

% #show diff/2.
% #show sameclass/1.
% #show eqclass/1.
#show counteqclasses/1.
#show countdiff/1.
#show pos_path/5.
#show neg_path/5.
%#show npert/2.

#show getspos/3.
%#show vlabel/4.
#show difflabel/4.
