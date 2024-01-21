## assert_simple.m:14
%!test <*57615>
%! try
%!   assert_simple (complex (pi*1e-17,2*pi), 0, 1e-1);
%! catch
%!   errmsg = lasterr ();
%!   assert_simple (isempty (strfind (errmsg, "sprintf: invalid field width")));
%! end_try_catch
%!error <Invalid call> assert_simple ()
%!error <Invalid call> assert_simple (1,2,3,4)
