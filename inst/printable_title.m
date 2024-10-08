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
## @deftypefn {Function File} @var{s_out} = printable_title(@var{s_in})
## Prepare a string to be displayed in a figure (e.g. without underscores)
## @end deftypefn

function s_out = printable_title(s_in)
  if (nargin ~= 1)
    print_usage();
  endif
  
  s_out = s_in;
  s_out(find(s_out == '_')) = ' ';
endfunction

%!error
%! error("this test must always fail");
