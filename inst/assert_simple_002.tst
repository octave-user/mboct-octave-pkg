## assert_simple.m:02
%!test  # 2-D matrix
%! try
%! A = [1 2 3]'*[1,2];
%! assert_simple (A, A);
%! fail ("assert_simple (A.*(A!=2),A)");
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!test
%! try
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
