## doe_res_idx_to_param_idx.m:02
%!demo
%! x = linspace(-pi / 2, pi / 2, 30);
%! y = linspace(-pi / 3, pi / 3, 25);
%! dim = int32([numel(x), numel(y)]);
%! options.number_of_parameters = doe_param_dim_to_res_dim(dim);
%! options.number_of_processors = int32(4);
%! options.verbose = false;
%! x_idx = @(i) doe_res_idx_to_param_idx(dim, i)(1);
%! y_idx = @(i) doe_res_idx_to_param_idx(dim, i)(2);
%! func = @(i, x, y) sin(x(x_idx(i))^2 + y(y_idx(i))^2);
%! res = run_parallel(options, func, x, y);
%! z = zeros(numel(x), numel(y));
%! for i=1:numel(res)
%!  idx = doe_res_idx_to_param_idx(dim, i);
%!  z(idx(1), idx(2)) = res{i};
%! endfor
%! for i=1:numel(x)
%!  for j=1:numel(y)
%!    assert(z(i, j), sin(x(i)^2 + y(j)^2));
%!  endfor
%! endfor
%! figure("visible", "off");
%! [xx, yy] = meshgrid(x, y);
%! contourf(xx, yy, z.');
%! colormap("jet");
%! colorbar();
%! xlabel("x");
%! ylabel("y");
%! title("f(x,y) = sin(x^2 + y^2)");
