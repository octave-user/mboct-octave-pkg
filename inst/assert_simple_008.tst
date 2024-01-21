## assert_simple.m:08
%!test
%! try
%!   assert_simple (complex (Inf, 0.2), complex (-Inf, 0.2 + 2*eps), eps);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 3)
%!     error ("Too many errors reported for Inf assert");
%!   elseif (strfind (errmsg, "Abs err"))
%!     error ("Abs err reported for Inf assert");
%!   endif
%! end_try_catch
%!error <Abs err> assert (complex (Inf, 0.2), complex (Inf, 0.2 + 2*eps), eps)
%!assert ("dog", "dog")
%!error <Strings don't match> assert_simple ("dog", "cat")
%!error <Expected string, but observed number> assert_simple (3, "dog")
%!error <Class char != double> assert_simple ("dog", [3 3 3])
%!error <Expected string, but observed cell> assert_simple ({"dog"}, "dog")
%!error <Expected string, but observed struct> assert_simple (struct ("dog", 3), "dog")
%!error <Expected cell, but observed double> assert_simple (1, {1})
%!error <Dimensions don't match> assert_simple (cell (1,2,3), cell (3,2,1))
