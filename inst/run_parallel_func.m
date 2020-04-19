## Copyright (C) 2016(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} run_parallel_func(@var{proc_idx}, @var{data})
## Helper function used by run_parallel
##
## @var{proc_idx} @dots{} index of current process in the call to run_parallel
##
## @var{data} @dots{} data passed by the calling process in run_parallel
##
## @seealso{run_parallel}
## @end deftypefn

function run_parallel_func(proc_idx, data)
  res = cell(1, data.options.number_of_parameters);

  for i=proc_idx:data.options.number_of_processors:data.options.number_of_parameters
    try
      res{i} = feval(data.job.user_func, i, data.job.user_args{:});
    catch
      if (~data.options.ignore_errors)
        rethrow(lasterror());
      else
        error_report(lasterror());
        continue;
      endif
    end_try_catch
  endfor

  save("-binary", data.job.output_files{proc_idx}, "res");

  if (data.options.verbose)
    fprintf(stderr, "%d: job %d file \"%s\" created\n", getpid(), proc_idx, data.job.output_files{proc_idx});
  endif
endfunction
