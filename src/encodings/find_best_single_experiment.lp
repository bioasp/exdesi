% vertex(N,X)           vertex X in network N
% obs_elabel(N,X,Y,S).  edge from X to Y with sign S in network N
% preadout(X).          possible readout in node X
% pperturb(X,S).        possible perturbed node X, S sign of perturbation
% done(E,X,S).          already performed experiment E, perturbe node X with sign S

% possible experiments
exp(1..X) :- pexperiment(X).
% the networks
net(N) :- vertex(N,X).
% keep isolated vertices
vertex(N,X) :- obs_elabel(N,Y,X,S).
vertex(N,Y) :- obs_elabel(N,Y,X,S).
vertex(X) :- vertex(N,X).
vertex(N,X) :- net(N), vertex(X).



%% filter already done experiments

donexp(DE) :- done(DE,X,S).

% a experiment DE is not redone if atleat one pertubations X,S done in DE is not done (not pert(X,S))
is_not_redone(DE) :- done(DE,X,S), not pert(X,S).
% a experiment DE is not redone if atleat one pertubations X,S not done in DE is done ( pert(X,S))
is_not_redone(DE) :- donexp(DE), not done(DE,X,S), pert(X,S).

is_redone :- not is_not_redone(DE), donexp(DE).
:- is_redone.


%% filter stupid zero pertubations
% node X has a predecessor
has_pred(X)  :- vertex(N,X), obs_elabel(N,Y,X,S), Y!=X.
% node X would be 0 because it has no predecessors
zero_anyway(X) :- vertex(N,X), not has_pred(X), not pert(X,1), not pert(X,-1).
% node X has one predecessor which would not be 0 anyways
one_predessor_not_zero(X) :- obs_elabel(N,Y,X,S), not zero_anyway(Y).
% node X would be 0 because all its predecessors would be  0
zero_anyway(X) :- vertex(N,X), not one_predessor_not_zero(X), not pert(X,1), not pert(X,-1).

% forbid 0-pertubations in nodes which must be zero anyway
:- pert(X,0), zero_anyway(X).


%% choose pertubations, filter those which dont lead to a possible readout

% node X has a path to a preadout in network N
to_preadout(X,N) :- preadout(Y), obs_elabel(N,X,Y,S).
to_preadout(X,N) :- to_preadout(Y,N), obs_elabel(N,X,Y,S).
% node X has a path to a preadout in some network
to_preadout(X):- to_preadout(X,N).

{pert(X,S)} :- to_preadout(X), pperturb(X,S). 
pert(X) :- pert(X,S).

% no two pertubations in the same node
:- pert(G,S1), pert(G,S2), S1!=S2.


%% choose readouts, filter those which are not reachable by a perturbed node

% X is possible influenced by a pperturb in network N
pinfluenced(X,N) :- pperturb(X,S), net(N).
pinfluenced(X,N) :- pinfluenced(Y,N), obs_elabel(N,Y,X,S).
% X is possible influenced by a pperturb in some network
pinfluenced(X) :- pinfluenced(X,N).

% X is influenced by a pert in network N
influenced(X,N) :- pert(X), net(N).
influenced(X,N) :- influenced(Y,N), obs_elabel(N,Y,X,S).
% X is influenced by a pert in some network
influenced(X) :- influenced(X,N).

%{readout(X)} :- preadout(X).
readout(X) :- influenced(X), preadout(X).



%% compute labeling


% X is on the way to a readout if it is a potential readout that has a possible pertubator
wtoreadout(X) :- preadout(X), pinfluenced(X).
% X is on the way to a readout if it is a potential readout that is also possibly pertubed
wtoreadout(X) :- obs_elabel(N,X,Y,S), wtoreadout(Y).

% wenn es in keinem netzwerk einen weg zum readout gibt dann ist es keine lösung
:- pert(X), not wtoreadout(X).

frompert(X) :- pperturb(X,S), to_preadout(X).
frompert(X) :- obs_elabel(N,Y,X,S), frompert(Y).

both(X) :- wtoreadout(X), frompert(X).


