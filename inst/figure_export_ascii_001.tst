## figure_export_ascii.m:01
%!test
%! hfig = [];
%! fd = -1;
%! unwind_protect
%! [fd, output_file] = mkstemp(fullfile(tempdir(), "figure_export_ascii_XXXXXX"), true);
%! for i=1:5
%!  hfig(end + 1) = figure("visible", "off");
%!  for j=1:2
%!    subplot(2, 1, j);
%!    hold("on");
%!    for k=1:2
%!      plot(1:10,rand(1, 10), sprintf("-;rand(%d, %d);", i, j));
%!    endfor
%!    xlabel("x");
%!    ylabel("y");
%!    title(sprintf("test figure %d axes %d", i, j));
%!  endfor
%! endfor
%! figure_export_ascii(hfig, fd, 2);
%! unwind_protect_cleanup
%!  for i=1:numel(hfig);
%!    close(hfig(i));
%!  endfor
%!  if (fd ~= -1)
%!    fclose(fd);
%!    [~] = unlink(output_file);
%!  endif
%! end_unwind_protect
