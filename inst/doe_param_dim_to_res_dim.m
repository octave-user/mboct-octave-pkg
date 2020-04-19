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
## @deftypefn {Function File} @var{n} = doe_param_dim_to_res_dim(@var{parameter_dim})
## Return the total number of function evaluations needed by a DOE with @var{parameter_dim} dimensions.
## @seealso{run_parallel, doe_res_idx_to_param_idx}
## @end deftypefn

function n = doe_param_dim_to_res_dim(parameter_dim)
  if (nargin ~= 1)
    print_usage();
  endif
  
  n = int32(1);

  for i=1:numel(parameter_dim)
    n *= parameter_dim(i);
  endfor
endfunction

%!error doe_param_dim_to_res_dim();

%!test
%! assert(doe_param_dim_to_res_dim(int32([4, 3, 8, 10])), int32(4 * 3 * 8 * 10));

%!demo
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
