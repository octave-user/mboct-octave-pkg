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
## @deftypefn {Function File} error_report()
## @deftypefnx {} error_report(@var{err})
## @deftypefnx {} error_report(@var{err}, @var{fd})
## Print an error report for @var{err} to a file @var{fd} or to stderr
## @end deftypefn

function error_report(err = lasterror(), fd = stderr())
  if (nargin > 2)
    print_usage();
  endif
  
  if (fd == -1)
    error("invalid file number %d\n", fd);
  endif

  if (ischar(err))
    fprintf(stderr, "error: %s\n", err);
  elseif (isstruct(err))
    if (isfield(err, 'message'))
      fprintf(fd, "message: %s\n", err.message);
    endif

    if (isfield(err, 'identifer'))
      fprintf(fd, "identifer: %s\n", err.identifer);
    endif

    if (isfield(err, 'stack'))
      if (isfield(err.stack, "file") && isfield(err.stack, "name") && isfield(err.stack, "line") && isfield(err.stack, "column"))
        for i=1:numel(err.stack)
          fprintf(fd,"file: %s name: %s line: %d column: %d\n", err.stack(i).file, err.stack(i).name, err.stack(i).line, err.stack(i).column);
        endfor
      endif
    endif
  endif
endfunction

%!test
%! try
%!   x = 1:3;
%!   x(-1) = 5;
%! catch
%!   fd = -1;
%!   unwind_protect
%!     [fd, fname] = mkstemp("error_report_XXXXXX", true);
%!     error_report(lasterror(), fd);
%!   unwind_protect_cleanup
%!     if (fd ~= -1)
%!       fclose(fd);
%!       unlink(fname);
%!     endif
%!  end_unwind_protect
%! end_try_catch

%!demo
%! try
%!   x = 1:3;
%!   x(-1) = 5;
%! catch
%!   error_report(lasterror(), stderr);
%! end_try_catch
