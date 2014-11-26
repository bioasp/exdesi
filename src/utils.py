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
import os


def print_experiment_table(experiment) :

    nets = set()
    readouts = set()
    tab = dict()
    for a in experiment:
      #print(a)
      if a.pred() == "pert" :
        print('set',a.arg(0),'=',a.arg(1))
      if a.pred() == "difflabel" :
        nets.add(a.arg(0))
        readouts.add(a.arg(1))
        p = (a.arg(0),a.arg(1))
        val = a.arg(2)
        tab[p]=val
    lo_nets = sorted(list(nets))
    lo_readouts = list(readouts)
    print('Network',end='')
    for r in lo_readouts :
      print ('|',r,end='')
    print ('')
    for n in lo_nets:
      print(n,'\t',end='')
      for r in lo_readouts :
        print ('|',tab[(n,r)],end='')
      print ('')
      


def clean_up() :
  if os.path.isfile("parser.out"): os.remove("parser.out")
  if os.path.isfile("asp_py_lextab.py"): os.remove("asp_py_lextab.py")
  if os.path.isfile("asp_py_lextab.pyc"): os.remove("asp_py_lextab.pyc")
  if os.path.isfile("asp_py_parsetab.py"): os.remove("asp_py_parsetab.py")
  if os.path.isfile("asp_py_parsetab.pyc"): os.remove("asp_py_parsetab.pyc")
  if os.path.isfile("graph_parser_lextab.py"): os.remove("graph_parser_lextab.py")
  if os.path.isfile("graph_parser_parsetab.py"): os.remove("graph_parser_parsetab.py")
  if os.path.isfile("parsetab.py"): os.remove("parsetab.py")
  if os.path.isfile("parsetab.pyc"): os.remove("parsetab.pyc")
  if os.path.isfile("sif_parser_lextab.py"): os.remove("sif_parser_lextab.py")
  if os.path.isfile("sif_parser_lextab.pyc"): os.remove("sif_parser_lextab.pyc")
