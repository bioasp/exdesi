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
import re
from pyasp.asp import *
from pyasp.misc import *

import pyasp.ply.lex as lex
import pyasp.ply.yacc as yacc

import __expidesi__.sif_parser as sif_parser

def parse_val(s):
    if s == '+': return '1'
    elif s == '-': return '-1'
    elif s == '0': return '0'
    elif s == 'nc': return '0'
    elif s == 'notPlus': return 'notPlus'    
    elif s == 'notMinus': return 'notMinus'        
    elif s == 'input': return 'input'
    elif s == 'readout': return 'readout'
    else: 
        print(s)
        assert(False)


def readSIFGraph(filename):
    p = sif_parser.Parser(filename)
    """
    input: string, name of a file containing a Bioquali-like graph description
    output: asp.TermSet, with atoms matching the contents of the input file
    
    Parses a Bioquali-like graph description, and returns
    a TermSet object.
    Written using original Bioquali
    """

    accu = TermSet()
    file = open(filename,'r')
    s = file.readline()
    while s!="":
        try:
            accu = p.parse(s)
        except EOFError:
            break
        s = file.readline()

    return accu



def readProfile(filename):
    GENE_ID = '[-a-zA-Z0-9_:\(\)/]+'
    VAL = '(-|\+|0|nc|readout|input|notPlus|notMinus)'
    file = open(filename,'r')
    val_re = '(?P<genid>'+GENE_ID+')(\s)*=(\s)*(?P<sign>'+VAL+')'
    val = re.compile(val_re)
    line_number = 1
    line = file.readline()
    accu = TermSet()
    while line:
        vm = val.match(line)
        if vm:
            if parse_val(vm.group('sign'))=='readout':
              vertex = quote(vm.group('genid'))
              accu.add(Term('preadout',["gen("+vertex+")"]))
            else:
              vertex = quote(vm.group('genid'))
              accu.add(Term('pperturb',["gen("+vertex+")", parse_val(vm.group('sign'))]))
        else:
            print('Syntax error line:', line_number, ':', line)
        line = file.readline()
        line_number+=1
    return accu


