## assert_simple.m:06
%!test
%! try
%! try
%!   assert_simple ([NaN 1], [1 NaN]);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 4)
%!     error ("Too many errors reported for NaN assert");
%!   elseif (strfind (errmsg, "NA"))
%!     error ("NA reported for NaN assert");
%!   elseif (strfind (errmsg, "Abs err NaN exceeds tol 0"))
%!     error ("Abs err reported for NaN assert");
%!   endif
%! end_try_catch
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!error <'NA' mismatch> assert_simple (NA, 1)
%!error assert_simple ([NA 1]', [1 NA]')
%!test
%! try
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
