
%% compute getspos getsneg

both(X,N) :- pinfluenced(X,N), to_preadout(X,N).

% in network n exist a pos_path from X to Y
pos_path(E,N,gen(X),gen(Y)) :-
       	pert(E,gen(X)), obs_elabel(N,gen(X),gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N).
pos_path(E,N,X,gen(Y))    :-
       	pos_path(E,N,X,Z), obs_elabel(N,Z,gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N).     
                          
pos_path(E,N,X,gen(Y))    :-
       	neg_path(E,N,X,Z), obs_elabel(N,Z,gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N).
                       
% in network n exist a neg_path from X to Y
neg_path(E,N,gen(X),gen(Y)) :-
       	pert(E,gen(X)), obs_elabel(N,gen(X),gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N).
neg_path(E,N,X,gen(Y))    :-
       	neg_path(E,N,X,Z), obs_elabel(N,Z,gen(Y), 1), not pert(E,gen(Y)),
       	both(gen(Y),N).
                          
neg_path(E,N,X,gen(Y))    :-
       	pos_path(E,N,X,Z), obs_elabel(N,Z,gen(Y),-1), not pert(E,gen(Y)),
       	both(gen(Y),N).

% Y gets a positive influence
getspos(E,N,Y) :- pert(E,X, 1), readout(E,Y), pos_path(E,N,X,Y).
getspos(E,N,Y) :- pert(E,X,-1), readout(E,Y), neg_path(E,N,X,Y).

% Y gets a negative influence
getsneg(E,N,Y) :- pert(E,X, 1), readout(E,Y), neg_path(E,N,X,Y).
getsneg(E,N,Y) :- pert(E,X,-1), readout(E,Y), pos_path(E,N,X,Y).


