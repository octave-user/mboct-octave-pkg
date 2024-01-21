## assert_simple.m:03
%!test  # N-D matrix
%! X = zeros (2,2,3);
%! Y = X;
%! Y(1,2,3) = 1.5;
%! fail ("assert_simple (X,Y)");
%!assert (100+100*eps, 100, -2*eps)
%!assert (100, 100+100*eps, -2*eps)
%!error <Rel err .* exceeds tol> assert_simple (100+300*eps, 100, -2*eps)
%!error <Rel err .* exceeds tol> assert_simple (100, 100+300*eps, -2*eps)
