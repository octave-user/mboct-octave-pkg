## assert_simple.m:01
%!test
%! try
%! N = 1000;
%! for i=1:100
%!   A = rand(N, N);
%!   B = rand(N, N);
%!   if (max(max(abs(A - B))) == 0)
%!     continue;
%!   endif
%!   fail("assert_simple(A, B, 0)");
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!error assert_simple ([])
%!error assert_simple ("")
%!error assert_simple ({})
%!error assert_simple (struct ([]))
%!assert (zeros (3,0), zeros (3,0))
%!error <O\(3x0\)\s+E\(0x2\)> assert_simple (zeros (3,0), zeros (0,2))
%!error <Dimensions don't match> assert_simple (zeros (3,0), [])
%!error <Dimensions don't match> assert_simple (zeros (2,0,2), zeros (2,0))
%!assert (isempty ([]))
%!assert (1)
%!error assert_simple (0)
%!assert (ones (3,1))
%!assert (ones (1,3))
%!assert (ones (3,4))
%!error assert_simple ([1,0,1])
%!error assert_simple ([1;1;0])
%!error assert_simple ([1,0;1,1])
%!error <2-part error> assert_simple (false, "%s %s", "2-part", "error")
%!error <2-part error> assert_simple (false, "TST:msg_id", "%s %s", "2-part", "error")
%!error <Dimensions don't match> assert_simple (3, [3,3])
%!error <Dimensions don't match> assert_simple (3, [3,3; 3,3])
%!error <Dimensions don't match> assert_simple ([3,3; 3,3], 3)
%!assert (3, 3)
%!error <Abs err 1 exceeds tol> assert_simple (3, 4)
%!assert (3+eps, 3, eps)
%!assert (3, 3+eps, eps)
%!error <Abs err 4.4409e-0?16 exceeds tol> assert_simple (3+2*eps, 3, eps)
%!error <Abs err 4.4409e-0?16 exceeds tol> assert_simple (3, 3+2*eps, eps)
%!assert ([1,2,3],[1,2,3])
%!assert ([1;2;3],[1;2;3])
%!error <Abs err 1 exceeds tol 0> assert_simple ([2,2,3,3],[1,2,3,4])
%!error <Abs err 1 exceeds tol 0.5> assert_simple ([2,2,3,3],[1,2,3,4],0.5)
%!error <Rel err 1 exceeds tol 0.1> assert_simple ([2,2,3,5],[1,2,3,4],-0.1)
%!error <Abs err 1 exceeds tol 0> assert_simple ([6;6;7;7],[5;6;7;8])
%!error <Abs err 1 exceeds tol 0.5> assert_simple ([6;6;7;7],[5;6;7;8],0.5)
%!error <Rel err .* exceeds tol 0.1> assert_simple ([6;6;7;7],[5;6;7;8],-0.1)
%!error <Dimensions don't match> assert_simple ([1,2,3],[1;2;3])
%!error <Dimensions don't match> assert_simple ([1,2],[1,2,3])
%!error <Dimensions don't match> assert_simple ([1;2;3],[1;2])
%!assert ([1,2;3,4],[1,2;3,4])
%!error assert_simple ([1,4;3,4],[1,2;3,4])
%!error <Dimensions don't match> assert_simple ([1,3;2,4;3,5],[1,2;3,4])
%!error assert_simple(2 == 1);
%!error assert_simple(2, 1);
%!error assert_simple(2, 1, eps);
%!error assert_simple(ones(3,3), zeros(3,3), eps);
