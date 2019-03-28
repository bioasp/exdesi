---
layout: index
title: ExDesi
tagline: Designing optimal experiments to discriminate interaction graph models
---

### Experiment Planning using Sign Consistency on Influence Graphs

Modern methods for the inference of cellular networks from experimental data
often express nondeterminism by proposing an ensemble of candidate models with
similar properties.
To further discriminate among these model candidates, and to find the biological
truth, new experiments need to be carried out.
The goal of optimal experiment design is to determine those experiments that
discriminate most of the candidates while minimizing the costs.
Building upon a notion of consistency between biochemical/genetic regulations
and high-throughput profiles of cell activity,
ExDesi implements an approach for experiment planning with interaction graph models
and sign consistency methods.
ExDesi can be used in combination with methods for network inference and consistency checking
to compute experiments which are most suitable to deliver results that allow a refinement of the model. 

### Installation

You can install exdesi by running:

	$ pip install --user exdesi

On Linux the executable scripts can then be found in ``~/.local/bin``

and on Mac OS the scripts are under ``/Users/YOURUSERNAME/Library/Python/3.5/bin``.


### Usage

Typical usage is:

	$ exdesi.py candidate_directory experimental_variables_file

For more options you can ask for help as follows:

	$ exdesi.py -h
	usage: exdesi.py [-h] [--best_set BEST_SET] [-x EXCLUDE]
                 networkfiles experivarfile

	positional arguments:
	  networkfiles          directory of influence graphs in SIF format
	  experivarfile         experimental variables

	optional arguments:
	  -h, --help            show this help message and exit
	  --best_set BEST_SET   compute best set of experiments maximal number of
	                        experiments, default is OFF, 0=unlimited
	  -x EXCLUDE, --exclude EXCLUDE
	                        exclude experiments described in file EXCLUDE



### Example

Sample files available in the [git repository](https://github.com/bioasp/exdesi/tree/master/data).

A sample call would be:

	$ exdesi.py in_silico_HEK293/candidates_round1/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude1.txt


### Related publications
* [*Designing optimal experiments to discriminate interaction graph models*](https://doi.org/10.1109/TCBB.2018.2812184),
IEEE/ACM Trans. Comput. Biol. Bioinform, preprint.

* [*Extended notions of sign consistency to relate experimental data to signaling and regulatory network topologies*](http://dx.doi.org/10.1186/s12859-015-0733-7),
  BMC Bioinformatics, 2015.

* [*Repair and Prediction (under Inconsistency) in Large Biological Networks with Answer Set Programming*](http://aaai.org/ocs/index.php/KR/KR2010/paper/view/1334/1660),
  12th International Conference on the Principles of Knowledge Representation and Reasoning, 2010.

* [*Detecting Inconsistencies in Large Biological Networks with Answer Set Programming*](http://dx.doi.org/10.1007/978-3-540-89982-2_19),
  Theory and Practice of Logic Programming, 2011.


### FAQ

**Q**: I don't have pip. How can I install pip without admin rights?

**A**: To install pip without admin rights:

1. Download [getpip.py](https://raw.github.com/pypa/pip/master/contrib/get-pip.py).

		$ wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py

2. Install pip locally. 

		$ python get-pip.py --user

3. You can install using your local pip.


**Q**: How can I write the output of exdesi into a file?

**A**: You can redirect the output of exdesi into a file using ``>``. For example to write the results into the file ``myfile.txt`` type:

	$ exdesi.py network.sif observation.obs --show_labelings 10 --show_predictions > myfile.txt

	
