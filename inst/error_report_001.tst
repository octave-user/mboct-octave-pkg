## error_report.m:01
%!test
%! try
%! try
%!   x = 1:3;
%!   x(-1) = 5;
%! catch
%!   fd = -1;
%!   unwind_protect
%!     [fd, fname] = mkstemp(fullfile(tempdir(), "error_report_XXXXXX"), true);
%!     error_report(lasterror(), fd);
%!   unwind_protect_cleanup
%!     if (fd ~= -1)
%!       fclose(fd);
%!       [~] = unlink(fname);
%!     endif
%!  end_unwind_protect
%! end_try_catch
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
