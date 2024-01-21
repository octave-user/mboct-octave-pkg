## figure_hide.m:01
%!test
%! for i=1:2
%!   h(i) = figure("visible", "off");
%! endfor
%! figure_hide(h);
%! for i=1:numel(h)
%!   close(h(i));
%! endfor
