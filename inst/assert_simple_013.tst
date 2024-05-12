## assert_simple.m:13
%!test
%! try
%! x = [1 2; 3 4];
%! y = [0 -1; 1 2];
%! tol = [-0.1 0; -0.2 0.3];
%! try
%!   assert_simple (x, y, tol);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 6)
%!     error ("Incorrect number of errors reported");
%!   endif
%!   assert_simple (! isempty (regexp (errmsg, '\(1,2\).*Abs err 3 exceeds tol 0\>')));
%!   assert_simple (! isempty (regexp (errmsg, '\(2,2\).*Abs err 2 exceeds tol 0.3')));
%!   assert_simple (! isempty (regexp (errmsg, '\(1,1\).*Abs err 1 exceeds tol 0.1')));
%!   assert_simple (! isempty (regexp (errmsg, '\(2,1\).*Rel err 2 exceeds tol 0.2')));
%! end_try_catch
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!test
%! try
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
