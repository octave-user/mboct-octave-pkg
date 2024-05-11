## Copyright (C) 2023(-2024) Reinhard <octave-user@a1.net>
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
## @deftypefn  {FunctionFile} @var{old_handler} assert_handler (@var{new_handler})
##
## Get or set a handler which should be called if assert fails.
## @end deftypefn

function fn = assert_handler(handler_fn)
  persistent handler_func = [];

  if (nargin > 1 || nargout > 1)
    print_usage();
  endif

  if (nargin >= 1)
    handler_func = handler_fn;
  endif

  if (isempty(handler_func))
    handler_func = @gtest_fail;
  endif

  fn = handler_func;
endfunction
