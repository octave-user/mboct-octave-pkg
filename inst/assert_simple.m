## Copyright (C) 2023(-2023) Reinhard <octave-user@a1.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} assert_simple (@var{cond})
## @deftypefnx {} {} assert_simple (@var{cond}, @var{errmsg})
## @deftypefnx {} {} assert_simple (@var{cond}, @var{errmsg}, @dots{})
## @deftypefnx {} {} assert_simple (@var{cond}, @var{msg_id}, @var{errmsg}, @dots{})
## @deftypefnx {} {} assert_simple (@var{observed}, @var{expected})
## @deftypefnx {} {} assert_simple (@var{observed}, @var{expected}, @var{tol})
##
## Produce an error if the specified condition is not met.
## The reason why we cannot just call assert is, that assert might be excessively slow in some situations.
## For that reason, assert may break a whole testsuite just because a single assertion fails and the error message becomes too long.
##
## @code{assert_simple} can be called in three different ways.
##
## @table @code
## @item  assert_simple (@var{cond})
## @itemx assert_simple (@var{cond}, @var{errmsg})
## @itemx assert_simple (@var{cond}, @var{errmsg}, @dots{})
## @itemx assert_simple (@var{cond}, @var{msg_id}, @var{errmsg}, @dots{})
## Called with a single argument @var{cond}, @code{assert_simple} produces an error if
## @var{cond} is false (numeric zero).
##
## Any additional arguments are passed to the @code{error} function for
## processing.
##
## @item assert_simple (@var{observed}, @var{expected})
## Produce an error if observed is not the same as expected.
##
## Note that @var{observed} and @var{expected} can be scalars, vectors,
## matrices, strings, cell arrays, or structures.
##
## @item assert_simple (@var{observed}, @var{expected}, @var{tol})
## Produce an error if observed is not the same as expected but equality
## comparison for numeric data uses a tolerance @var{tol}.
##
## If @var{tol} is positive then it is an absolute tolerance which will produce
## an error if @code{abs (@var{observed} - @var{expected}) > abs (@var{tol})}.
##
## If @var{tol} is negative then it is a relative tolerance which will produce
## an error if @code{abs (@var{observed} - @var{expected}) >
## abs (@var{tol} * @var{expected})}.
##
## If @var{expected} is zero @var{tol} will always be interpreted as an
## absolute tolerance.
##
## If @var{tol} is not scalar its dimensions must agree with those of
## @var{observed} and @var{expected} and tests are performed on an
## element-by-element basis.
## @end table
## @seealso{assert}
## @end deftypefn

function assert_simple(varargin)
  switch (nargin)
    case {2, 3}
    otherwise
      real_assert(varargin{:});
      return
  endswitch

  observed = varargin{1};
  expected = varargin{2};

  if (nargin >= 3)
    tolerance = varargin{3};
  else
    tolerance = 0;
  endif

  size_observed = size(observed);
  size_expected = size(expected);

  size_test = size(size_observed) == size(size_expected) && isscalar(tolerance) && all(size_observed == size_expected);
  class_test = strcmp(class(observed), class(expected));
  numeric_test = isnumeric(observed) && isnumeric(expected);
  sparse_test = issparse(observed) == issparse(expected);
  scalar_test = ~(isscalar(observed) && isscalar(expected));

  if (numeric_test)
    finite_test = really_all(isfinite(observed) && isfinite(expected));
  else
    finite_test = true;
  endif

  tol_test = tolerance >= 0;

  if (~(scalar_test && tol_test && size_test && class_test && numeric_test && sparse_test && finite_test))
    real_assert(varargin{:});
    return;
  endif

  difference = really_max(abs(observed - expected));

  if (difference > tolerance)
    error("Abs err %.5g exceeds tol %.5g", difference, tolerance);
  endif
endfunction

function flag = really_all(x)
  flag = x;

  while (~isscalar(flag))
    flag = all(flag);
  endwhile
endfunction

function maxx = really_max(x)
  maxx = x;

  while (~isscalar(maxx))
    maxx = max(maxx);
  endwhile
