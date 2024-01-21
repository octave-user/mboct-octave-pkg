## griddata_prepared.m:01
%!test
%! state = rand("state");
%! unwind_protect
%! rand("seed", 0);
%! for k=1:100
%! x = linspace(-pi, pi, 10);
%! y = linspace(-pi, pi, 15);
%! [xx, yy] = meshgrid(x, y);
%! zz = sin(xx.^2 + yy.^2) ./ (xx.^2 + yy.^2);
%! xi = 2 * pi * (2 * rand(3, 5) - 1);
%! yi = 2 * pi * (2 * rand(3, 5) - 1);
%! tri = delaunay(xx, yy);
%! zi = griddata_prepared(xx, yy, zz, xi, yi, tri, "linear/nearest");
%! zn = griddata(xx, yy, zz, xi, yi, "nearest");
%! zl = griddata(xx, yy, zz, xi, yi, "linear");
%! for i=1:rows(xi)
%!  for j=1:columns(xi)
%!    if (xi(i, j) >= min(x) && xi(i, j) <= max(x) && yi(i, j) >= min(y) && yi(i, j) <= max(y))
%!      assert(zi(i, j), zl(i, j));
%!    else
%!      assert(zi(i, j), zn(i, j));
%!    endif
%!  endfor
%! endfor
%! endfor
%! unwind_protect_cleanup
%! rand("state", state);
%! end_unwind_protect
