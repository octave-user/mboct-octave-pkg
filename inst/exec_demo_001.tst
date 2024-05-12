## exec_demo.m:01
%!test
%! try
%! exec_demo(which("exec_demo_001.tst"), 2, 1, "test");
%! assert(evalin("base", "__exec_demo_x"), 1);
%! assert(evalin("base", "__exec_demo_y"), 2);
%! assert(evalin("base", "__exec_demo_z"), 3);
%! evalin("base", "clear __exec_demo_x __exec_demo_y __exec_demo_z");

%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!test
%! try
%! __exec_demo_x = 1;
%! __exec_demo_y = 2;
%! __exec_demo_z = 3;

%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!test
%! try
%! exec_demo(which("exec_demo"), 1, 1, "test");
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
