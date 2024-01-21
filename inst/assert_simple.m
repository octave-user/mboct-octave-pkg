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

