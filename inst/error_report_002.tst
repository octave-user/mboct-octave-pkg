## error_report.m:02
%!demo
%! try
%! try
%!   x = 1:3;
%!   x(-1) = 5;
%! catch
%!   error_report(lasterror(), stderr);
%! end_try_catch
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
