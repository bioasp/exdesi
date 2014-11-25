%choose experimental setting
{pert(G,S)} :- pperturb(G,S). 
{readout(G)} :- preadout(G). 

pert(G) :- pert(G,S).

% choose labeling
1{vlabel(NET,G,-1), vlabel(NET,G,0), vlabel(NET,G,1), vlabel(NET,G,undef)}1 :- vertex(NET,G).

vlabel(N,G,1) :- vertex(N,G), pert(G,1).
vlabel(N,G,-1):- vertex(N,G), pert(G,-1).
vlabel(N,G,0) :- vertex(N,G), pert(G,0).


infl(N,G,1)  :- obs_elabel(N,A,G,1), vlabel(N,A,1).
infl(N,G,-1)  :- obs_elabel(N,A,G,-1), vlabel(N,A,1).

infl(N,G,-1)  :- obs_elabel(N,A,G,1), vlabel(N,A,-1).
infl(N,G,1)  :- obs_elabel(N,A,G,-1), vlabel(N,A,-1).

infl(N,G,-1) :- edge(N,A,G), vlabel(N,A,undef).
infl(N,G,1)  :- edge(N,A,G), vlabel(N,A,undef).


vlabel(N,G,undef) :- infl(N,G,1), infl(N,G,-1), not pert(G).
vlabel(N,G,1) :- infl(N,G,1), not infl(N,G,-1), not pert(G).
vlabel(N,G,-1) :- infl(N,G,-1), not infl(N,G,1), not pert(G).
vlabel(N,G,0) :- vertex(N,G), not infl(N,G,-1), not infl(N,G,1), not pert(G).


difflabel(N1,G,S1) :- readout(G), vlabel(N1,G,S1), vlabel(N2,G,S2), N1!=N2,S1!=S2.
diff(N1,N2) :- difflabel(N1,G,S1), difflabel(N2,G,S2), N1<N2, S1!=S2.
diff :- diff(N1,N2).
:- not diff.


#hide.
#show diff/2.
#show pert/2.
#show readout/1.
#show difflabel/3.



