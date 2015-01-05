% the networks
net(N) :- vertex(N,X).

% keep isolated vertices
vertex(N,X) :- obs_elabel(N,Y,X,S).
vertex(N,Y) :- obs_elabel(N,Y,X,S).
vertex(X) :- vertex(N,X).
vertex(N,X) :- net(N), vertex(X).

%pertubations
per(1).
per(-1).
per(0).



% define already done experiments
done(1,gen("B"),-1).
done(2,gen("R"),1).
done(3,gen("E"),-1).
done(4,gen("B"),-1).
done(4,gen("E"),-1).

% filter already done experiments
donexp(DE) :- done(DE,G,S).

ndone(DE,G,S) :- pperturb(G,S), donexp(DE), not done(DE,G,S).
ndone(DE,G,S) :- done(DE2,G2,S2), donexp(DE), vertex(G), per(S), not done(DE,G,S).

one_undone(DE) :- done(DE,X,S), npert(X,S).
one_new(DE) :- ndone(DE,X,S), pert(X,S).

:- not one_new(DE), not one_undone(DE), donexp(DE).


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
%{pert(G,S)} :- hasinfl(G), pperturb(G,S).
{pert(G,S)} :- hasinfl(G), pperturb(G,S), not forbidden_pert(G,S). 
pert(G) :- pert(G,S).

% pert(gen("R"),1).
% pert(gen("E"),-1).

% no two pertubations in the same node
:- pert(G,S1), pert(G,S2),S1!=S2.

% is possibly perturned
is_pperturbed(X) :- pperturb(X,S).
is_pperturbed(Y) :- is_pperturbed(X), obs_elabel(N,X,Y,S).

% check if a node has at least one pertubator in a network 
is_pertubed(X) :- pert(X).
is_pertubed(Y) :- is_pperturbed(Y), is_pertubed(X), obs_elabel(N,X,Y,S).


% choose experimental readouts (take all)
readout(G) :- is_pertubed(G), preadout(G). 
%{readout(G)} :- preadout(G). 

npert(G,S) :- pperturb(G,S), not pert(G,S).


% compute labeling

wtoreadout(X) :- preadout(X), is_pperturbed(X).
wtoreadout(X) :- obs_elabel(N,X,Y,S), wtoreadout(Y).

frompert(X) :- pperturb(X,S), hasinfl(X).
frompert(X) :- obs_elabel(N,Y,X,S), frompert(Y).

both(X) :- wtoreadout(X), frompert(X).

count_edges(N,Z) :-  Z = #count{obs_elabel(N,X,Y,S)}, net(N).

path(N,X,Y, l(X,Y),1) :- pert(X),      obs_elabel(N,X,Y, S), npert(Y).
path(N,X,Y, l(PXZ,Y),C+1) :- path(N,X,Z,PXZ,C), obs_elabel(N,Z,Y, S), npert(Y), count_edges(N,C2), C+1<C2.

path(PATH) :- path(N,X,Y, PATH,C).
npert(X) :-  vertex(X), not pert(X).

pos_path(N,X,Y, l(X,Y) ) :- pert(X),      obs_elabel(N,X,Y, 1), npert(Y).
neg_path(N,X,Y, l(X,Y) ) :- pert(X),      obs_elabel(N,X,Y,-1), npert(Y).

pos_path(N,X,Y, l(PXZ,Y)) :- pos_path(N,X,Z,PXZ), obs_elabel(N,Z,Y, 1), npert(Y), notin(Y,PXZ).
pos_path(N,X,Y, l(PXZ,Y)) :- neg_path(N,X,Z,PXZ), obs_elabel(N,Z,Y,-1), npert(Y), notin(Y,PXZ).

neg_path(N,X,Y, l(PXZ,Y)) :- neg_path(N,X,Z,PXZ), obs_elabel(N,Z,Y, 1), npert(Y), notin(Y,PXZ).
neg_path(N,X,Y, l(PXZ,Y)) :- pos_path(N,X,Z,PXZ), obs_elabel(N,Z,Y,-1), npert(Y), notin(Y,PXZ).

notin(X, Y) :- X!=Y, both(X), both(Y),pperturb(Y,S).
notin(X, l(Y,Z)) :- X!=Z, notin(X,Y), notin(Z,Y),path(l(Y,Z)).


getspos(N,Y) :- pert(X, 1), readout(Y), pos_path(N,X,Y,PATH).
getspos(N,Y) :- pert(X,-1), readout(Y), neg_path(N,X,Y,PATH).

getsneg(N,Y) :- pert(X, 1), readout(Y), neg_path(N,X,Y,PATH).
getsneg(N,Y) :- pert(X,-1), readout(Y), pos_path(N,X,Y,PATH).


vlabel(N,G,am) :- readout(G), getspos(N,G), getsneg(N,G).
vlabel(N,G,1)  :- readout(G), getspos(N,G), not getsneg(N,G).
vlabel(N,G,-1) :- readout(G), getsneg(N,G), not getspos(N,G).

vlabel(N,G,0)  :- readout(G), not getsneg(N,G), not getspos(N,G), vertex(N,G).
vlabel(N,G,0)  :- readout(G), not getsneg(N,G), not getspos(N,G), vertex(N,G).


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
difflabel(1,N1,G,S1) :- vlabel(N1,G,S1), vlabel(N2,G,S2), N1!=N2, uneq(S1,S2).
diff(N1,N2)          :-  vlabel(N1,G,S1), vlabel(N2,G,S2), N1<N2, uneq(S1,S2).
diff :- diff(N1,N2).

countdiff(Z) :- Z = #count{diff(N1,N2)}.

% every experiment must distinguish atleast 2 network classes
:- not diff.

same(N1,N2) :- net(N1), net(N2), N1<N2, not diff(N1,N2).

countpert(Z) :- Z = #count{ pert(G)}.

has_smaller_same(Y) :- same(X,Y).
notunique(X) :- same(X,Y).
notunique(Y) :- same(X,Y).
eqclass(X) :- same(X,Y), not has_smaller_same(X).
eqclass(X) :- net(X) , not notunique(X).
counteqclasses(Z) :- Z = #count{eqclass(X)}.

% maximize network clusters
#maximize[ not false, eqclass(X) @3 ].
% maximize differences
#maximize[ not false, diff(N1,N2) @2 ].
% minimize pertubations
#minimize[ false, pert(G) @1 ].
#hide.


pert(1,X,Y) :- pert(X,Y).
#show pert/3.

#show counteqclasses/1.
#show countdiff/1.
#show difflabel/4.

