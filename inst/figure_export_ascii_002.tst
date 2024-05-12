## figure_export_ascii.m:02
%!test
%! try
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp(fullfile(tempdir(), "figure_export_ascii_XXXXXX"), true);
%! for i=1:5
%!  hfig(end + 1) = figure("visible", "off");
%!  for j=1:2
%!    subplot(2, 1, j);
%!    plot(1:10,rand(1, 10), sprintf("-;rand(%d);", i));
%!    xlabel("x");
%!    ylabel("y");
%!    title(sprintf("test figure %d axes %d", i, j));
%!  endfor
%! endfor
%! fclose(fd);
%! figure_export_ascii(hfig, output_file, 1);
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    [~] = unlink(output_file);
%!  endif
%! end_unwind_protect
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
