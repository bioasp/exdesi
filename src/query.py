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
find_best_exp_sets_prg = root + '/encodings/find_best_experiment_sets.lp'
elem_path_prg          = root + '/encodings/shortest_elem_path.lp'

    
def get_best_single_experiments(nets,expvars):
  '''
  returns the experiments as a``TermSet`` object [instance].
  '''
  netsf    = nets.to_file()
  expvarsf = expvars.to_file()


  i = 1 #single experiment
    
  num_exp   = String2TermSet('pexperiment('+str(i)+')')
  num_expf  = num_exp.to_file()
  prg       = [ netsf, expvarsf, num_expf, find_best_exp_sets_prg ,
                elem_path_prg ]
  coptions  = '--project --opt-mode=optN --opt-strategy=0 --opt-heuristic'
  solver    = GringoClasp(clasp_options=coptions)
  solutions = solver.run(prg,collapseTerms=True,collapseAtoms=False)

  os.unlink(num_expf)      

  os.unlink(netsf)
  os.unlink(expvarsf)
  return solutions


def get_best_experiment_sets(nets,expvars,num,SP):
  '''
  given the network and the experimental variables, and the bound on the size of an experiment set
  returns the experiments as a``TermSet`` object [instance].
  '''
  netsf    = nets.to_file()
  expvarsf = expvars.to_file()

  best           = -1
  best_solutions = []
  best_found     = False

  i = 0
  while i < num and not best_found :
    i += 1
    
    num_exp   = String2TermSet('pexperiment('+str(i)+')')
    num_expf  = num_exp.to_file()
    prg       = [ netsf, expvarsf, num_expf, find_best_exp_sets_prg ,
                  elem_path_prg ]
    coptions  = '--project --opt-mode=optN --opt-strategy=0 --opt-heuristic'
    solver    = GringoClasp(clasp_options=coptions)
    solutions = solver.run(prg,collapseTerms=True,collapseAtoms=False)

    os.unlink(num_expf)      
    if solutions == []: best_found = True
    else:
      opt=(solutions[0].score[0]+solutions[0].score[1])
      if best == opt:
        best_found = True
      else:
        best           = opt
        best_solutions = solutions
        
  os.unlink(netsf)
  os.unlink(expvarsf)

  return best_solutions
    

