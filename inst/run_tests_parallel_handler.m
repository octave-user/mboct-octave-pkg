## Copyright (C) 2016(-2025) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} @var{status} = run_tests_parallel_handler(@var{idx}, @var{pkg_files})
## Execute Octave's test function in parallel
## @seealso{run_tests_parallel}
## @end deftypefn

function status = run_tests_parallel_handler(idx, pkg_files)
  printf("%d:%s\n", idx, pkg_files{idx});
  [status.N, status.NMAX] = test(pkg_files{idx});
endfunction
