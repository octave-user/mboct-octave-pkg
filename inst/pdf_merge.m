## Copyright (C) 2016(-2016) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} @var{status} = pdf_merge(@var{input_filenames}, @var{output_filename}, @var{verbose})
## Combine several Pdf files listed in @var{input_filenames} into a single file identified by @var{output_filename}.
## If one has many pdf files to be merged, pdf_merge is significantly faster than using the "-append" option of print.
##
## @var{input_filenames} @dots{} cell array of strings containing input filenames
##
## @var{output_filename} @dots{} char string containing the output filename
##
## @var{verbose} @dots{} enable verbose output
## @seealso{pdf_create,print}
## @end deftypefn

function status = pdf_merge(input_filenames, output_filename, verbose)
  if (nargin < 2 || nargin > 3)
    print_usage();
  endif
  
  if (nargin < 3)
    verbose = false;
  endif
  
  [output_dir, output_name, output_ext] = fileparts(output_filename);

  if (~strcmp(output_ext, ".pdf"))
    output_ext = ".pdf";
  endif

  output_filename = fullfile(output_dir, cstrcat(output_name, output_ext));

  status = run_command(input_filenames, output_filename, verbose);
endfunction

function status = run_command(files, output_filename, verbose)
  max_length = 32768; ## according to WIN32 API documentation (CreateProcess)
    
  max_trials = 100;
  j = 0;
  cmd = "gs";
  [out_dir, out_name, out_ext] = fileparts(output_filename);
  stage = 0;
  
  do
    files_next_stage = {};
    k = 1;
    do      
      cmd_length = length(cmd) + 3 + 2;
      output_filename_tmp = fullfile(out_dir, sprintf("%s_st%03d%s", out_name, ++j, out_ext));
      
      args = {"-q", "-dNOPAUSE", "-dBATCH", "-sDEVICE=pdfwrite", sprintf("-sOutputFile=%s", output_filename_tmp), "-f"};
      
      for i=1:length(args)
        cmd_length += length(args{i}) + 3;
      endfor
      
      N = k - 1;

      total_size = 0;
      
      for i=k:length(files)
        [info, err, msg] = stat(files{i});

        if (err ~= 0)
          error("file not found: \"%s\": %s", files{i}, msg);
        endif

        if (info.size == 0)
          error("file \"%s\" size is zero", files{i});
        endif
        
        length_add = length(files{i}) + 3;

        if (cmd_length + length_add > max_length)
          break
        endif

        total_size += info.size;
        cmd_length += length_add;
        ++N;
      endfor

      if (N < length(files) && length(k:N) < 2)
        error("command line too long for this system");
      endif

      [~] = unlink(output_filename_tmp);

      if (verbose)
        fprintf(stderr, "\"%s%s\" stage %d: processing files [%d:%d] of %d\n", out_name, out_ext, stage, k, N, length(files));
      endif

      for l=1:max_trials
        pid = spawn(cmd, {args{:}, files{k:N}});

        status = spawn_wait(pid);

        [info, err] = stat(output_filename_tmp);
        
        if (status == 0 && err == 0 && info.size > 0)
          break;
        else
          if (l < max_trials)
            err_hnd = @warning;
          else
            err_hnd = @error;
          endif
          feval(err_hnd, "command \"%s\" failed with status %d", cmd, status);
        endif
      endfor
      
      for i=k:N
        [err, msg] = unlink(files{i});
        
        if (err ~= 0)
          warning("unlink(\"%s\") failed with status %d: %s\n", files{i}, err, msg);
        endif
      endfor
      
      files_next_stage{end + 1} = output_filename_tmp;
      k = N + 1;
    until (N == length(files));
    
    files = files_next_stage;
    ++stage;
  until (length(files_next_stage) == 1)

  [~] = unlink(output_filename);
  
  [err, msg] = rename(files_next_stage{1}, output_filename);

  if (err ~= 0)
    error("failed to rename file \"%s\": %s", files_next_stage{1}, msg);
  endif
endfunction