endfunction

function real_assert(varargin)
  err = [];
  try
    assert(varargin{:});
  catch
    err = lasterror();
  end_try_catch

  if (~isempty(err))
    rethrow(err);
  endif
endfunction

%!test
%! N = 1000;
%! for i=1:100
%!   A = rand(N, N);
%!   B = rand(N, N);
%!   if (max(max(abs(A - B))) == 0)
%!     continue;
%!   endif
%!   fail("assert_simple(A, B, 0)");
%! endfor

## empty input
%!error assert_simple ([])
%!error assert_simple ("")
%!error assert_simple ({})
%!error assert_simple (struct ([]))
%!assert (zeros (3,0), zeros (3,0))
%!error <O\(3x0\)\s+E\(0x2\)> assert_simple (zeros (3,0), zeros (0,2))
%!error <Dimensions don't match> assert_simple (zeros (3,0), [])
%!error <Dimensions don't match> assert_simple (zeros (2,0,2), zeros (2,0))

## conditions
%!assert (isempty ([]))
%!assert (1)
%!error assert_simple (0)
%!assert (ones (3,1))
%!assert (ones (1,3))
%!assert (ones (3,4))
%!error assert_simple ([1,0,1])
%!error assert_simple ([1;1;0])
%!error assert_simple ([1,0;1,1])
%!error <2-part error> assert_simple (false, "%s %s", "2-part", "error")
%!error <2-part error> assert_simple (false, "TST:msg_id", "%s %s", "2-part", "error")

## scalars
%!error <Dimensions don't match> assert_simple (3, [3,3])
%!error <Dimensions don't match> assert_simple (3, [3,3; 3,3])
%!error <Dimensions don't match> assert_simple ([3,3; 3,3], 3)
%!assert (3, 3)
%!error <Abs err 1 exceeds tol> assert_simple (3, 4)
%!assert (3+eps, 3, eps)
%!assert (3, 3+eps, eps)
%!error <Abs err 4.4409e-0?16 exceeds tol> assert_simple (3+2*eps, 3, eps)
%!error <Abs err 4.4409e-0?16 exceeds tol> assert_simple (3, 3+2*eps, eps)

## vectors
%!assert ([1,2,3],[1,2,3])
%!assert ([1;2;3],[1;2;3])
%!error <Abs err 1 exceeds tol 0> assert_simple ([2,2,3,3],[1,2,3,4])
%!error <Abs err 1 exceeds tol 0.5> assert_simple ([2,2,3,3],[1,2,3,4],0.5)
%!error <Rel err 1 exceeds tol 0.1> assert_simple ([2,2,3,5],[1,2,3,4],-0.1)
%!error <Abs err 1 exceeds tol 0> assert_simple ([6;6;7;7],[5;6;7;8])
%!error <Abs err 1 exceeds tol 0.5> assert_simple ([6;6;7;7],[5;6;7;8],0.5)
%!error <Rel err .* exceeds tol 0.1> assert_simple ([6;6;7;7],[5;6;7;8],-0.1)
%!error <Dimensions don't match> assert_simple ([1,2,3],[1;2;3])
%!error <Dimensions don't match> assert_simple ([1,2],[1,2,3])
%!error <Dimensions don't match> assert_simple ([1;2;3],[1;2])

## matrices
%!assert ([1,2;3,4],[1,2;3,4])
%!error assert_simple ([1,4;3,4],[1,2;3,4])
%!error <Dimensions don't match> assert_simple ([1,3;2,4;3,5],[1,2;3,4])
%!test  # 2-D matrix
%! A = [1 2 3]'*[1,2];
%! assert_simple (A, A);
%! fail ("assert_simple (A.*(A!=2),A)");
%!test  # N-D matrix
%! X = zeros (2,2,3);
%! Y = X;
%! Y(1,2,3) = 1.5;
%! fail ("assert_simple (X,Y)");

