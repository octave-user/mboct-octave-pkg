## figure_export_ascii.m:03
%!demo
%! try
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp(fullfile(tempdir(), "figure_export_ascii_XXXXXX"), true);
%! x = linspace(0, 2 * pi, 10);
%! y = [sin(x); cos(x)];
%! for i=1:rows(y)
%!   hfig(end + 1) = figure("visible", "off");
%!   for j=1:2
%!     subplot(2, 1, j);
%!     hold on;
%!     for k=1:2
%!       plot(x, y(i, :), sprintf("-;y%d=f%d(x%d);1", i, j, k));
%!     endfor
%!     xlabel("x");
%!     ylabel("y");
%!     title(sprintf("figure(%d) axes(%d)", i, j));
%!   endfor
%! endfor
%! figure_export_ascii(hfig, output_file, 2);
%! spawn_wait(spawn("cat", {output_file}));
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    fclose(fd);
%!    [~] = unlink(output_file);
%!  endif
%! end_unwind_protect
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
