## figure_list.m:01
%!demo
%! try
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
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
