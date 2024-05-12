## run_parallel.m:02
%!demo
%! try
%! Phi = linspace(-pi, pi, 1000);
%! f = @(i, Phi) quadv(@(x) sin(x + Phi(i)).^2, 0, 2 * pi);
%! opt.number_of_parameters = numel(Phi);
%! opt.number_of_processors = 4;
%! tic();
%! y = run_parallel(opt, f, Phi);
%! tpar = toc();
%! tic();
%! yser = zeros(1, numel(Phi));
%! for i=1:numel(Phi)
%!   yser(i) = feval(f, i, Phi);
%! endfor
%! tser = toc();
%! assert([y{:}], yser);
%! fprintf(stderr, "serial time: %g\n", tser);
%! fprintf(stderr, "parallel time: %g\n", tpar);
%! fprintf(stderr, "speedup: %g\n", tser / tpar);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
