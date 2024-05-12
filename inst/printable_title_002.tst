## printable_title.m:02
%!demo
%! try
%! file_name = "output_data.dat";
%! figure("visible", "off");
%! plot(sin(0:0.05:2*pi));
%! title(printable_title(file_name));
%! figure_list();
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
