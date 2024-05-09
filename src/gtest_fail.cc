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
#include <vector>

// PKG_ADD: autoload ("gtest_fail", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("gtest_fail", "__mboct_octave_proc__.oct", "remove");

struct StackRecord {
     StackRecord(const std::string& filetmp = __FILE__, int linetmp = __LINE__, int columntmp = -1)
          :file(filetmp), line(linetmp), column(columntmp), trace(file.c_str(), line, column) {
     }

     StackRecord(const StackRecord& oRecord)
          :file(oRecord.file),
           line(oRecord.line),
           column(oRecord.column),
           trace(file.c_str(), line, column) {
     }

     const std::string file;
     const int line;
     const int column;
     const testing::ScopedTrace trace;
};

DEFUN_DLD (gtest_fail, args, nargout,
          "-*- texinfo -*-\n"
           "@deftypefn {} gtest_fail(@var{last_err})\n\n"
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

     std::vector<StackRecord> rgStack;
     rgStack.reserve(std::max<octave_idx_type>(1, stack.numel()));

     if (stack.isempty()) {
          rgStack.emplace_back(__FILE__, __LINE__);
     } else {
          for (octave_idx_type i = 0; i < stack.numel(); ++i) {
               std::string fn = file(i).string_value();

               if (fn.empty()) {
                    fn = "<unknown file>";
               }

               rgStack.emplace_back(fn, line(i).int_value(), column(i).int_value());
          }
     }

     ADD_FAILURE_AT(rgStack.front().file.c_str(), rgStack.front().line) << message;

     return octave_value_list();
}
