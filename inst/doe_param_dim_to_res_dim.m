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

