## Copyright (C) 2015(-2020) Reinhard <octave-user@a1.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} exec_test(@var{filename})
## @deftypefnx {} exec_test(@var{filename}, @var{index})
## @deftypefnx {} exec_test(@var{filename}, @var{index}, @var{first_line})
## Execute a test from a function file within the global context and leave all variables in place.
## @end deftypefn

function status = exec_test(filename, index, first_line)
  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (nargin < 2)
    index = 1;
  endif

  if (nargin < 3)
    first_line = 1;
  endif

  status = exec_demo(filename, index, first_line, 'test');
  
  if (0 == status)
    fprintf(stderr, "test %d passed\n", index);
  else
    fprintf(stderr, "test %d failed\n", index);
  endif
endfunction

