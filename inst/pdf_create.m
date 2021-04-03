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
## @deftypefn {Function File} [@var{rc}]=pdf_create()
## @deftypefnx {} [@dots{}]=pdf_create(@var{nfig})
## @deftypefnx {} [@dots{}]=pdf_create(@var{nfig}, @var{output_filename})
## @deftypefnx {} [@dots{}]=pdf_create(@var{nfig}, @var{output_filename}, @var{width}, @var{height})
## @deftypefnx {} [@dots{}]=pdf_create(@var{nfig}, @var{output_filename}, @var{width}, @var{height}, @var{delete_tmp_files})
## @deftypefnx {} [@dots{}]=pdf_create(@var{nfig}, @var{output_filename}, @var{width}, @var{height}, @var{delete_tmp_files}, @var{single_pdf})
##
## Creates a Pdf file from all figures listed in @var{nfig}
##
## @var{nfig} @dots{} array of figure handles or character string "all"
##
## @var{output_filename} @dots{} pdf file path
##
## @var{width} @dots{} page width
##
## @var{height} @dots{} page height
##
## @var{delete_tmp_files} @dots{} if true, temporary files will be deleted
##
## @var{single_pdf} @dots{} if true, write all figures to a single .pdf file
##
## @seealso{pdf_merge}
## @end deftypefn

function rc = pdf_create(nfig = "all", output_filename = "figure", width = 1024/2, height = 768/2, delete_tmp_files = true, single_file = true, verbose = false)

  [outdir, outname, outext] = fileparts(output_filename);

  if (ischar(nfig) && strcmp(nfig,"all"))
    nfig = sort(get(0, "children"));
  endif

  nameo = cell(1, numel(nfig));

  unwind_protect
    for i=1:numel(nfig)
      nameo{i} = fullfile(outdir, sprintf("%s_%03d.pdf", outname, nfig(i)));
      err_cnt = int32(0);
      max_err = int32(10);

      do
        if (verbose)
          fprintf(stderr, "file \"%s\" is created ...\n", nameo{i});
        endif

        unlink(nameo{i});

        print(nfig(i), "-dpdf", "-color", "-landscape", "-fillpage", nameo{i});

        [info, err] = stat(nameo{i});

        if (err ~= 0)
          if (++err_cnt > max_err)
            func = @error;
          else
            func = @warning;
          endif

          feval(func, "failed to create file \"%s\"", nameo{i});
        endif
      until (err == 0);
    endfor

    if (single_file)
      if (0 ~= pdf_merge(nameo, output_filename, verbose))
        delete_tmp_files = false;
      endif
    endif
  unwind_protect_cleanup
    if (delete_tmp_files)
      for i=1:numel(nameo)
        if (ischar(nameo{i}))
          unlink(nameo{i});
        endif
      endfor
    endif
  end_unwind_protect
endfunction

%!test
%! output_name = "";
%! h = zeros(1, 2);
%! unwind_protect
%! output_name = [tempname(), ".pdf"];
%! h(1) = figure("visible","off");
%! sombrero();
%! h(2) = figure("visible","off");
%! peaks();
%! for i=1:numel(h)
%!   graphics_toolkit(h, "gnuplot");
%! endfor
%! pdf_create(h, output_name);
%! unwind_protect_cleanup
%! if (numel(output_name))
%!   [err] = unlink(output_name);
%!   assert(err, 0);
%! endif
%! for i=1:numel(h)
%!  if(isfigure(h(i)))
%!   close(h(i));
%!  endif
%! endfor
%! end_unwind_protect

%!demo
%! output_name = "";
%! y = rand(3, 5);
%! h = zeros(1, rows(y));
%! unwind_protect
%! output_name = tempname();
%! for i=1:rows(y)
%!   h(i) = figure("visible","off");
%!   graphics_toolkit(h(i), "gnuplot");
%!   plot(y(i, :), sprintf("-;y%d;%d", i, i));
%! endfor
%! pdf_create(h, output_name);
%! unwind_protect_cleanup
%! if (numel(output_name))
%!   err = unlink([output_name, ".pdf"]);
%!   assert(err, 0);
%! endif
%! for i=1:numel(h)
%!  if(isfigure(h(i)))
%!   close(h(i));
%!  endif
%! endfor
%! end_unwind_protect
