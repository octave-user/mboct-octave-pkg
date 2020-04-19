## Copyright (C) 1999-2019 Kai Habel
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

## Author:      Kai Habel <kai.habel@gmx.de>
## Adapted-by:  Alexander Barth <barth.alexander@gmail.com>
##              xi and yi are not "meshgridded" if both are vectors
##              of the same size (for compatibility)
## Adapted-by:  Reinhard <octave-user@a1.net> allow multiple calls without having to
##              rebuild the delaunay triangulation for each call.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{zi} =} griddata_prepared (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{tri})
## @deftypefnx {} {@var{zi} =} griddata_prepared (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{tri}, @var{method})
## @deftypefnx {} {[@var{xi}, @var{yi}, @var{zi}] =} griddata_prepared (@dots{})
##
## This is an optimized variant of Octave's builtin griddata function where the triangulation has to be performed only once.
##
## @var{tri} @dots{} triangulation data returned from delaunay
##
## @seealso{griddata, delaunay}
## @end deftypefn

function [rx, ry, rz] = griddata_prepared (x, y, z, xi, yi, tri, method)
  if (nargin < 6 || nargin > 7)
    print_usage ();
  endif

  if (nargin < 7)
    method = "linear";
  endif
  
  if (ischar (method))
    method = tolower (method);
  endif

  ## Meshgrid if x and y are vectors but z is matrix
  if (isvector (x) && isvector (y) && all ([numel(y), numel(x)] == size (z)))
    [x, y] = meshgrid (x, y);
  endif

  if (isvector (x) && isvector (y) && isvector (z))
    if (! isequal (length (x), length (y), length (z)))
      error ("griddata_prepared: X, Y, and Z must be vectors of the same length");
    endif
  elseif (! size_equal (x, y, z))
    error ("griddata_prepared: lengths of X, Y must match the columns and rows of Z");
  endif

  ## Meshgrid xi and yi if they are a row and column vector.
  if (rows (xi) == 1 && columns (yi) == 1)
    [xi, yi] = meshgrid (xi, yi);
  elseif (isvector (xi) && isvector (yi))
    ## Otherwise, convert to column vectors
    xi = xi(:);
    yi = yi(:);
  endif

  if (! size_equal (xi, yi))
    error ("griddata_prepared: XI and YI must be vectors or matrices of same size");
  endif

  if (! ismatrix(tri) || columns(tri) != 3)
    error("griddata_prep_prep: tri is not a valid triangulation");
  endif
  
  x = x(:);
  y = y(:);
  z = z(:);

  zi = NaN (size (xi));

  switch (method)
    case "cubic"
    error ("griddata_prepared: cubic interpolation not yet implemented");
  case "nearest"
    ## Search index of nearest point.
    idx = dsearch (x, y, tri, xi, yi);
    valid = ! isnan (idx);
    zi(valid) = z(idx(valid));

  case {"linear", "linear/nearest"}  
    ## Search for every point the enclosing triangle.
    tri_list = tsearch (x, y, tri, xi(:), yi(:));

    ## Only keep the points within triangles.
    valid = ! isnan (tri_list);

    switch (method)
      case "linear/nearest"
	if (any(! valid))
	  ## Use "nearest" if "linear" failed!
	  idx = dsearch (x, y, tri, xi(:), yi(:));
	  valid_near = ! isnan (idx);
	  zi(valid_near) = z(idx(valid_near));
	endif    
    endswitch
    
    tri_list = tri_list(valid);
    nr_t = rows (tri_list);

    tri = tri(tri_list,:);

    ## Assign x,y,z for each point of triangle.
    x1 = x(tri(:,1));
    x2 = x(tri(:,2));
    x3 = x(tri(:,3));

    y1 = y(tri(:,1));
    y2 = y(tri(:,2));
    y3 = y(tri(:,3));

    z1 = z(tri(:,1));
    z2 = z(tri(:,2));
    z3 = z(tri(:,3));

    ## Calculate norm vector.
    N = cross ([x2-x1, y2-y1, z2-z1], [x3-x1, y3-y1, z3-z1]);
    ## Normalize.
    N = diag (norm (N, "rows")) \ N;

    ## Calculate D of plane equation
    ## Ax+By+Cz+D = 0;
    D = -(N(:,1) .* x1 + N(:,2) .* y1 + N(:,3) .* z1);

    ## Calculate zi by solving plane equation for xi, yi.
    zi(valid) = -(N(:,1).*xi(:)(valid) + N(:,2).*yi(:)(valid) + D) ./ N(:,3);

  otherwise
    error ("griddata_prepared: unknown interpolation METHOD");
  endswitch

  if (nargout > 1)
    rx = xi;
    ry = yi;
    rz = zi;
  else
    rx = zi;
  endif

endfunction

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
