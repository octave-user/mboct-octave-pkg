## error_report.m:02
%!demo
%! try
%!   x = 1:3;
%!   x(-1) = 5;
%! catch
%!   error_report(lasterror(), stderr);
%! end_try_catch
