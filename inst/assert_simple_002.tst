## assert_simple.m:02
%!test  # 2-D matrix
%! A = [1 2 3]'*[1,2];
%! assert_simple (A, A);
%! fail ("assert_simple (A.*(A!=2),A)");
