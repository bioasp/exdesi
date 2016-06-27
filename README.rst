Installation
------------


You can install exdesi by running::

	$ pip install --user exdesi

On Linux the executable scripts can then be found in ``~/.local/bin``
and on MacOS the scripts are under ``/Users/YOURUSERNAME/Library/Python/3.2/bin``.



Usage
-----

Typical usage is::

	$ exdesi.py candidate_directory experimental_variables_file
	
For more options you can ask for help as follows::

	$ exdesi.py -h
	usage: exdesi.py [-h] [--best_set BEST_SET] [-x EXCLUDE] networkfiles experivarfile

	positional arguments:
	  networkfiles          directory of influence graphs in SIF format
	  experivarfile         experimental variables

	optional arguments:
	  -h, --help            show this help message and exit
	  --best_set BEST_SET   compute best set of experiments maximal number of
	                        experiments, default is OFF, 0=unlimited
	  -x EXCLUDE, --exclude EXCLUDE
	                        exclude experiments described in file EXCLUDE


Example
-------
Sample files available in the data_ directory.
A sample call would be::

        $ exdesi.py in_silico_HEK293/candidates_round1/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude1.txt

.. _data: https://github.com/bioasp/exdesi/tree/master/data


