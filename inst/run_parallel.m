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
## @deftypefn {Function File} @var{res} = run_parallel(@var{options}, @var{func}, @var{varargin})
## Distribute the execution of a function to multiple processes and return the results of each call as an cell array.
##
## @var{options}.number_of_parameters @dots{} total number of calls to @var{func} to be executed
##
## @var{options}.number_of_processors @dots{} maximum number of processes running at the same time
##
## @var{options}.ignore_errors @dots{} continue if @var{func} throws an exception
##
## @var{options}.octave_exec @dots{} Octave's executable to start
##
## @var{func} @dots{} user function to be called (e.g. res@{idx@} = feval(func, idx, varargin@{:@}))
##
## @var{varargin} @dots{} additional arguments to be passed to @var{func}
## @seealso{run_parallel_func, run_parallel_helper, doe_param_dim_to_res_dim, doe_res_idx_to_param_idx}
## @end deftypefn

function res = run_parallel(options, func, varargin)
  if (nargin < 2)
    print_usage();
  endif

  output_dir = fullfile(tempdir(), sprintf("octave-run_parallel_%04d", getpid()));
  
  if (~isfield(options, "number_of_processors"))
    error("missing field options.number_of_processors");
  endif

  if (~isfield(options, "number_of_parameters"))
    error("missing field options.number_of_parameters");
  endif

  if (~isfield(options, "ignore_errors"))
    options.ignore_errors = false;
  endif

  if (~isfield(options, "verbose"))
    options.verbose = false;
  endif

  if (~isfield(options, "octave_exec"))
    options.octave_exec = fullfile(OCTAVE_HOME, "bin", "octave-cli");
  endif
  
  if (options.number_of_parameters < options.number_of_processors)
    options.number_of_processors = options.number_of_parameters;
  endif

  res = cell(1, options.number_of_parameters);
  
  pid = repmat(uint64(-1), 1, options.number_of_processors);

  status_dir = 0;
  
  unwind_protect
    status_dir = mkdir(output_dir);

    if (status_dir ~= 1)
      error("failed to create directory \"%s\"", output_dir);
    endif

    try
      output_files = cell(1, options.number_of_processors);
      
      for i=1:options.number_of_processors
        output_files{i} = fullfile(output_dir, sprintf("result_%02d.mat", i));
      endfor

      proc_idx = 1;

      helper_script = which("run_parallel_helper");

      if (numel(helper_script) == 0)
        error("file not found run_parallel_helper.m");
      endif

      input_data_file = fullfile(output_dir, "input_data.mat");
      
      oct_path = path();
      
      data.options = options;
      data.job.user_func = func;
      data.job.user_args = varargin;
      data.job.output_files = output_files;
      
      save("-binary", input_data_file, "data", "oct_path");

      if (options.verbose)
        start_time = tic();
      endif
      
      for i=1:options.number_of_processors
        args ={"--no-gui", ...
               "--no-history", ...
               "--norc", ...
               "--no-init-file", ...
               "-q", ...
               helper_script, ...
               "--function", ...
               "run_parallel_func", ...
               "--input-file", ...
               input_data_file, ...
               "--proc-idx", ...
               sprintf("%d", i)};
        pid(i) = spawn(options.octave_exec, args);
      endfor

      for i=1:numel(pid)
        if (pid(i) > 0)
          status = spawn_wait(pid(i));
          if (options.verbose)
            fprintf(stderr, "%d: job %d returned with status %d\n", getpid(), pid(i), status);
          endif
        endif
      endfor

      res = cell(1, options.number_of_parameters);
      
      for i=1:numel(output_files)
        res_i = load(output_files{i}, "res").res;
        
        for j=i:options.number_of_processors:options.number_of_parameters
          res{j} = res_i{j};
        endfor

        if (options.verbose)
          fprintf(stderr, "%d: removing file \"%s\" ...\n", getpid(), output_files{i});
        endif        
        
        if (0 ~= unlink(output_files{i}))
          warning("failed to remove file \"%s\"", output_files{i});
        endif
      endfor

      if (options.verbose)        
        toc(start_time);
      endif
    catch
      current_exception = lasterror();
      
      for i=1:numel(pid)
        if (pid(i) > 0)
          if (0 ~= kill(pid(i), SIG.TERM))
            warning("failed to terminate process %d", pid(i));
          endif
          
          status = spawn_wait(pid(i));

          if (options.verbose)
            if (status == 0)
              fprintf(stderr, "%d: job %d completed with status %d\n", getpid(), pid(i), status);
            else
              fprintf(stderr, "%d: job %d failed with status %d\n", getpid(), pid(i), status);
            endif
          endif
        endif
      endfor
      rethrow(current_exception);
    end_try_catch
  unwind_protect_cleanup
    if (status_dir == 1)
      status = confirm_recursive_rmdir();
      confirm_recursive_rmdir(false);
      if (options.verbose)
        fprintf(stderr, "removing directory \"%s\" ...\n", output_dir);
      endif
      rmdir(output_dir, "s");
      confirm_recursive_rmdir(status);
    endif
  end_unwind_protect
endfunction

