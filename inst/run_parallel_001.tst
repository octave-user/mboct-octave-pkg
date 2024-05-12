## run_parallel.m:01
%!test
%! try
%! for Phi=0:pi/2:pi
%! x = linspace(0, 2 * pi, 10000);
%! f = @(i, x, Phi) sin(x(i) + Phi);
%! opt.number_of_parameters = numel(x);
%! opt.number_of_processors = 4;
%! y = run_parallel(opt, f, x, Phi);
%! assert([y{:}], sin(x + Phi));
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
