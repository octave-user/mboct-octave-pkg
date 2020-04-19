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
## @deftypefn {Function File} figure_set_visible(@var{ifig}, @var{visible})
## @deftypefnx {} figure_set_visible(@dots{}, @var{toolkit})
## Makes several figures, identified by @var{ifig}, visible or invisible and select a graphics toolkit for it.
##
## @var{ifig} @dots{} Array of figure handles
##
## @var{toolkit} @dots{} String name of graphics toolkit to be selected for @var{ifig}
##
## @seealso{figure_show,figure_hide,figure_list}
## @end deftypefn

function figure_set_visible(ifig, visible, toolkit)
  if (nargin < 2 || nargin > 3)
    print_usage();
  endif

  try
    if (ischar(ifig))
      switch (ifig)
        case "all"
          ifig = get(0, "children");
        otherwise
          error("ifig must be a number, a range or \"all\"");
      endswitch
    endif

    ifig = sort(ifig);

    for i=1:length(ifig)
      switch (get(ifig(i), "type"))
        case "figure"
          if (nargin >= 3)
            graphics_toolkit(ifig(i), toolkit);
          endif
          figure(ifig(i), "visible", visible);
        otherwise
          error("%d is not valid figure handle", ifig(i));
      endswitch
    endfor
  catch
    error_report(lasterror());
  end_try_catch
endfunction

%!test
%! for i=1:2
%!   h(i) = figure("visible", "off");
%! endfor
%! figure_set_visible(h(i), "off", "gnuplot");
%! for i=1:numel(h)
%!   close(h(i));
%! endfor

%!demo
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_set_visible(hfig, "off", "gnuplot");
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
