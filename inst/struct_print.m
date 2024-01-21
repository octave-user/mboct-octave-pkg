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
## @deftypefn {Function File} struct_print (@var{param},@var{fout},@var{prefix})
##
## Prints the struct @var{param} to the file associated with file descriptor @var{fout}.
## Optionally the string @var{prefix} can be used as the name of the data structure.
## The output can be loaded into octave again by means of the source command.
##
## @end deftypefn

function struct_print(param, fout, prefix)
  if (nargin < 1 || nargin > 3)
    print_usage();
  endif

  if (nargin < 2)
    fout = stdout;
  endif

  if (nargin < 3)
    prefix = inputname(1);
  endif

  owns_fd = false;

  unwind_protect
    if (ischar(fout))
      fname = fout;
      fout = -1;
      owns_fd = true;
      [fout, msg] = fopen(fname, "wt");

      if (fout == -1)
        error("could not open file \"%s\": %s", fname, msg);
      endif
    endif

    param_names = sort(fieldnames(param));

    for j=1:length(param)
      for i=1:length(param_names)
        param_val = getfield(param(j),param_names{i});

        if (length(param) > 1)
          if (length(prefix) > 0)
            struct_array_prefix = sprintf("(%d)",j);
          else
            error("prefix must be present for struct array!");
          endif
        else
          struct_array_prefix = "";
        endif

        if (length(prefix) > 0)
          struct_array_prefix = strcat(struct_array_prefix,".");
        endif

        if (isstruct(param_val))
          struct_print(param_val,fout,strcat(prefix, struct_array_prefix, param_names{i}));
        else
          if (ndims(param_val) <= 2)
            param_name_eq = sprintf("%s%s%s = ", prefix, struct_array_prefix, param_names{i});

            fprintf(fout,param_name_eq);

            print_value(param_val,fout,length(param_name_eq)+1);
            fprintf(fout,";\n\n");
          else
            if (~iscell(param_val))
              fprintf(fout, "%s%s%s = zeros(", prefix, struct_array_prefix, param_names{i});
              for k=1:ndims(param_val)
                fprintf(fout, "%d", size(param_val, k));
                if (k < ndims(param_val))
                  fprintf(fout, ", ");
                else
                  fprintf(fout, ");\n");
                endif
              endfor
            endif
            for k=1:size(param_val, 3)
              for l=1:size(param_val, 4)
                param_name_eq = sprintf("%s%s%s(:,:,%d,%d) = ", prefix, struct_array_prefix, param_names{i}, k, l);
                fprintf(fout,param_name_eq);
                if (iscell(param_val))
                  print_value({param_val{:, :, k, l}}, fout, length(param_name_eq) + 1);
                else
                  print_value(param_val(:, :, k, l), fout, length(param_name_eq) + 1);
                endif
                fprintf(fout,";\n\n");
              endfor
            endfor
          endif
        endif
      endfor
    endfor
  unwind_protect_cleanup
    if (owns_fd && fout ~= -1)
      fclose(fout);
    endif
  end_unwind_protect
endfunction

function print_value(param_val, fout, indent)
  if (isstruct(param_val))
    print_struct_elem(param_val, fout);
  elseif (is_function_handle(param_val))
    param_string = disp(param_val);
    fprintf(fout, "%s", substr(param_string, 1, length(param_string) - 1));
  elseif (isscalar(param_val))
    if (isbool(param_val))
      if (param_val)
        fprintf(fout, "true");
      else
        fprintf(fout, "false");
      endif
    elseif (isinteger(param_val))
      fprintf(fout, "int32(%d)", param_val);
    elseif (isreal(param_val))
      fprintf(fout, "%.16g",param_val);
    elseif (iscomplex(param_val))
      fprintf(fout, "%.16g + %.16gj", real(param_val), imag(param_val));
    endif
  elseif (ischar(param_val))
    fprintf(fout, "\"%s\"", param_val);
  elseif (ismatrix(param_val) || iscell(param_val))
    if (iscell(param_val))
      fprintf(fout, "{");
    else
      fprintf(fout, "[");
    endif

    if (rows(param_val) > 0 && columns(param_val) > 0)
      for j=1:rows(param_val)
        for k=1:columns(param_val)
          if (k == 1 && j > 1)
            for l=1:indent
              fprintf(fout, " ");
            endfor
          endif

          if (iscell(param_val))
            param_val_jk = param_val{j, k};
          else
            param_val_jk = param_val(j, k);
          endif

          print_value(param_val_jk, fout, indent);

          if (k < columns(param_val))
            fprintf(fout, ",");
          elseif (j < rows(param_val))
            fprintf(fout, ";\n");
          endif
        endfor
      endfor
    endif

    if (iscell(param_val))
      fprintf(fout, "}");
    else
      fprintf(fout, "]");
    endif
  elseif (isnull(param_val) || rows(param_val) == 0 || columns(param_val) == 0)
    fprintf(fout, "[]");
  endif
endfunction

function print_struct_elem(param_val,fout)
  fprintf(fout, "struct(");
  names = fieldnames(param_val);

  for i=1:length(names)
    fprintf(fout, "\"%s\",", names{i});
    val = getfield(param_val, names{i});
    print_value(val, fout, 0);

    if (i < numel(names))
      fprintf(fout, ",");
    endif
  endfor
  fprintf(fout, ")");
endfunction

