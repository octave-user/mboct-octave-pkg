## assert_simple.m:07
%!test
%! try
%! try
%!   assert_simple ([NA 1]', [1 NA]');
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 4)
%!     error ("Too many errors reported for NA assert");
%!   elseif (strfind (errmsg, "NaN"))
%!     error ("NaN reported for NA assert");
%!   elseif (strfind (errmsg, "Abs err NA exceeds tol 0"))
%!     error ("Abs err reported for NA assert");
%!   endif
%! end_try_catch
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!error assert_simple ([(complex (NA, 1)) (complex (2, NA))], [(complex (NA, 2)) 2])
%!error <'Inf' mismatch> assert_simple (-Inf, Inf)
%!error <'Inf' mismatch> assert_simple ([-Inf Inf], [Inf -Inf])
%!test
%! try
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
