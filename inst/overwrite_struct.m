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
## @deftypefn {Function File} @var{data} = overwrite_struct(@var{data_in}, @var{overwrite})
## @deftypefnx {} @dots{} = overwrite_struct(@var{data_in}, @var{overwrite}, @var{options})
## This function is useful for Octave programs which allow user input in form of octave expressions passed as command line arguments.
## Overwrite a value in a struct by an expression passed as a character string.
##
## @var{data_in} @dots{} input data structure
##
## @var{overwrite} @dots{} return value from overwrite_struct_add_arg
##
## @var{options}.verbose @dots{} enable verbose output
##
## @example
## ov.data.x = 1;
## ov.data.y = 2;
## args = @{"data.x=1.5", "data.y=2.5"@};
## ovd = struct()([]);
## for i=1:numel(args)
##   ovd = overwrite_struct_add_arg(ovd, args@{i@});
## endfor
## ov = overwrite_struct(ov, ovd);
## @end example
## @seealso{overwrite_struct_add_arg}
## @end deftypefn

function data = overwrite_struct(data_in, overwrite, options)
  if (nargin < 2 || nargin > 3)
    print_usage();
  endif

  if (nargin < 3)
    options = struct();
  endif
  
  if (~isfield(options, "verbose"))
    options.verbose = true;
  endif
  
  data = data_in;

  for i=1:length(overwrite)
    base_struct_name = "data";
    curr_value = {data};

    for j=1:length(overwrite(i).struct_name)
      if (~isfield(curr_value{j}, overwrite(i).struct_name{j}))
        error("field \"%s\" not found in struct \"%s\"", overwrite(i).struct_name{j}, base_struct_name);
      endif
      curr_value{j + 1} = getfield(curr_value{j}, overwrite(i).struct_name{j});
      base_struct_name = overwrite(i).struct_name{j};
    endfor
    
    if (options.verbose)
      if (~strcmp(typeinfo(overwrite(i).value), typeinfo(curr_value{end})))
        warning("data type for field \"%s\" does not match: expected type \"%s\" but got type \"%s\"", ...
                overwrite(i).struct_name{end}, ...
                typeinfo(curr_value{end}), ...
                typeinfo(overwrite(i).value));
      endif
      
      fprintf(stderr, "data");

      for j=1:length(overwrite(i).struct_name)
        fprintf(stderr, ".%s", overwrite(i).struct_name{j});
      endfor

      fprintf(stderr, "=");
      fdisp(stderr, overwrite(i).value);
    endif
    
    curr_value{end} = overwrite(i).value;

    for j=length(curr_value):-1:2
      curr_value{j - 1} = setfield(curr_value{j - 1}, overwrite(i).struct_name{j - 1}, curr_value{j});  
    endfor

    data = curr_value{1};
  endfor
endfunction

