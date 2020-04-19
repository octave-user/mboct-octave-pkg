## Copyright (C) 2017(-2020) Reinhard <octave-user@a1.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{param_idx} = doe_res_idx_to_param_idx(@var{parameter_dim}, @var{result_index})
## This function is useful to distribute DOE's to multiple processes with run_parallel.
## For example we have a scalar function @var{y} = f(@var{x}_1, @var{x}_2, @dots{}, @var{x}_@var{N})
## which depends on @var{N} scalar parameters. For each parameter @var{x}_i the function f should be
## evaluated for @var{parameter_dim}(i) different values. In this case the total number of function
## evaluations to be executed by run_parallel will be
## @var{number_of_parameters} = doe_param_dim_to_res_dim(@var{parameter_dim}).
## Run_parallel will pass @var{result_index} as the first argument to the user supplied callback
## function @var{func}. Then the callback function @var{func} can use the return value @var{param_idx}
## from doe_res_idx_to_param_idx(@var{parameter_dim}, @var{result_index}) to evaluate @var{x}_i.
##
## @var{y}@{@var{result_index}@} = f(@var{x}_1(@var{param_idx}(1)), @var{x}_2(@var{param_idx}(2)), @dots{}, @var{x}_N(@var{param_idx}(@var{N})))
##
## @var{parameter_dim} @dots{} array containing the number of different values for each parameter in the DOE
##
## @var{result_index} @dots{} index of the function call (e.g. the first argument passed to a user function by run_parallel)
##
## @seealso{run_parallel, doe_param_dim_to_res_dim}
## @end deftypefn

function param_idx = doe_res_idx_to_param_idx(parameter_dim, result_index)
  param_idx = zeros(1, numel(parameter_dim), "int32");
  dim = zeros(1, numel(parameter_dim), "int32");
  dim(end) = 1;
  
  for i=numel(dim) - 1:-1:1
    dim(i) = dim(i + 1) * parameter_dim(i + 1);
  endfor
  
  for i=1:numel(parameter_dim)
    param_idx(i) = mod(floor((result_index - 1) / dim(i)), parameter_dim(i)) + 1;
  endfor
endfunction

%!test
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
