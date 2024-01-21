## struct_sizeof.m:01
%!demo
%! s1(1).x = 1;
%! s1(2).x = 2;
%! s1(1).y.z = rand(3, 3);
%! s1(2).y.z = rand(3, 100);
%! s1(1).y.v = "1234";
%! s1(2).y.v = "56478";
%! s1(1).y.w = zeros(2^10, 2^10, "int8");
%! s1(2).y.w = zeros(2 * 2^10, 2^10, "int8");
%! s1(2).y.s2 = s1;
%! struct_sizeof(s1);
%!error struct_sizeof()
%!error struct_sizeof(1,2,3)
