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

from setuptools import setup
                         
setup(
  name             = 'expidesi',
  version          = '0.2',
  url              = 'http://bioasp.github.io/expidesi/',
  license          = 'GPLv3+',
  description      = 'Design experiments to differentiate interaction graph '
                     'models.',
  long_description = open('README.rst').read(),
  author           = 'Sven Thiele',
  author_email     = 'sthiele78@gmail.com',
  packages         = ['__expidesi__'],
  package_dir      = {'__expidesi__' : 'src'},
  package_data     = {'__expidesi__' : ['encodings/*.lp','encodings/*.gringo']},
  scripts          = ['expidesi.py'],
  install_requires = ['pyasp == 1.4.2']
)
