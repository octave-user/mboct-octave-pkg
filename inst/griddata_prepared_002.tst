## griddata_prepared.m:02
%!demo
%! x = linspace(-pi, pi, 10);
%! y = linspace(-pi, pi, 15);
%! [xx, yy] = meshgrid(x, y);
%! tri = delaunay(xx, yy);
%! zz = sin(xx.^2 + yy.^2) ./ (xx.^2 + yy.^2);
%! xi = 2 * pi * (2 * rand(1, 5) - 1);
%! yi = 2 * pi * (2 * rand(1, 7) - 1);
%! tri = delaunay(xx, yy);
%! zi = zeros(numel(xi), numel(yi));
%! for i=1:numel(xi)
%!   for j=1:numel(yi)
%!     zi(i, j) = griddata_prepared(xx, yy, zz, xi(i), yi(j), tri, "linear/nearest");
%!   endfor
%! endfor