% in network n exist a pos_path from X to Y
pos_path(N,X,Y,1) :-   pert(X),  obs_elabel(N,X,Y, 1), not pert(Y), both(Y).
pos_path(N,X,Y,D+1) :- pos_path(N,X,Z,D), obs_elabel(N,Z,Y, 1), not pert(Y), both(Y), 
                       not shorter_path(N,X,Y,D+1), D<20.                       
                       
pos_path(N,X,Y,D+1) :- neg_path(N,X,Z,D), obs_elabel(N,Z,Y,-1), not pert(Y), both(Y), 
                       not shorter_path(N,X,Y,D+1), D<20.
                       
% in network n exist a neg_path from X to Y
neg_path(N,X,Y,1) :-   pert(X),      obs_elabel(N,X,Y,-1), not pert(Y), both(Y).
neg_path(N,X,Y,D+1) :- neg_path(N,X,Z,D), obs_elabel(N,Z,Y, 1), not pert(Y), both(Y),
                       not shorter_path(N,X,Y,D+1), D<20.
neg_path(N,X,Y,D+1) :- pos_path(N,X,Z,D), obs_elabel(N,Z,Y,-1), not pert(Y), both(Y), 
                       not shorter_path(N,X,Y,D+1), D<20.
                       
shorter_path(N,X,Y,D+2) :- pos_path(N,X,Z,D), obs_elabel(N,Z,Y,_), not pert(Y), both(Y).
shorter_path(N,X,Y,D+2) :- neg_path(N,X,Z,D), obs_elabel(N,Z,Y,_), not pert(Y), both(Y).
shorter_path(N,X,Y,D+1) :- shorter_path(N,X,Y,D), D<20.


% Y gets a positive influence
getspos(N,Y) :- pert(X, 1), readout(Y), pos_path(N,X,Y,_).
getspos(N,Y) :- pert(X,-1), readout(Y), neg_path(N,X,Y,_).

% Y gets a negative influence
getsneg(N,Y) :- pert(X, 1), readout(Y), neg_path(N,X,Y,_).
getsneg(N,Y) :- pert(X,-1), readout(Y), pos_path(N,X,Y,_).


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

uneq2(am,1).
uneq2(am,0).
uneq2(am,-1).
uneq2(1,am).
uneq2(0,am).
uneq2(-1,am).


% check whether labelings are different
difflabel(1,N1,X,S1) :- vlabel(N1,X,S1), vlabel(N2,X,S2), N1!=N2, uneq(S1,S2), readout(X).
diff1(N1,N2)         :- vlabel(N1,X,S1), vlabel(N2,X,S2), N1<N2,  uneq(S1,S2), readout(X).
% countdiff1(Z)        :- Z = #count{diff1(N1,N2)}.

% check whether labelings MAYBE different
difflabel(1,N1,X,S1) :- vlabel(N1,X,S1), vlabel(N2,X,S2), N1!=N2, uneq2(S1,S2), readout(X).
diff2(N1,N2)         :- vlabel(N1,X,S1), vlabel(N2,X,S2), N1<N2,  uneq2(S1,S2), readout(X).
% countdiff2(Z)        :- Z = #count{diff2(N1,N2)}.

diff :- diff1(N1,N2).
diff :- diff2(N1,N2).
% every experiment must distinguish atleast 2 network classes
:- not diff.


% count eq classes
same(N1,N2)         :- net(N1), net(N2), N1<N2, not diff1(N1,N2), not diff2(N1,N2).
has_smaller_same(Y) :- same(X,Y).

notunique(X)        :- same(X,Y).
notunique(Y)        :- same(X,Y).

eqclass(X)          :- same(X,Y), not has_smaller_same(X).
eqclass(X)          :- net(X) , not notunique(X).
counteqclasses(Z)   :- Z = #count{eqclass(X)}.


% maximize differences
#maximize[ not false, diff1(N1,N2) @3 ].
#maximize[ not false, diff2(N1,N2) @2 ].
% minimize pertubations
#minimize[ false, pert(G) @1 ].
#hide.


pert(1,X,Y) :- pert(X,Y).
#show pert/3.
#show counteqclasses/1.
#show difflabel/4.

