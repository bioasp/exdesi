This folder contains the input data used for planning the experiments presented in
"Designing optimal experiments to discriminate interaction graph models".

The following calls were used to plan the presented in silico experiments:

#1
 exdesi.py in_silico_HEK293/candidates_round1/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude1.txt

#2
 exdesi.py in_silico_HEK293/candidates_round2/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude2.txt

#3
 exdesi.py in_silico_HEK293/candidates_round3/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude3.txt

Step 3 returns no experiments. We therfore increase the possible perturbations in step 4.

#4
 exdesi.py in_silico_HEK293/candidates_round3/ in_silico_HEK293/expvars_total.txt -x in_silico_HEK293/exclude3.txt


The following calls were used to plan the presented in vivo experiments:

#1
 exdesi.py in_vivo_HEK293/candidates_round1/ in_vivo_HEK293/expvars_ohne_gabMutanten.txt

#2
 exdesi.py in_vivo_HEK293/candidates_round2/ in_vivo_HEK293/expvars_ohne_gabMutanten.txt

