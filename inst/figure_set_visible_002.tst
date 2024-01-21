## figure_set_visible.m:02
%!demo
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_set_visible(hfig, "off", "gnuplot");
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
