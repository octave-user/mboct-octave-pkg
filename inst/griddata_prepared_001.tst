## griddata_prepared.m:01
%!test
%! try
%! state = rand("state");
%! unwind_protect
%! rand("seed", 0);
%! for k=1:100
%! x = linspace(-pi, pi, 11);
%! y = linspace(-pi, pi, 13);
%! [xx, yy] = meshgrid(x, y);
%! f = @(xx, yy) xx * 2 + yy * 3 + 5;
%! zz = f(xx, yy);
%! xi = pi * (2 * rand(3, 5) - 1);
%! yi = pi * (2 * rand(3, 5) - 1);
%! tri = delaunay(xx, yy);
%! zi = griddata_prepared(xx, yy, zz, xi, yi, tri, "linear/nearest");
%! zref = f(xi, yi);
%! tol = eps^0.9;
%! assert(zi, zref, tol * norm(zref));
%! endfor
%! unwind_protect_cleanup
%! rand("state", state);
%! end_unwind_protect
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
