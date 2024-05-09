// Copyright (C) 2018(-2024) Reinhard <octave-user@a1.net>

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <gtest/gtest.h>

// PKG_ADD: autoload ("gtest_fail", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("gtest_fail", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD (gtest_fail, args, nargout,
          "-*- texinfo -*-\n"
           "@deftypefn {} gtest_fail(@var{expression}, @var{file}, @var{line})\n\n"
           "Pass exception information to the GoogleTest library (e.g. to be used in assert_simple)\n\n"
           "@example\n"
           "gtest_fail(lasterror().message, lasterror().stack(end).file, lasterror().stack(end).line)\n"
           "@end example\n"
           "@end deftypefn\n")
{
     if (args.length() != 3) {
          print_usage();
          return octave_value_list();
     }

     const std::string expression = args(0).string_value();
     const std::string file = args(1).string_value();
     const int line = args(2).int_value();

     ADD_FAILURE_AT(file.c_str(), line) << expression;

     return octave_value_list();
}
