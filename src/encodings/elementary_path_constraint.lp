
#begin_lua

function string:split( inSplitPattern, outResults )
  --print("split",self)
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


function strconc(l,x)
  local myString = tostring(l)..":"..tostring(x)
  local myset = myString:split(":")

  table.sort(myset)
  retstring = ""
  for i,n in ipairs(myset) do
    if n=="" then
            --    print("WHOOOPS   ",n)
    else
      retstring= retstring..":"..n
    end
  end
  return retstring
end

function str(x)
  local myString = tostring(x)
  local myset = myString:split(":")

  table.sort(myset)
  retstring = ""
  for i,n in ipairs(myset) do
    if n=="" then
            --    print("WHOOOPS   ",n)
    else
      retstring= retstring..":"..n
    end
  end
  return retstring
end


function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function member(x,l)
  local myString = tostring(l)
  local myset = myString:split(":")
  for i,n in ipairs(myset) do
 --   print(i,n)
    if n==tostring(x) then
      return 1
    else
      -- print("noteq")
    end
  end
  return 0
end

#end_lua.



% in a network exists under Condition E a positive path to X

pos_path(E,N,X,@str(X)) :- input(E,X), vlabel(E,N,X, 1).
neg_path(E,N,X,@str(X)) :- input(E,X), vlabel(E,N,X,-1).

pos_path(E,N,X,@strconc(P,X)) :- pos_path(E,N,Y,P),
                                 elabel(N,Y,X, 1), not input(E,X), X!=Y,
                                 0==@member(X,P).

neg_path(E,N,X,@strconc(P,X)) :- pos_path(E,N,Y,P),
                                 elabel(N,Y,X,-1), not input(E,X), X!=Y,
                                 0==@member(X,P).

pos_path(E,N,X,@strconc(P,X)) :- neg_path(E,N,Y,P),
                                 elabel(N,Y,X,-1), not input(E,X), X!=Y,
                                 0==@member(X,P).

neg_path(E,N,X,@strconc(P,X)) :- neg_path(E,N,Y,P),
                                 elabel(N,Y,X, 1), not input(E,X), X!=Y,
                                 0==@member(X,P).

pos_path(E,N,V) :- pos_path(E,N,V,P).
neg_path(E,N,V) :- neg_path(E,N,V,P).

forbidden(E,N,V, 1) :- exp(E), vertex(N,V), not pos_path(E,N,V), not input(E,V).
forbidden(E,N,V,-1) :- exp(E), vertex(N,V), not neg_path(E,N,V), not input(E,V).