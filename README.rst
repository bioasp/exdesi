Installation
------------


You can install exdesi by running::

	$ pip install --user exdesi

On Linux the executable scripts can then be found in ``~/.local/bin``



Usage
-----

Typical usage is::

	$ exdesi.py [-h] [--best_set BEST_SET] [-x EXCLUDE] networkfiles experivarfile

For more options you can ask for help as follows::

	$ exdesi.py -h



Example
-------
Sample files available in the data_ directory.
A sample call would be::
        $ exdesi.py in_silico_HEK293/candidates_round2/ in_silico_HEK293/expvars.txt -x in_silico_HEK293/exclude1.txt

.. _data: https://github.com/bioasp/exdesi/tree/master/data