## must give a small tolerance for floating point errors on relative
%!assert (100+100*eps, 100, -2*eps)
%!assert (100, 100+100*eps, -2*eps)
%!error <Rel err .* exceeds tol> assert_simple (100+300*eps, 100, -2*eps)
%!error <Rel err .* exceeds tol> assert_simple (100, 100+300*eps, -2*eps)

## test relative vs. absolute tolerances
%!test  assert_simple (0.1+eps, 0.1, 2*eps);
%!error <Rel err 2.2204e-0?15 exceeds tol> assert_simple (0.1+eps, 0.1, -2*eps)
%!test  assert_simple (100+100*eps, 100, -2*eps);
%!error <Abs err 2.8422e-0?14 exceeds tol> assert_simple (100+100*eps, 100, 2*eps)

## Corner case of relative tolerance with 0 divider
%!error <Abs err 2 exceeds tol 0.1> assert_simple (2, 0, -0.1)

## Extra checking of inputs when tolerance unspecified.
%!error <Class single != double> assert_simple (single (1), 1)
%!error <Class uint8 != uint16> assert_simple (uint8 (1), uint16 (1))
%!error <sparse != non-sparse> assert_simple (sparse([1]), [1])
%!error <non-sparse != sparse> assert_simple ([1], sparse([1]))
%!error <complex != real> assert_simple (1+i, 1)
%!error <real != complex> assert_simple (1, 1+i)

## exceptional values
%!assert ([NaN, NA, Inf, -Inf, 1+eps, eps], [NaN, NA, Inf, -Inf, 1, 0], eps)

%!error <'NaN' mismatch> assert_simple (NaN, 1)
%!error <'NaN' mismatch> assert_simple ([NaN 1], [1 NaN])
%!test
%! try
%!   assert_simple ([NaN 1], [1 NaN]);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 4)
%!     error ("Too many errors reported for NaN assert");
%!   elseif (strfind (errmsg, "NA"))
%!     error ("NA reported for NaN assert");
%!   elseif (strfind (errmsg, "Abs err NaN exceeds tol 0"))
%!     error ("Abs err reported for NaN assert");
%!   endif
%! end_try_catch

%!error <'NA' mismatch> assert_simple (NA, 1)
%!error assert_simple ([NA 1]', [1 NA]')
%!test
%! try
%!   assert_simple ([NA 1]', [1 NA]');
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 4)
%!     error ("Too many errors reported for NA assert");
%!   elseif (strfind (errmsg, "NaN"))
%!     error ("NaN reported for NA assert");
%!   elseif (strfind (errmsg, "Abs err NA exceeds tol 0"))
%!     error ("Abs err reported for NA assert");
%!   endif
%! end_try_catch
%!error assert_simple ([(complex (NA, 1)) (complex (2, NA))], [(complex (NA, 2)) 2])

%!error <'Inf' mismatch> assert_simple (-Inf, Inf)
%!error <'Inf' mismatch> assert_simple ([-Inf Inf], [Inf -Inf])
%!test
%! try
%!   assert_simple (complex (Inf, 0.2), complex (-Inf, 0.2 + 2*eps), eps);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 3)
%!     error ("Too many errors reported for Inf assert");
%!   elseif (strfind (errmsg, "Abs err"))
%!     error ("Abs err reported for Inf assert");
%!   endif
%! end_try_catch
%!error <Abs err> assert (complex (Inf, 0.2), complex (Inf, 0.2 + 2*eps), eps)

## strings
%!assert ("dog", "dog")
%!error <Strings don't match> assert_simple ("dog", "cat")
%!error <Expected string, but observed number> assert_simple (3, "dog")
%!error <Class char != double> assert_simple ("dog", [3 3 3])
%!error <Expected string, but observed cell> assert_simple ({"dog"}, "dog")
%!error <Expected string, but observed struct> assert_simple (struct ("dog", 3), "dog")

## cell arrays
%!error <Expected cell, but observed double> assert_simple (1, {1})
%!error <Dimensions don't match> assert_simple (cell (1,2,3), cell (3,2,1))
%!test
%! x = {{{1}}, 2};  # cell with multiple levels
%! y = x;
%! assert_simple (x,y);
%! y{1}{1}{1} = 3;
%! fail ("assert_simple (x,y)");

