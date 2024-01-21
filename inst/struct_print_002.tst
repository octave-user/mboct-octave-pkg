## struct_print.m:02
%!demo
%! data.x = 1;
%! data.A = rand(1, 2);
%! data.str = "abc";
%! data.s = struct("a",{1,2,3},"b",{4,5,6});
%! data.args(1).y = {1, 2};
%! data.args(2).y.f = {@sin, @cos};
%! struct_print(data);
