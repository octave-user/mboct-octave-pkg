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
## @deftypefn {Function File} @var{overwrite} = overwrite_struct_add_arg(@var{overwrite_in}, @var{cmd_arg})
## Add a command line argument @var{cmd_args} to a list of values @var{overwrite_in} which can be passed to overwrite_struct.
## @seealso{overwrite_struct}
## @end deftypefn

function overwrite = overwrite_struct_add_arg(overwrite_in, cmd_arg)
  if (nargin ~= 2)
    print_usage();
  endif

  overwrite = overwrite_in;

  try
    [struct_name, value] = strtok(cmd_arg, "=");
    value = strtok(value, "=");
    overwrite(end + 1).value = eval(value);
    j = int32(0);

    while (length(struct_name) > 0)
      [overwrite(end).struct_name{++j}, struct_name] = strtok(struct_name, ".");
    endwhile
  catch
    error("invalid argument: --set-var \"%s\"", cmd_arg);
  end_try_catch
endfunction

%!test
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
%! assert(ov.data.x, 2);
%! assert(ov.data.opts.y, zeros(3, 3));
%! assert(ov.data.opts.name.z, "123");

%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x1=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);

%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y1=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);

%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z2=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
