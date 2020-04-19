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
## @deftypefn {Function File} figure_show(@var{ifig})
## @deftypefnx {} figure_show(@var{ifig}, @var{toolkit})
## Make hidden figures, identified by <@var{ifig}>, visible and optionally select the graphics toolkit for it.
##
## @var{ifig} @dots{} Array of figure handles
##
## @var{toolkit} @dots{} String name of the graphics toolkit to be selected for figure <@var{ifig}>.
##
## @seealso{figure_hide, figure_list, figure_set_visible}
## @end deftypefn

function figure_show(ifig, varargin)
  if (nargin < 1)
    print_usage();
  endif
  
  figure_set_visible(ifig, "on", varargin{:});
endfunction

%!demo
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_show(hfig, "gnuplot");
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
