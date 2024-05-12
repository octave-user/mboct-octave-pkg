## figure_hide.m:01
%!test
%! try
%! for i=1:2
%!   h(i) = figure("visible", "off");
%! endfor
%! figure_hide(h);
%! for i=1:numel(h)
%!   close(h(i));
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
