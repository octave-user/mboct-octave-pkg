## addpath_full.m:02
%!demo
%! try
%! addpath_full("~");
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error);
%!   rethrow(gtest_error);
%! end_try_catch
