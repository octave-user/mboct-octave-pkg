## printable_title.m:01
%!test
%! try
%! assert(printable_title("__"), "  ");
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
