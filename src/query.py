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
heu_prg   =        root +'/encodings/heuristic.lp'

def get_experiments(nets,expvars,num):
    '''
    returns the experiments as a``TermSet`` object [instance].
    '''
    netsf = nets.to_file('nets.lp')
    expvarsf = expvars.to_file('expvars.lp')
    best=-1
    best_solutions=[]
    best_found=False
    i=0
    while i < num and not best_found :
      i += 1
      num_exp = String2TermSet('pexperiment('+str(i)+')')
      num_expf = num_exp.to_file('num_exp.lp')
      #exit()
      #prg = [netsf,expvarsf,num_expf, find_exp_prg,heu_prg ]
      #coptions = '--opt-mode=optN --dom-mod=6 --heu=Domain'

      prg = [netsf,expvarsf,num_expf, find_exp_prg ]
      coptions = '--opt-mode=optN'
      #coptions = '--opt-mode=optN --opt-strategy=5'
      
      solver = GringoClasp(clasp_options=coptions)
      solutions = solver.run(prg,collapseTerms=True,collapseAtoms=False)

      #print(solutions[0].score[1])
      
      if solutions == []: best_found=True
      else:
        #print(solutions)
        #print("\n",solutions[0].score[0])
        opt=solutions[0].score[0]
        if best == opt:
          best_found=True
        else:
          best = opt
          best_solutions=solutions
          
      #print(i,opt,best,best_found)

    os.unlink(netsf)
    os.unlink(expvarsf)
    os.unlink(num_expf)
    return best_solutions




#def get_experiments(nets,expvars):
    #'''
    #returns the experiments as a``TermSet`` object [instance].
    #'''
    #netsf = nets.to_file('nets.lp')
    #expvarsf = expvars.to_file('expvars.lp')
    ##exit()
    #prg = [netsf,expvarsf, find_exp_prg]
    #coptions = '--opt-mode=optN '
    #solver = GringoClasp(clasp_options=coptions)
    #solutions = solver.run(prg,collapseTerms=True,collapseAtoms=False)
    
    #os.unlink(netsf)
    #os.unlink(expvarsf)
    #return solutions
    