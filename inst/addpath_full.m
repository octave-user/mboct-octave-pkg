## Copyright (C) 2015(-2020) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} addpath_full(@var{pathname})
##
## Add @var{pathname} to octave's search path as an absolute pathname.
## This function supports also shell expansions.
##
## @end deftypefn

function addpath_full(pathname)
  if (nargin ~= 1)
    print_usage();
  endif
  
  if (length(strfind(pathname, "~")))
    gpathname = glob(pathname);
    if (length(gpathname) > 0)
      for i=1:length(gpathname)
        addpath(make_absolute_filename(gpathname{i}));
      endfor
      return
    endif
  endif
  
  addpath(make_absolute_filename(pathname));
endfunction

