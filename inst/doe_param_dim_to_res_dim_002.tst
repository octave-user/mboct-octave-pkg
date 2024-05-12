## doe_param_dim_to_res_dim.m:02
%!demo
%! try
%! parameter_dim = int32([3, 5]);
%! x1 = linspace(0, 1, parameter_dim(1));
%! x2 = linspace(1, 2, parameter_dim(2));
%! n = doe_param_dim_to_res_dim(parameter_dim);
%! func = @(x1, x2) x1^2 / (1 + x2^2);
%! for i=1:n
%!  param_idx = doe_res_idx_to_param_idx(parameter_dim, i);
%!  x1_i = x1(param_idx(1));
%!  x2_i = x2(param_idx(2));
%!  printf("f_%02d(x1=%3.2f, x2=%3.2f)=%3.4f\n", i, x1_i, x2_i, func(x1_i, x2_i));
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