## function handles
%!assert (@sin, @sin)
%!error <Function handles don't match> assert_simple (@sin, @cos)
%!error <Expected function handle, but observed double> assert_simple (pi, @cos)
%!error <Class function_handle != double> assert_simple (@sin, pi)

%!test
%! x = {[3], [1,2,3]; 100+100*eps, "dog"};
%! y = x;
%! assert_simple (x, y);
%! y = x; y(1,1) = [2];
%! fail ("assert_simple (x, y)");
%! y = x; y(1,2) = [0, 2, 3];
%! fail ("assert_simple (x, y)");
%! y = x; y(2,1) = 101;
%! fail ("assert_simple (x, y)");
%! y = x; y(2,2) = "cat";
%! fail ("assert_simple (x, y)");
%! y = x; y(1,1) = [2];  y(1,2) = [0, 2, 3]; y(2,1) = 101; y(2,2) = "cat";
%! fail ("assert_simple (x, y)");

## structures
%!error <Expected struct, but observed double> assert_simple (1, struct ("a", 1))
%!error <Structure sizes don't match>
%! x(1,2,3).a = 1;
%! y(1,2).a = 1;
%! assert_simple (x,y);
%!error <Structure sizes don't match>
%! x(1,2,3).a = 1;
%! y(3,2,2).a = 1;
%! assert_simple (x,y);
%!error <Structure sizes don't match>
%! x.a = 1;
%! x.b = 1;
%! y.a = 1;
%! assert_simple (x,y);
%!error <Structure fieldname mismatch>
%! x.b = 1;
%! y.a = 1;
%! assert_simple (x,y);

%!test
%! x.a = 1; x.b=[2, 2];
%! y.a = 1; y.b=[2, 2];
%! assert_simple (x, y);
%! y.b=3;
%! fail ("assert_simple (x, y)");
%! fail ("assert_simple (3, x)");
%! fail ("assert_simple (x, 3)");
%! ## Empty structures
%! x = resize (x, 0, 1);
%! y = resize (y, 0, 1);
%! assert_simple (x, y);

## vector of tolerances
%!test
%! x = [-40:0];
%! y1 = (10.^x).*(10.^x);
%! y2 = 10.^(2*x);
%! ## Increase tolerance from eps (y1) to 4*eps (y1) because of an upstream bug
%! ## in mingw-w64: https://sourceforge.net/p/mingw-w64/bugs/466/
%! assert_simple (y1, y2, 4*eps (y1));
%! fail ("assert_simple (y1, y2 + eps*1e-70, eps (y1))");

## Multiple tolerances
%!test
%! x = [1 2; 3 4];
%! y = [0 -1; 1 2];
%! tol = [-0.1 0; -0.2 0.3];
%! try
%!   assert_simple (x, y, tol);
%! catch
%!   errmsg = lasterr ();
%!   if (sum (errmsg () == "\n") != 6)
%!     error ("Incorrect number of errors reported");
%!   endif
%!   assert_simple (! isempty (regexp (errmsg, '\(1,2\).*Abs err 3 exceeds tol 0\>')));
%!   assert_simple (! isempty (regexp (errmsg, '\(2,2\).*Abs err 2 exceeds tol 0.3')));
%!   assert_simple (! isempty (regexp (errmsg, '\(1,1\).*Abs err 1 exceeds tol 0.1')));
%!   assert_simple (! isempty (regexp (errmsg, '\(2,1\).*Rel err 2 exceeds tol 0.2')));
%! end_try_catch

%!test <*57615>
%! try
%!   assert_simple (complex (pi*1e-17,2*pi), 0, 1e-1);
%! catch
%!   errmsg = lasterr ();
%!   assert_simple (isempty (strfind (errmsg, "sprintf: invalid field width")));
%! end_try_catch

## test input validation
%!error <Invalid call> assert_simple ()
%!error <Invalid call> assert_simple (1,2,3,4)
