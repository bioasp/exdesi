# Copyright (c) 2014, Sven Thiele <sthiele78@gmail.com>
#
# This file is part of exdesi.
#
# exdesi is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# exdesi is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with exdesi.  If not, see <http://www.gnu.org/licenses/>.
# -*- coding: utf-8 -*-
import os


def print_experiment_table(experimental_design) :

  nets         = set()
  readouts     = set()
  experiments  = set()
  classes      = 0
  pertubations = []
  difftables2  = dict()
  for a in experimental_design:
    if a.pred() == "counteqclasses" :
      classes = a.arg(0)
    if a.pred() == "pert" : # pert(E,G,S)
      pertubations.append((a.arg(0),a.arg(1),a.arg(2)))
    if a.pred() == "difflabel" :
      experiment = a.arg(0)
      net        = a.arg(1)
      readout    = a.arg(2)
      sign       = a.arg(3)
      experiments.add(experiment)
      nets.add(net)
      readouts.add((experiment,readout))
      #print('add:',experiment,net,readout,sign)
      difftables2[(experiment,net,readout)] = sign
  lo_nets        = sorted(list(nets))
  lo_readouts    = list(readouts)
  lo_experiments = list(experiments)
  lo_experiments.sort()
  print('We can differentiate',classes,'classes of networks with',len(experiments),'experiments.')

  for e in lo_experiments :
    print ('experiment',e,': ',end='')
    for p in pertubations:
      if p[0]==e : print (p[1],'=',p[2],end=', ')
    print ('')
  print ('')

  #print prediction table header
  for e in lo_experiments : print ('experiment',e,end=' | ')
  print ('')
  for e in lo_experiments:
    for r in lo_readouts :
      if r[0]==e : print (r[1],end=' ')
    print ('| ',end='')
  print('Network')

  #print prediction table content
  rows = []
  for n in lo_nets :
    row = []
    for e in lo_experiments:
      for r in lo_readouts :
        if r[0]==e : row.append(difftables2[(e,n,r[1])])
      row.append('|')
    row.append(n)
    rows.append(row)

  rows.sort()
  for r in rows :
    for e in r :
      if e == "1"   : print("  1 ",end='')
      elif e == '0' : print("  0 ",end='')
      elif e == "|" : print("|",end='')
      else: print('',e,'',end='')
    print('')


def clean_up() :
  if os.path.isfile("parser.out")              : os.remove("parser.out")
  if os.path.isfile("asp_py_lextab.py")        : os.remove("asp_py_lextab.py")
  if os.path.isfile("asp_py_lextab.pyc")       : os.remove("asp_py_lextab.pyc")
  if os.path.isfile("asp_py_parsetab.py")      : os.remove("asp_py_parsetab.py")
  if os.path.isfile("asp_py_parsetab.pyc")     : os.remove("asp_py_parsetab.pyc")
  if os.path.isfile("graph_parser_lextab.py")  : os.remove("graph_parser_lextab.py")
  if os.path.isfile("graph_parser_parsetab.py"): os.remove("graph_parser_parsetab.py")
  if os.path.isfile("parsetab.py")             : os.remove("parsetab.py")
  if os.path.isfile("parsetab.pyc")            : os.remove("parsetab.pyc")
  if os.path.isfile("sif_parser_lextab.py")    : os.remove("sif_parser_lextab.py")
  if os.path.isfile("sif_parser_lextab.pyc")   : os.remove("sif_parser_lextab.pyc")
