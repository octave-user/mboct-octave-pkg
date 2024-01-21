## assert_simple.m:05
%!test  assert_simple (100+100*eps, 100, -2*eps);
%!error <Abs err 2.8422e-0?14 exceeds tol> assert_simple (100+100*eps, 100, 2*eps)
%!error <Abs err 2 exceeds tol 0.1> assert_simple (2, 0, -0.1)
%!error <Class single != double> assert_simple (single (1), 1)
%!error <Class uint8 != uint16> assert_simple (uint8 (1), uint16 (1))
%!error <sparse != non-sparse> assert_simple (sparse([1]), [1])
%!error <non-sparse != sparse> assert_simple ([1], sparse([1]))
%!error <complex != real> assert_simple (1+i, 1)
%!error <real != complex> assert_simple (1, 1+i)
%!assert ([NaN, NA, Inf, -Inf, 1+eps, eps], [NaN, NA, Inf, -Inf, 1, 0], eps)
%!error <'NaN' mismatch> assert_simple (NaN, 1)
%!error <'NaN' mismatch> assert_simple ([NaN 1], [1 NaN])
