% vertex(N,X)           vertex X in network N
% obs_elabel(N,X,Y,S).  edge from X to Y with sign S in network N
% preadout(X).          possible readout in node X
% pperturb(X,S).        possible perturbed node X, S sign of perturbation
% done(E,X,S).          already performed experiment E, perturbe node X with sign S

sign(1;-1;0).
% possible experiments
exp(1..X) :- pexperiment(X).
% the networks
net(N) :- vertex(N,X).
% keep isolated vertices
vertex(N,X) :- obs_elabel(N,Y,X,S).
vertex(N,Y) :- obs_elabel(N,Y,X,S).
vertex(X)   :- vertex(N,X).
vertex(N,X) :- net(N), vertex(X).


elabel(N,Y,X,S) :- obs_elabel(N,Y,X,S). % iggy style


%% filter already done experiments

donexp(DE) :- done(DE,X,S).

% a experiment DE is not equal to E, if atleat one pertubations X,S done in DE is not done (not pert(E,X,S))
is_not_redone(DE,E) :- done(DE,X,S), not pert(E,X,S), exp(E).
% a experiment DE is not equal to E, if atleat one pertubations X,S not done in DE is done in E (pert(E,X,S))
is_not_redone(DE,E) :- donexp(DE), not done(DE,X,S), pert(E,X,S).

is_redone :- not is_not_redone(DE,E), donexp(DE), exp(E).
:- is_redone.


%% filter stupid zero pertubations
% node X has a predecessor
has_pred(X)  :- vertex(N,X), elabel(N,Y,X,S), Y!=X.
% node X would be 0 because it has no predecessors
zero_anyway(E,X) :- vertex(N,X), not has_pred(X), not pert(E,X,1), not pert(E,X,-1), exp(E).
% node X has one predecessor which would not be 0 anyways
one_predessor_not_zero(E,X) :- elabel(N,Y,X,S), not zero_anyway(E,Y), exp(E).
% node X would be 0 because all its predecessors would be  0
zero_anyway(E,X) :- vertex(N,X), not one_predessor_not_zero(E,X), not pert(E,X,1), not pert(E,X,-1), exp(E).

% forbid 0-pertubations in nodes which must be zero anyway
:- pert(E,X,0), zero_anyway(E,X).


%% choose pertubations, filter those which dont lead to a possible readout

% node X has a path to a preadout in network N
to_preadout(X,N) :- preadout(X), net(N).
to_preadout(X,N) :- to_preadout(Y,N), elabel(N,X,Y,S).
% node X has a path to a preadout in some network
to_preadout(X):- to_preadout(X,N).

{pert(E,X,S)} :- to_preadout(X), pperturb(X,S), exp(E). 
pert(E,X) :- pert(E,X,S).
pert(X)   :- pert(E,X).

input(E,X):- pert(E,X).                 % iggy style
vlabel(E,N,X,S) :- pert(E,X,S), net(N). % iggy style

% no two pertubations in the same node
:- pert(E,X,S1), pert(E,X,S2), S1!=S2.


%% choose readouts, filter those which are not reachable by a perturbed node

% X is possible influenced by a pperturb in network N
pinfluenced(X,N) :- pperturb(X,S), net(N).
pinfluenced(X,N) :- pinfluenced(Y,N), elabel(N,Y,X,S).
% X is possible influenced by a pperturb in some network
pinfluenced(X) :- pinfluenced(X,N).

% X is influenced by a pert in network N
influenced(E,X,N) :- pert(E,X), net(N).
influenced(E,X,N) :- influenced(E,Y,N), elabel(N,Y,X,S).
% X is influenced by a pert in some network
influenced(E,X) :- influenced(E,X,N).

%{readout(E,X)} :- preadout(X), exp(E). 
readout(E,X) :- influenced(E,X), preadout(X). 


%% force total order biggest different pertubation last

diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), pert(E1,G,S),  not pert(E1+1,G,S).
diffpert(G,S,E1,E1+1) :- exp(E1), exp(E1+1), not pert(E1,G,S), pert(E1+1,G,S).
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G2,S2,E1,E2), G<G2.
hasbiggerdiffpert(G,S,E1,E2) :-  diffpert(G,S,E1,E2), diffpert(G,S2,E1,E2),  S<S2.
biggestdiffpert(G,S,E1,E2) :- diffpert(G,S,E1,E2) , not hasbiggerdiffpert(G,S,E1,E2).
:- exp(E1),exp(E2), E1<E2, biggestdiffpert(G,S,E1,E2), pert(E1,G,S), not pert(E2,G,S).




%% compute labeling

1{vlabel(E,N,V,1), vlabel(E,N,V,-1), vlabel(E,N,V,0)} :- vertex(N,V), exp(E).

% influences
infl(E,N,V,S*T) :- elabel(N,U,V,S), vlabel(E,N,U,T).

