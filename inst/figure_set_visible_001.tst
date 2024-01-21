## figure_set_visible.m:01
%!test
%! for i=1:2
%!   h(i) = figure("visible", "off");
%! endfor
%! figure_set_visible(h(i), "off", "gnuplot");
%! for i=1:numel(h)
%!   close(h(i));
%! endfor
