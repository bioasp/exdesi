# Copyright (c) 2014, Sven Thiele <sthiele78@gmail.com>
#
# This file is part of expidesi.
#
# expidesi is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# expidesi is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with expidesi.  If not, see <http://www.gnu.org/licenses/>.

# -*- coding: utf-8 -*-

"""
This module contains the queries which can be asked to the model and data.

"""
import os
import tempfile
from pyasp.asp import *

root = __file__.rsplit('/', 1)[0]
find_exp_prg   =	root +'/encodings/find_experiment.lp'

def get_experiments(nets,expvars):
    '''
    returns the experiments as a``TermSet`` object [instance].
    '''
    netsf = nets.to_file('nets.lp')
    expvarsf = expvars.to_file('expvars.lp')
    #exit()
    prg = [netsf,expvarsf, find_exp_prg]
    coptions = '--opt-mode=optN '
    solver = GringoClasp(clasp_options=coptions)
    solutions = solver.run(prg,collapseTerms=True,collapseAtoms=False)
    
    os.unlink(netsf)
    os.unlink(expvarsf)
    return solutions
    