% pure influences
pinfl(E,N,V, 1) :- elabel(N,U,V, 1), vlabel(E,N,U, 1), not vlabel(E,N,U,0), not vlabel(E,N,U,-1).
pinfl(E,N,V,-1) :- elabel(N,U,V,-1), vlabel(E,N,U, 1), not vlabel(E,N,U,0), not vlabel(E,N,U,-1).
pinfl(E,N,V,-1) :- elabel(N,U,V, 1), vlabel(E,N,U,-1), not vlabel(E,N,U,0), not vlabel(E,N,U, 1).
pinfl(E,N,V, 1) :- elabel(N,U,V,-1), vlabel(E,N,U,-1), not vlabel(E,N,U,0), not vlabel(E,N,U, 1).


% constraints
:- forbidden(E,N,V,S), vlabel(E,N,V,S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute pos_path, neg_path are in module elementary_path_constraint.lp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% keep observed input variation
forbidden(E,N,V,T) :- input(E,V), vlabel(E,N,V,S), sign(S), sign(T), S!=T.


% measured variations must be explained by  predecessor

forbidden(E,N,V, 1) :- exp(E), vertex(N,V), not infl(E,N,V, 1), not input(E,V).
forbidden(E,N,V,-1) :- exp(E), vertex(N,V), not infl(E,N,V,-1), not input(E,V).

% propagate forward
vlabel(E,N,V, 0) :- exp(E), vertex(N,V), not forbidden(E,N,V, 0).
vlabel(E,N,V, 1) :- infl(E,N,V, 1), not forbidden(E,N,V, 1).
vlabel(E,N,V,-1) :- infl(E,N,V,-1), not forbidden(E,N,V,-1).


% constraint zero for generic nodes
forbidden(E,N,gen(V),0) :- pinfl(E,N,gen(V), 1), not infl(E,N,gen(V),-1), not input(E,gen(V)), not ismax(E,gen(V)).
forbidden(E,N,gen(V),0) :- pinfl(E,N,gen(V),-1), not infl(E,N,gen(V), 1), not input(E,gen(V)), not ismin(E,gen(V)).

% constraint zero for depmat does not work with and nodes
% pure influences
prinfl(E,N,V, 1) :- elabel(N,U,V, 1),
                    pos_path(E,N,V,P),1==@member(U,P),
                    vlabel(E,N,U, 1), not vlabel(E,N,U,0), not vlabel(E,N,U,-1).
prinfl(E,N,V,-1) :- elabel(N,U,V,-1),
                    neg_path(E,N,V,P),1==@member(U,P),
                    vlabel(E,N,U, 1), not vlabel(E,N,U,0), not vlabel(E,N,U,-1).
prinfl(E,N,V,-1) :- elabel(N,U,V, 1),
                    neg_path(E,N,V,P),1==@member(U,P),
                    vlabel(E,N,U,-1), not vlabel(E,N,U,0), not vlabel(E,N,U, 1).
prinfl(E,N,V, 1) :- elabel(N,U,V,-1),
                    pos_path(E,N,V,P),1==@member(U,P),
                    vlabel(E,N,U,-1), not vlabel(E,N,U,0), not vlabel(E,N,U, 1).

forbidden(E,N,gen(V), 0) :- exp(E), prinfl(E,N,gen(V), 1), not neg_path(E,N,gen(V)), not input(E,gen(V)), not ismax(E,gen(V)).
forbidden(E,N,gen(V), 0) :- exp(E), prinfl(E,N,gen(V),-1), not pos_path(E,N,gen(V)), not input(E,gen(V)), not ismin(E,gen(V)).

% constraint zero for and nodes
forbidden(E,N,and(V),0) :- infl(E,N,and(V), 1), not infl(E,N,and(V),-1), not infl(E,N,and(V),0), not input(E,and(V)), not ismax(E,and(V)).
forbidden(E,N,and(V),0) :- infl(E,N,and(V),-1), not infl(E,N,and(V), 1), not infl(E,N,and(V),0), not input(E,and(V)), not ismin(E,and(V)).



% project multisign/labeling
mvlabel(E,N,V, 0) :- readout(E,V), vlabel(E,N,V, 0), not vlabel(E,N,V, 1), not vlabel(E,N,V,-1).
mvlabel(E,N,V, 1) :- readout(E,V), vlabel(E,N,V, 1), not vlabel(E,N,V, 0), not vlabel(E,N,V,-1).
mvlabel(E,N,V,-1) :- readout(E,V), vlabel(E,N,V,-1), not vlabel(E,N,V, 0), not vlabel(E,N,V, 1).
mvlabel(E,N,V,nm) :- readout(E,V), vlabel(E,N,V, 0),     vlabel(E,N,V, 1), not vlabel(E,N,V,-1).
mvlabel(E,N,V,np) :- readout(E,V), vlabel(E,N,V, 0),     vlabel(E,N,V,-1), not vlabel(E,N,V, 1).
mvlabel(E,N,V,am) :- readout(E,V), vlabel(E,N,V, 0),     vlabel(E,N,V,-1),     vlabel(E,N,V, 1).


% define when two signs are different (and what the chances for differentiation are)
uneq(1, 0).
uneq(1,-1).
uneq(0, 1).
uneq(0,-1).
uneq(-1,1).
uneq(-1,0).
uneq(np, 1).
uneq( 1,np).
uneq(nm,-1).
uneq(-1,nm).

uneq2(nm,np).
uneq2(np,nm).
uneq2(np,-1).
uneq2(np, 0).
uneq2(-1,np).
uneq2( 0,np).
uneq2(nm, 1).
uneq2(nm, 0).
uneq2( 1,nm).
uneq2( 0,nm).
uneq2(am, 1).
uneq2(am, 0).
uneq2(am,-1).
uneq2( 1,am).
uneq2( 0,am).
uneq2(-1,am).


uneq3(am,np).
uneq3(am,nm).
uneq3(np,am).
uneq3(nm,am).


% check whether experiment may differentiate between the labels
difflabel(E,N1,X,S1) :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1!=N2, uneq(S1,S2), readout(E,X).
diff1(E,N1,N2)       :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1<N2,  uneq(S1,S2), readout(E,X).
diff1(N1,N2)         :- diff1(E,N1,N2).
% countdiff1(Z)        :- Z = #count{diff1(N1,N2)}.

% check whether experiment may differentiate between the labels
difflabel(E,N1,X,S1) :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1!=N2, uneq2(S1,S2), readout(E,X).
diff2(E,N1,N2)       :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1<N2,  uneq2(S1,S2), readout(E,X).
diff2(N1,N2)         :- diff2(E,N1,N2).

% check whether experiment may differentiate between the labels
difflabel(E,N1,X,S1) :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1!=N2, uneq3(S1,S2), readout(E,X).
diff3(E,N1,N2)       :- mvlabel(E,N1,X,S1), mvlabel(E,N2,X,S2), N1<N2,  uneq3(S1,S2), readout(E,X).
diff3(N1,N2)         :- diff3(E,N1,N2).

diff(E,N1,N2)  :- diff1(E,N1,N2).
diff(E,N1,N2)  :- diff2(E,N1,N2).
diff(E,N1,N2)  :- diff3(E,N1,N2).
diff(E) :- diff(E,N1,N2).
% every experiment must distinguish atleast 2 network classes
:- exp(E), not diff(E).

diffreadout(E,X) :- difflabel(E,N1,X,S1).


% each further experiment must distinguish atleast 1 more network
sdiff(E,N1,N2) :- exp(E), exp(E2), E2<=E, diff(E2,N1,N2).
newdiff(E)     :- exp(E), exp(E2), E2<E,  diff(E,N1,N2), not sdiff(E2,N1,N2).
newdiff(E,N1,N2)     :- exp(E), exp(E2), E2<E,  diff(E,N1,N2), not sdiff(E2,N1,N2).
:- exp(E1), exp(E2), E2>E1, not newdiff(E2).


% who is influencing the readout that is different in two candidate network
hasinfl_diffreadout(E,X,N) :- diffreadout(E,Y), elabel(N,X,Y,S).
hasinfl_diffreadout(E,X,N) :- hasinfl_diffreadout(E,Y,N), elabel(N,X,Y,S).
hasinfl_diffreadout(E,X)   :- hasinfl_diffreadout(E,X,N).
% jede pertubation muss einen underschied in einem readout verantworten
:- pert(E,X), not hasinfl_diffreadout(E,X).


% count eq classes
same(N1,N2)         :- net(N1), net(N2), N1<N2, not diff1(N1,N2), not diff2(N1,N2), not diff3(N1,N2).
has_smaller_same(Y) :- same(X,Y).

notunique(X)        :- same(X,Y).
notunique(Y)        :- same(X,Y).

eqclass(X)          :- same(X,Y), not has_smaller_same(X).
eqclass(X)          :- net(X) , not notunique(X).
counteqclasses(Z)   :- Z = #count{eqclass(X)}.


% maximize differences
#maximize[ not false, diff1(N1,N2) @4 ].
d2(N1,N2) :- diff2(N1,N2), not diff1(N1,N2).
#maximize[ not false, d2(N1,N2) @3 ].
d3(N1,N2) :- diff3(N1,N2), not diff2(N1,N2), not diff1(N1,N2).
#maximize[ not false, d3(N1,N2) @2 ].

% minimize pertubations
#minimize[ false, pert(E,G) @1 ].
#hide.


#show pert/3.
#show counteqclasses/1.
#show difflabel/4.
% #show vlabel/4.
% #show mvlabel/4.
#show newdiff/1.
#show newdiff/3.
#show sdiff/3.