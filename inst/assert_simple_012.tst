## assert_simple.m:12
%!test
%! x = [-40:0];
%! y1 = (10.^x).*(10.^x);
%! y2 = 10.^(2*x);
%! ## Increase tolerance from eps (y1) to 4*eps (y1) because of an upstream bug
%! ## in mingw-w64: https://sourceforge.net/p/mingw-w64/bugs/466/
%! assert_simple (y1, y2, 4*eps (y1));
%! fail ("assert_simple (y1, y2 + eps*1e-70, eps (y1))");
