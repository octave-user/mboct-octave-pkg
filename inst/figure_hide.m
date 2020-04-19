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
## @deftypefn {Function File} figure_hide(@var{ifig})
## Hide a list of figures identified by @var{ifig}
## @seealso{figure_show, figure_set_visible, figure_list}
## @end deftypefn

function figure_hide(ifig)
  if (nargin ~= 1)
    print_usage();
  endif
  
  figure_set_visible(ifig, "off");
endfunction

%!test
%! for i=1:2
%!   h(i) = figure("visible", "off");
%! endfor
%! figure_hide(h);
%! for i=1:numel(h)
%!   close(h(i));
%! endfor

%!demo
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_hide(hfig);
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
