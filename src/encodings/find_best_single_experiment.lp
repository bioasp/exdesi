% vertex(N,X)           vertex X in network N
% obs_elabel(N,X,Y,S).  edge from X to Y with sign S in network N
% preadout(X).          possible readout in node X
% pperturb(X,S).        possible perturbed node X, S sign of perturbation
% done(E,X,S).          already performed experiment E, perturbe node X with sign S

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

% use number of vertices as upper bound for path length
countvertices(C)    :- C = #count{vertex(X)}.

% in network n exist a pos_path from X to Y
pos_path(N,gen(X),gen(Y), 1, @strconc(X,Y)) :- pert(gen(X)),  obs_elabel(N,gen(X),gen(Y), 1), not pert(gen(Y)), both(gen(Y)).
pos_path(N,X,gen(Y),D+1,@strconc(P,Y))      :- pos_path(N,X,Z,D,P), obs_elabel(N,Z,gen(Y), 1), not pert(gen(Y)), both(gen(Y)), 
                                            0==@member(Y,P), D<C, countvertices(C).                       
                       
pos_path(N,X,gen(Y),D+1,@strconc(P,Y))      :- neg_path(N,X,Z,D,P), obs_elabel(N,Z,gen(Y),-1), not pert(gen(Y)), both(gen(Y)), 
                                            0==@member(Y,P), D<C, countvertices(C).
                       
% in network n exist a neg_path from X to Y
neg_path(N,gen(X),gen(Y), 1, @strconc(X,Y)) :- pert(gen(X)), obs_elabel(N,gen(X),gen(Y),-1), not pert(gen(Y)), both(gen(Y)).
neg_path(N,X,gen(Y),D+1, @strconc(P,Y))     :- neg_path(N,X,Z,D,P), obs_elabel(N,Z,gen(Y), 1), not pert(gen(Y)), both(gen(Y)),
                                            0==@member(Y,P), D<C, countvertices(C).
                              
neg_path(N,X,gen(Y),D+1, @strconc(P,Y)) :- pos_path(N,X,Z,D,P), obs_elabel(N,Z,gen(Y),-1), not pert(gen(Y)), both(gen(Y)), 
                                           0==@member(Y,P), D<C, countvertices(C).
                       

#begin_lua

function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end


function strconc(x,y)
  return tostring(x)..":"..tostring(y)
end


function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function member(x,l)
  local myString = tostring(l)
  local myset = Set(myString:split(":"))
  if myset[x] then 
    return 1
  else 
    return 0
  end
end

#end_lua.



% Y gets a positive influence
getspos(N,Y) :- pert(X, 1), readout(Y), pos_path(N,X,Y,_,P).
getspos(N,Y) :- pert(X,-1), readout(Y), neg_path(N,X,Y,_,P).

% Y gets a negative influence
getsneg(N,Y) :- pert(X, 1), readout(Y), neg_path(N,X,Y,_,P).
getsneg(N,Y) :- pert(X,-1), readout(Y), pos_path(N,X,Y,_,P).


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

