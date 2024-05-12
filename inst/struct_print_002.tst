## struct_print.m:02
%!demo
%! try
%! data.x = 1;
%! data.A = rand(1, 2);
%! data.str = "abc";
%! data.s = struct("a",{1,2,3},"b",{4,5,6});
%! data.args(1).y = {1, 2};
%! data.args(2).y.f = {@sin, @cos};
%! struct_print(data);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
