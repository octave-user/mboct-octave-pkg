## assert_simple.m:10
%!test
%! x = {[3], [1,2,3]; 100+100*eps, "dog"};
%! y = x;
%! assert_simple (x, y);
%! y = x; y(1,1) = [2];
%! fail ("assert_simple (x, y)");
%! y = x; y(1,2) = [0, 2, 3];
%! fail ("assert_simple (x, y)");
%! y = x; y(2,1) = 101;
%! fail ("assert_simple (x, y)");
%! y = x; y(2,2) = "cat";
%! fail ("assert_simple (x, y)");
%! y = x; y(1,1) = [2];  y(1,2) = [0, 2, 3]; y(2,1) = 101; y(2,2) = "cat";
%! fail ("assert_simple (x, y)");
%!error <Expected struct, but observed double> assert_simple (1, struct ("a", 1))
%!error <Structure sizes don't match>
%! x(1,2,3).a = 1;
%! y(1,2).a = 1;
%! assert_simple (x,y);
%!error <Structure sizes don't match>
%! x(1,2,3).a = 1;
%! y(3,2,2).a = 1;
%! assert_simple (x,y);
%!error <Structure sizes don't match>
%! x.a = 1;
%! x.b = 1;
%! y.a = 1;
%! assert_simple (x,y);
%!error <Structure fieldname mismatch>
%! x.b = 1;
%! y.a = 1;
%! assert_simple (x,y);
