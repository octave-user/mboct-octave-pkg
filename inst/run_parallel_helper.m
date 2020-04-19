## Copyright(C) 2016(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Script File} run_parallel_helper
## Helper script which is used by run_parallel
##
## @seealso{run_parallel}
## @end deftypefn

clear all;
close all;

try
  args = argv();

  func = [];
  input_file = "";
  proc_idx = int32(-1);
  i = int32(0);
  
  while (++i <= length(args))
    if (length(args) < i + 1)
      error("missing argument for switch \"%s\"", args{i});
    endif
    
    switch (args{i})
      case "--function"
        func = args{++i};
      case "--input-file"
        input_file = args{++i};
      case "--output-format"
        output_format = args{++i};
      case "--proc-idx"
        [proc_idx, count] = sscanf(args{++i}, "%d", "C");
        if (count ~= 1)
          error("invalid argument %s %s", args{i - 2}, args{i - 1});
        endif
    endswitch
  endwhile

  if (length(func) == 0)
    error("missing argument --function");
  endif

  if (length(input_file) == 0)
    error("missing argument --input-file");
  endif

  if (proc_idx == -1)
    error("missing argument --proc-idx");
  endif

  input_data = load(input_file, "data", "oct_path", "pkg_names");

  if (~isfield(input_data, "data"))
    error("missing record \"data\" in file \"%s\"", input_file);
  endif

  if (~isfield(input_data, "oct_path"))
    error("missing record \"oct_path\" in file \"%s\"", input_file);
  endif
  
  addpath(input_data.oct_path);

  feval(func, proc_idx, input_data.data);
  
  if (input_data.data.options.verbose)
    fprintf(stderr, "exiting process %d ...\n", getpid());
  endif
catch
  if (input_data.data.options.verbose)
    fprintf(stderr, "exiting process %d with error:\n", getpid());
    error_report(lasterror());
  endif
  
  exit(1);
end_try_catch
