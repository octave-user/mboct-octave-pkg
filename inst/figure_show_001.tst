## figure_show.m:01
%!demo
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_show(hfig, "gnuplot");
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
