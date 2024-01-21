## assert_simple.m:11
%!test
%! x.a = 1; x.b=[2, 2];
%! y.a = 1; y.b=[2, 2];
%! assert_simple (x, y);
%! y.b=3;
%! fail ("assert_simple (x, y)");
%! fail ("assert_simple (3, x)");
%! fail ("assert_simple (x, 3)");
%! ## Empty structures
%! x = resize (x, 0, 1);
%! y = resize (y, 0, 1);
%! assert_simple (x, y);
