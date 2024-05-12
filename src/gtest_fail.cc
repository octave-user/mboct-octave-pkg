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

#include "config.h"

#include <octave/oct.h>

#ifdef HAVE_GTEST
#include <gtest/gtest.h>
#include <vector>
#endif

// PKG_ADD: autoload ("gtest_fail", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("gtest_fail", "__mboct_octave_proc__.oct", "remove");

#ifdef HAVE_GTEST
struct StackRecord: public octave_base_value {
     StackRecord(const std::string& filetmp = __FILE__, int linetmp = __LINE__, int columntmp = -1)
          :file(filetmp), line(linetmp), column(columntmp), trace(file.c_str(), line, column) {
     }

     StackRecord()
          :file(__FILE__),
           line(__LINE__),
           column(-1),
           trace(file.c_str(), line, column) {
     }

     virtual void print (std::ostream& os, bool pr_as_read_syntax) override {
          os << file << ":" << line << ":" << column << "\n";
     }

     virtual size_t byte_size() const override { return sizeof(*this); };
     virtual dim_vector dims() const override { return dim_vector(1,1); }
     virtual bool is_constant(void) const override { return true; }
     virtual bool is_defined(void) const override { return true; }
     virtual bool isreal() const override { return false; }
     virtual bool iscomplex() const override { return false; }

     const std::string file;
     const int line;
     const int column;
     const testing::ScopedTrace trace;
};
#endif

DEFUN_DLD (gtest_fail, args, nargout,
          "-*- texinfo -*-\n"
           "@deftypefn {} gtest_fail(@var{last_err}, @var{test_function})\n\n"
           "Pass exception information to the GoogleTest library (e.g. to be used in assert_simple)\n\n"
           "@example\n"
           "gtest_fail(lasterror())\n"
           "@end example\n"
           "@end deftypefn\n")
{
     octave_value_list retval;

     if (args.length() < 1 || args.length() > 2) {
          print_usage();
          return retval;
     }

#ifdef HAVE_GTEST
     const octave_scalar_map last_err = args(0).scalar_map_value();
     const std::string message = last_err.getfield("message").string_value();
     const octave_map stack = last_err.getfield("stack").map_value();
     const std::string test_function = args.length() > 1 ? args(1).string_value() : std::string("%__GTEST_FAIL_UNKNOWN_FUNCTION__%");

     const Cell file = stack.getfield("file");
     const Cell line = stack.getfield("line");
     const Cell column = stack.getfield("column");
     const octave_idx_type n = std::max<octave_idx_type>(1, stack.numel());
     Cell rgStackRecords(dim_vector(n, 1));
     
     if (stack.isempty()) {
          rgStackRecords(0) = octave_value(new StackRecord(__FILE__, __LINE__));
     } else {
          for (octave_idx_type i = 0; i < n; ++i) {
               std::string fn = file(i).string_value();

               if (fn.empty()) {
                    fn = test_function;
               }

               rgStackRecords(i) = octave_value(new StackRecord(fn, line(i).int_value(), column(i).int_value()));
          }
     }

     const auto pFront = dynamic_cast<const StackRecord*>(rgStackRecords(0).internal_rep());

     ADD_FAILURE_AT(pFront->file.c_str(), pFront->line) << message;

     retval.append(octave_value(rgStackRecords));
#else
     warning_with_id("mboct-octave-pkg:gtest_fail", "mboct-octave-pkg was not compiled with gtest");
#endif

     return retval;
}
