## doe_res_idx_to_param_idx.m:01
%!test
%! try
%! x = linspace(-pi / 2, pi / 2, 3);
%! y = linspace(-pi / 3, pi / 3, 5);
%! z = linspace(-pi / 4, pi / 3, 9);
%! u = linspace(-1, 1, 3);
%! v = linspace(0, 1, 2);
%! dim = int32([numel(x), numel(y), numel(z), numel(u), numel(v)]);
%! options.number_of_parameters = doe_param_dim_to_res_dim(dim);
%! options.number_of_processors = int32(4);
%! options.verbose = false;
%! x_idx = @(i) doe_res_idx_to_param_idx(dim, i)(1);
%! y_idx = @(i) doe_res_idx_to_param_idx(dim, i)(2);
%! z_idx = @(i) doe_res_idx_to_param_idx(dim, i)(3);
%! u_idx = @(i) doe_res_idx_to_param_idx(dim, i)(4);
%! v_idx = @(i) doe_res_idx_to_param_idx(dim, i)(5);
%! func = @(i, x, y, z) sin(u(u_idx(i)) * x(x_idx(i))^2 + v(v_idx(i)) * y(y_idx(i))^2 + z(z_idx(i))^2);
%! res = run_parallel(options, func, x, y, z);
%! f = zeros(numel(x), numel(y), numel(z), numel(u), numel(v));
%! for i=1:numel(res)
%!  idx = doe_res_idx_to_param_idx(dim, i);
%!  f(idx(1), idx(2), idx(3), idx(4), idx(5)) = res{i};
%! endfor
%! for i=1:numel(x)
%!  for j=1:numel(y)
%!    for k=1:numel(z)
%!      for l=1:numel(u)
%!        for m=1:numel(v)
%!          assert(f(i, j, k, l, m), sin(u(l) * x(i)^2 + v(m) * y(j)^2 + z(k)^2));
%!        endfor
%!      endfor
%!    endfor
%!  endfor
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
