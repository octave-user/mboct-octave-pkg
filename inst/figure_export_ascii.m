## Copyright (C) 2017(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} figure_export_ascii(@var{nfig}, @var{output_filename})
##
## @deftypefnx {Function File} figure_export_ascii(@var{nfig}, @var{output_filename}, @var{sample_rate})
##
## Creates an ASCII file to be imported by MS Excel from all figures in range <@var{nfig}>.
## Only those curves will be written to the ASCII file which have a name.
##
## @var{nfig} @dots{} Array of figure handles.
##
## @var{output_filename} @dots{} Name of the output file.
##
## @var{sample_rate} @dots{} Define this value to an integer higher than one in order to reduce the amount of data.
##
## @end deftypefn

function figure_export_ascii(figures = "all", varargin)
  if (~(nargin >= 2 && nargin <= 3))
    print_usage();
  endif

  if (ischar(figures) && strcmp(figures, "all"))
    figures = sort(get(0, "children"));
  endif

  if (nargin >= 3)
    sample_rate = varargin{2};
  else
    sample_rate = 1;
  endif

  fd = -1;

  unwind_protect
    if (isscalar(varargin{1}))
      fd = varargin{1};
    elseif (ischar(varargin{1}))
      [fd, msg] = fopen(varargin{1}, "wt");
    else
      print_usage();
    endif

    if (fd == -1)
      error("failed to open file \"%s\"", varargin{1});
    endif

    curve_dat = struct()([]);
    max_rows = 0;

    for i=1:length(figures)
      switch (get(figures(i), "type"))
        case "figure"
          axes = sort(get(figures(i), "children"), "ascend");
          for j=1:length(axes)
            switch (get(axes(j), "type"))
              case "axes"
                titlestr = get(get(axes(j), "title"), "string");
                xl = get(get(axes(j), "xlabel"), "string");
                yl = get(get(axes(j), "ylabel"), "string");
                curves = sort(get(axes(j), "children"), "ascend");
                for k=1:length(curves)
                  switch (get(curves(k), "type"))
                    case "line"
                      name = get(curves(k), "displayname");
                      x = get(curves(k), "xdata")(1:sample_rate:end);
                      y = get(curves(k), "ydata")(1:sample_rate:end);

                      if (length(name) > 0 && length(xl) > 0 && length(yl) > 0)
                        max_rows = max(max_rows, length(x));
                        curve_dat(end + 1).titlestr = titlestr;
                        curve_dat(end).name = name;
                        curve_dat(end).xl = xl;
                        curve_dat(end).yl = yl;
                        curve_dat(end).x = x;
                        curve_dat(end).y = y;
                      endif
                  endswitch
                endfor
            endswitch
          endfor
      endswitch
    endfor

    for i=1:length(curve_dat)
      fprintf(fd, "%s\t%s\t", curve_dat(i).titlestr, curve_dat(i).name);
    endfor

    fprintf(fd, "\n");

    for i=1:length(curve_dat)
      fprintf(fd, "%-10.6s\t%-10.6s\t", curve_dat(i).xl, curve_dat(i).yl);
    endfor

    fprintf(fd, "\n");

    for j=1:max_rows
      for i=1:length(curve_dat)
        if (length(curve_dat(i).x) >= j)
          fprintf(fd, "%10.6e\t%10.6e\t", [curve_dat(i).x(j); curve_dat(i).y(j)]);
        else
          fprintf(fd, "\t\t");
        endif
      endfor
      fprintf(fd, "\n");
    endfor
  unwind_protect_cleanup
    if (~isscalar(varargin{1}) && fd ~= -1)
      fclose(fd);
    endif
  end_unwind_protect
endfunction

%!error figure_export_ascii();

%!error figure_export_ascii(1, {});

%!error figure_export_ascii(1, "", 1, 2);

%!test
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp("figure_export_ascii_XXXXXX", true);
%! for i=1:5
%!  hfig(end + 1) = figure("visible", "off");
%!  for j=1:2
%!    subplot(2, 1, j);
%!    hold("on");
%!    for k=1:2
%!      plot(1:10,rand(1, 10), sprintf("-;rand(%d, %d);%d", i, j, k));
%!    endfor
%!    xlabel("x");
%!    ylabel("y");
%!    title(sprintf("test figure %d axes %d", i, j));
%!  endfor
%! endfor
%! figure_export_ascii(hfig, fd, 2);
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    fclose(fd);
%!    unlink(output_file);
%!  endif
%! end_unwind_protect

%!test
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp("figure_export_ascii_XXXXXX", true);
%! for i=1:5
%!  hfig(end + 1) = figure("visible", "off");
%!  for j=1:2
%!    subplot(2, 1, j);
%!    plot(1:10,rand(1, 10), sprintf("-;rand(%d);%d", i, i));
%!    xlabel("x");
%!    ylabel("y");
%!    title(sprintf("test figure %d axes %d", i, j));
%!  endfor
%! endfor
%! fclose(fd);
%! figure_export_ascii(hfig, output_file, 1);
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    unlink(output_file);
%!  endif
%! end_unwind_protect

%!demo
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp("figure_export_ascii_XXXXXX", true);
%! x = linspace(0, 2 * pi, 10);
%! y = [sin(x); cos(x)];
%! for i=1:rows(y)
%!   hfig(end + 1) = figure("visible", "off");
%!   for j=1:2
%!     subplot(2, 1, j);
%!     hold on;
%!     for k=1:2
%!       plot(x, y(i, :), sprintf("-;y%d=f%d(x%d);1", i, j, k));
%!     endfor
%!     xlabel("x");
%!     ylabel("y");
%!     title(sprintf("figure(%d) axes(%d)", i, j));
%!   endfor
%! endfor
%! figure_export_ascii(hfig, output_file, 2);
%! spawn_wait(spawn("cat", {output_file}));
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    fclose(fd);
%!    unlink(output_file);
%!  endif
%! end_unwind_protect
