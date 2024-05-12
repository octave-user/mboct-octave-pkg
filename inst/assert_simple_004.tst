## assert_simple.m:04
%!test
%! try
%! assert_simple (0.1+eps, 0.1, 2*eps);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!error <Rel err 2.2204e-0?15 exceeds tol> assert_simple (0.1+eps, 0.1, -2*eps)
%!test
%! try
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
