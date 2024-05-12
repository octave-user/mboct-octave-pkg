## doe_param_dim_to_res_dim.m:01
%!test
%! try
%! assert(doe_param_dim_to_res_dim(int32([4, 3, 8, 10])), int32(4 * 3 * 8 * 10));
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
