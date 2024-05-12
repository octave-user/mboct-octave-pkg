## exec_test.m:01
%!test
%! try
%! exec_test(which("exec_demo"), 1);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
