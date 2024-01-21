## assert_simple.m:04
%!test  assert_simple (0.1+eps, 0.1, 2*eps);
%!error <Rel err 2.2204e-0?15 exceeds tol> assert_simple (0.1+eps, 0.1, -2*eps)
