%choose experimental setting
{pert(G,S)} :- pperturb(G,S). 
{readout(G)} :- preadout(G). 



pert(G) :- pert(G,S).

% choose labeling
1{vlabel(NET,G,-1), vlabel(NET,G,0), vlabel(NET,G,1), vlabel(NET,G,undef)}1 :- vertex(NET,G).

vlabel(N,G,1) :- vertex(N,G), pert(G,1).
vlabel(N,G,-1):- vertex(N,G), pert(G,-1).
vlabel(N,G,0) :- vertex(N,G), pert(G,0).


infl(N,G,1)  :- obs_elabel(N,A,G,1),  vlabel(N,A,1).
infl(N,G,1)  :- obs_elabel(N,A,G,-1), vlabel(N,A,-1).
infl(N,G,1)  :- edge(N,A,G), vlabel(N,A,undef).

infl(N,G,-1) :- obs_elabel(N,A,G,-1), vlabel(N,A,1).
infl(N,G,-1) :- obs_elabel(N,A,G,1),  vlabel(N,A,-1).
infl(N,G,-1) :- edge(N,A,G), vlabel(N,A,undef).

:- vlabel(N,G,0),     not pert(G), infl(N,G,S).
:- vlabel(N,G,1),     not pert(G), not infl(N,G,1).
:- vlabel(N,G,1),     not pert(G), infl(N,G,-1).
:- vlabel(N,G,-1),    not pert(G), not infl(N,G,-1).
:- vlabel(N,G,-1),    not pert(G), infl(N,G,1).
:- vlabel(N,G,undef), not pert(G), not infl(N,G,1).
:- vlabel(N,G,undef), not pert(G), not infl(N,G,-1).


difflabel(N1,G,S1) :- readout(G), vlabel(N1,G,S1), vlabel(N2,G,S2), N1!=N2,S1!=S2.
diff(N1,N2) :- difflabel(N1,G,S1), difflabel(N2,G,S2), N1<N2, S1!=S2.
diff :- diff(N1,N2).
:- not diff.


#hide.
% #show diff/2.
#show pert/2.
#show readout/1.
% #show vlabel/3.
#show difflabel/3.



% founded(N,X) :- vlabel(N,X,S), pert(X,S).
% founded 1
founded(N,X) :- vlabel(N,X, 1), getspos(N,X).
% founded -1
founded(N,X) :- vlabel(N,X,-1), getsneg(N,X).
% founded undef
founded(N,X) :- vlabel(N,X,undef), getspos(N,X), getsneg(N,X).

getspos(N,X) :- vertex(N,X), pert(X,1).
getspos(N,X) :- getspos(N,Y), not pert(X), obs_elabel(N,Y,X,1).
getspos(N,X) :- getsneg(N,Y), not pert(X), obs_elabel(N,Y,X,-1).

getsneg(N,X) :- vertex(N,X), pert(X,-1).
getsneg(N,X) :- getsneg(N,Y), not pert(X), obs_elabel(N,Y,X,1).
getsneg(N,X) :- getspos(N,Y), not pert(X), obs_elabel(N,Y,X,-1).


:- vlabel(N,X, 1), not founded(N,X).
:- vlabel(N,X,-1), not founded(N,X).
:- vlabel(N,X,undef), not founded(N,X).


%maximize differences
#maximize[ not false = 0, diff(X,Y) @ 1 ].