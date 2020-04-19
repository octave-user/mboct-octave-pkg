## Copyright (C) 2018(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} struct_sizeof(@var{s})
## @deftypefnx {} struct_sizeof(@var{s}, @var{fd})
## Print a report for memory usage of variable @var{s} to file descriptor @var{fd} or to stdout.
## @end deftypefn

function struct_sizeof(s, fd)
  if (nargin < 1 || nargin > 2)
    print_usage();
  endif

  if (nargin < 2)
    fd = stdout;
  endif

  print_sizeof(s, inputname(1), 0, fd);
endfunction

function print_sizeof(s, prefix, level, fd)
  if (isstruct(s))
    fn = fieldnames(s);
    
    for i=1:numel(s)
      if numel(s) > 1
        idx_str = sprintf("(%d)", i);
      else
        idx_str = "";
      endif
      
      for j=1:numel(fn)
        print_sizeof(getfield(s(i), fn{j}), [prefix, idx_str, ".", fn{j}], level + 1, fd);
      endfor
      print_level(level, fd);
      fprintf(fd, "sizeof(%s)=%.6fMb\n", [prefix, idx_str], sizeof(s(i)) / 2^20);
    endfor
    print_level(level, fd);
    fprintf(fd, "sizeof(%s)=%.6fMb\n", prefix, sizeof(s) / 2^20);
  else
    print_level(level, fd);
    fprintf(fd, "sizeof(%s)=%.6fMb\n", prefix, sizeof(s) / 2^20);
  endif
endfunction

function print_level(level, fd)
  for i=1:level
    fputs(fd, " ");
  endfor
endfunction

%!demo
%! s1(1).x = 1;
%! s1(2).x = 2;
%! s1(1).y.z = rand(3, 3);
%! s1(2).y.z = rand(3, 100);
%! s1(1).y.v = "1234";
%! s1(2).y.v = "56478";
%! s1(1).y.w = zeros(2^10, 2^10, "int8");
%! s1(2).y.w = zeros(2 * 2^10, 2^10, "int8");
%! s1(2).y.s2 = s1;
%! struct_sizeof(s1);

%!error struct_sizeof()
%!error struct_sizeof(1,2,3)
