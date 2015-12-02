#!python
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
# along with iggy.  If not, see <http://www.gnu.org/licenses/>.
# -*- coding: utf-8 -*-
import sys
import argparse
from pyasp.asp import *
from __expidesi__ import query, utils, bioquali

if __name__ == '__main__':

  parser = argparse.ArgumentParser()
  parser.add_argument("networkfiles",
    help="directory of influence graphs in SIF format")
  parser.add_argument("experivarfile",
    help="experimental variables")
                      
  parser.add_argument("-x", "--exclude",
    help="exclude experiments described in file EXCLUDE")

  #parser.add_argument('--use_some_path',
    #help='compute depmat using some path semantic instead of shortest '
         #'elementary path, default is OFF',
    #action="store_true")

  args = parser.parse_args()


  print('Using elementary path semantic: an influence is '
        'received if an elementary path from the perturbation '
        'to the readout exists.')
  
  net_dir    = args.networkfiles
  exp_string = args.experivarfile

  flist      = os.listdir(net_dir)
  NETS       = TermSet()
  print('\nReading',len(flist),'network from',net_dir,'...',end='\n')
  for f in flist :
    net_string = os.path.join(net_dir,f)
    print ('   reading',net_string,'... ',end='')
    net  = bioquali.readSIFGraph(net_string)
    NETS = TermSet(NETS.union(net))
    print('done.')


  print('\nReading experimental variables',exp_string, '...',end='')
  mu = bioquali.readExpVar(exp_string)
  print('done.')
  #print(mu)

  if (args.exclude) :
    print('\nReading excluded experiments',args.exclude, '...',end='')
    exclude = bioquali.readExcludedExp(args.exclude)
    print('done.')
    #print(exclude)
    
    MU = TermSet(mu.union(exclude))
  else : MU = mu

  print('\nCompute best single experiment ...',end='')
  experiments = query.get_best_single_experiments(NETS, MU)
  print('done.')

  if experiments == [] :
    print("no experiment can distinguish the networks.")
    print("add more readouts or more perturbations.")

  else:
    count = 0
    for e in experiments :
      count = count+1
      print("best single experiment",count,":")
      utils.print_experiment_table(e)
  
    print('\nCompute best experiment sets (max card 10) ...',end='')
    max_number_experiments = 10
    experiments = query.get_best_experiment_sets(NETS,MU,max_number_experiments)
    print('done.')

    count = 0
    for e in experiments :
      count = count+1
      print("best experiment set",count,":")
      utils.print_experiment_table(e)

  utils.clean_up()



