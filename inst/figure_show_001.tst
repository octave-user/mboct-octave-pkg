## figure_show.m:01
%!demo
%! try
%! hfig = [];
%! for i=1:3
%!  hfig(end + 1) = figure("visible", "off");
%! endfor
%! figure_show(hfig, "gnuplot");
%! for i=1:numel(hfig)
%!   close(hfig(i));
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
