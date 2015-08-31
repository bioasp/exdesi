
%% compute getspos getsneg

both(X,N) :- pinfluenced(X,N), to_preadout(X,N).

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

% use number of vertices as upper bound for path length
countvertices(C)    :- C = #count{vertex(X)}.

% in network n exist a pos_path from X to Y
pos_path(E,N,gen(X),gen(Y),1, @strconc(X,Y)) :-
       	pert(E,gen(X)), obs_elabel(N,gen(X),gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N).
pos_path(E,N,X,gen(Y), D+1,@strconc(P,Y))    :-
       	pos_path(E,N,X,Z,D,P), obs_elabel(N,Z,gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N),
	0==@member(Y,P), D<C, countvertices(C).     
                          
pos_path(E,N,X,gen(Y), D+1,@strconc(P,Y))    :-
       	neg_path(E,N,X,Z,D,P), obs_elabel(N,Z,gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N),
	0==@member(Y,P), D<C, countvertices(C).
                       
% in network n exist a neg_path from X to Y
neg_path(E,N,gen(X),gen(Y),1, @strconc(X,Y)) :-
       	pert(E,gen(X)), obs_elabel(N,gen(X),gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N).
neg_path(E,N,X,gen(Y), D+1,@strconc(P,Y))    :-
       	neg_path(E,N,X,Z,D,P), obs_elabel(N,Z,gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N),
	0==@member(Y,P), D<C, countvertices(C).
                          
neg_path(E,N,X,gen(Y), D+1,@strconc(P,Y))    :-
       	pos_path(E,N,X,Z,D,P), obs_elabel(N,Z,gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N),
	0==@member(Y,P), D<C, countvertices(C).

% Y gets a positive influence
getspos(E,N,Y) :- pert(E,X, 1), readout(E,Y), pos_path(E,N,X,Y,_,P).
getspos(E,N,Y) :- pert(E,X,-1), readout(E,Y), neg_path(E,N,X,Y,_,P).

% Y gets a negative influence
getsneg(E,N,Y) :- pert(E,X, 1), readout(E,Y), neg_path(E,N,X,Y,_,P).
getsneg(E,N,Y) :- pert(E,X,-1), readout(E,Y), pos_path(E,N,X,Y,_,P).


