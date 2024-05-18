## Copyright (C) 2015(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} exec_demo(@var{filename})
## @deftypefnx {} exec_demo(@var{filename}, @var{index})
## @deftypefnx {} exec_demo(@var{filename}, @var{index}, @var{first_line})
## @deftypefnx {} exec_demo(@var{filename}, @var{index}, @var{first_line}, @var{type})
##
## Executes a demo function in the global context, and leave all variables in place
##
## @var{index} index of the demo
#
## @var{first_line} first code line to be executed
##
## @var{type} type of function (e.g. "demo" or "test")
##
## @end deftypefn

function status = exec_demo(filename_in, index, first_line, type)
  if (nargin < 1 || nargin > 4)
    print_usage();
  endif

  if (nargin < 2)
    index = 1;
  endif

  if (nargin < 3)
    first_line = 1;
  endif

  if (nargin < 4)
    type = "demo";
  endif

  fid_in = -1;
  fid_out = -1;
  line_no = 0;
  status = 1;

  unwind_protect
    temp_file_name = strcat(tempname(), ".m");

    unwind_protect
      [DIR, NAME, EXT] = fileparts(filename_in);

      if (length(EXT) == 0)
        filename_in = strcat(filename_in, ".m");
      endif

      [fid_in, msg] = fopen(filename_in, "rt");

      if (-1 == fid_in)
        error("Failed to open file \"%s\": %s", filename_in, msg);
      endif

      [fid_out, msg] = fopen(temp_file_name, "wt");

      if (-1 == fid_out)
        error("Failed to open file \"%s\": %s", temp_file_name, msg);
      endif

      f_demo_found = 0;

      while (true)
        line = fgets(fid_in);

        if (-1 == line)
          break;
        endif

        ++line_no;

        if (strncmp(line, sprintf("%%!%s", type), 6) || strncmp(line, sprintf("%%!x%s", type), 7))
          if (++f_demo_found == index)
            break;
          endif
        endif
      endwhile

      if (f_demo_found == index)
        fprintf(stderr, "Commands from demo %d of file \"%s\" are written to \"%s\" ...\n", f_demo_found, filename_in, temp_file_name);

        while ( 1 == 1 )
          line = fgets(fid_in);

          if ( -1 == line )
            break;
          endif

          ++line_no;

          if (strncmp(line, "%!demo", 6) || strncmp(line, "%!test", 6) || strncmp(line, "%!xtest", 7))
            break;
          endif

          if (strncmp(line, "%!", 2))
            if (line_no >= first_line)
              line = line(3:end);
              fputs(stdout,line);
              fputs(fid_out,line);
            endif
          endif
        endwhile
      endif

    unwind_protect_cleanup
      if (fid_in != -1)
        fclose(fid_in);
      endif
      if (fid_out != -1)
        fclose(fid_out);
      endif
    end_unwind_protect

    try
      fprintf(stderr, "\nfile \"%s\" will be executed!\n", temp_file_name);
      evalin("base", sprintf("clear all; __file='%s'; source('%s')", filename_in, temp_file_name));
      status = 0;
    catch
      fprintf(stderr, "\nerror in file \"%s\"\n", temp_file_name);
      error_report(lasterror());
    end_try_catch
  unwind_protect_cleanup
    [~] = unlink(temp_file_name);
  end_unwind_protect
endfunction
