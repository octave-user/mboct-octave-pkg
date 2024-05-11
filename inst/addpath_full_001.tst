## addpath_full.m:01
%!test
%! try
%! dirname = ".";
%! addpath_full(dirname);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error);
%!   rethrow(gtest_error);
%! end_try_catch
