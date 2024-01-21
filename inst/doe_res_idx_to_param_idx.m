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

