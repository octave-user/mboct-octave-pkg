## assert_simple.m:09
%!test
%! x = {{{1}}, 2};  # cell with multiple levels
%! y = x;
%! assert_simple (x,y);
%! y{1}{1}{1} = 3;
%! fail ("assert_simple (x,y)");
%!assert (@sin, @sin)
%!error <Function handles don't match> assert_simple (@sin, @cos)
%!error <Expected function handle, but observed double> assert_simple (pi, @cos)
%!error <Class function_handle != double> assert_simple (@sin, pi)
