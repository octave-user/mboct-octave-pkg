## run_parallel.m:01
%!test
%! try
%! for r=[true,false]
%! for Phi=0:pi/2:pi
%! for v=[true,false]
%! x = linspace(0, 2 * pi, 100);
%! f = @(i, x, Phi) sin(x(i) + Phi);
%! opt.number_of_parameters = numel(x);
%! opt.number_of_processors = 4;
%! opt.verbose = false;
%! opt.reuse_subprocess=r;
%! opt.verbose = v;
%! y = run_parallel(opt, f, x, Phi);
%! assert([y{:}], sin(x + Phi));
%! endfor
%! endfor
%! endfor
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
