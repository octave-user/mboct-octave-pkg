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
## @deftypefn {Function File} figure_list()
## Print a list of all figures (visible or invisible)
## @seealso{figure_show, figure_hide, figure_set_visible}
## @end deftypefn

function figure_list()
  if (nargin ~= 0)
    print_usage();
  endif
  
  figures = sort(get(0, "children"));

  fprintf(stderr, "list of figures:\n");
  
  for i=1:length(figures)
    fprintf(stderr, "\t%d: %s\n", i, get(get(get(figures(i),"currentaxes"),"title"),"string"));
  endfor
  
  fprintf(stderr, "\ttype figure_show(1) to figure_show figure 1 ...\n");
endfunction

%!demo
%! x = linspace(0, 2 * pi, 10);
%! y = [sin(x); cos(x); tanh(x)];
%! hfig = [];
%! for i=1:rows(y)
%!   hfig(end + 1) = figure("visible", "off");
%!   plot(x, y(i, :), sprintf("-;y%d(x);%d", i, i));
%!   title(sprintf("function y%d(x)", i));
%! endfor
%! figure_list();
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
