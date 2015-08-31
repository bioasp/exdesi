
%% compute labeling

both(X,N) :- to_preadout(X,N),pinfluenced(X,N).

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
pos_path(N,gen(X),gen(Y)) :- 
	pert(gen(X)), obs_elabel(N,gen(X),gen(Y),1), not pert(gen(Y)),
       	both(gen(Y),N).
pos_path(N,X,gen(Y))      :-
       	pos_path(N,X,Z), obs_elabel(N,Z,gen(Y), 1), not pert(gen(Y)),
       	both(gen(Y),N).                       
                       
pos_path(N,X,gen(Y))      :- 
	neg_path(N,X,Z), obs_elabel(N,Z,gen(Y),-1), not pert(gen(Y)), 
	both(gen(Y),N).
                       
% in network n exist a neg_path from X to Y
neg_path(N,gen(X),gen(Y)) :-
       	pert(gen(X)), obs_elabel(N,gen(X),gen(Y),-1), not pert(gen(Y)),
       	both(gen(Y),N).
neg_path(N,X,gen(Y))     :- 
	neg_path(N,X,Z), obs_elabel(N,Z,gen(Y), 1), not pert(gen(Y)), 
	both(gen(Y),N).
                              
neg_path(N,X,gen(Y)) :-
	pos_path(N,X,Z), obs_elabel(N,Z,gen(Y),-1), not pert(gen(Y)),
       	both(gen(Y),N).
                       

% Y gets a positive influence
getspos(N,Y) :- pert(X, 1), readout(Y), pos_path(N,X,Y).
getspos(N,Y) :- pert(X,-1), readout(Y), neg_path(N,X,Y).

% Y gets a negative influence
getsneg(N,Y) :- pert(X, 1), readout(Y), neg_path(N,X,Y).
getsneg(N,Y) :- pert(X,-1), readout(Y), pos_path(N,X,Y).


