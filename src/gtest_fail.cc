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
#include <memory>
#include <vector>

// PKG_ADD: autoload ("gtest_fail", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("gtest_fail", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD (gtest_fail, args, nargout,
          "-*- texinfo -*-\n"
           "@deftypefn {} gtest_fail(@{last_err})\n\n"
           "Pass exception information to the GoogleTest library (e.g. to be used in assert_simple)\n\n"
           "@example\n"
           "gtest_fail(lasterror())\n"
           "@end example\n"
           "@end deftypefn\n")
{
     if (args.length() != 1) {
          print_usage();
          return octave_value_list();
     }

     const octave_scalar_map last_err = args(0).scalar_map_value();
     const std::string message = last_err.getfield("message").string_value();
     const octave_map stack = last_err.getfield("stack").map_value();

     const Cell file = stack.getfield("file");
     const Cell line = stack.getfield("line");
     const Cell column = stack.getfield("column");

     std::vector<std::unique_ptr<testing::ScopedTrace>> rgTrace;

     rgTrace.reserve(stack.numel());

     for (octave_idx_type i = 0; i < stack.numel(); ++i) {
          rgTrace.push_back(std::unique_ptr<testing::ScopedTrace>(new testing::ScopedTrace(file(i).string_value().c_str(), line(i).int_value(), column(i).int_value())));
     }

     SCOPED_TRACE("gtest_fail");

     const std::string file0 = file.isempty() ? std::string(__FILE__) : file(0).string_value();
     const int line0 = line.isempty() ? __LINE__ : line(0).int_value();

     ADD_FAILURE_AT(file0.c_str(), line0) << message;

     return octave_value_list();
}
