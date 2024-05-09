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

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <string>
#include <oct-env.h>
#include <octave.h>

#include <gtest/gtest.h>

extern "C" OCTAVE_API void octave_block_async_signals (void);

class GTestOctaveCLI: public testing::Test {
public:
     GTestOctaveCLI(int argc, char* argv[])
          :argc(argc), argv(argv) {
     }

     virtual void TestBody() override {
          octave_block_async_signals ();

          octave::sys::env::set_program_name (argv[0]);

          octave::cli_application app (argc, argv);

          int ret = app.execute();

          if (ret != 0) {
               ADD_FAILURE_AT(__FILE__, __LINE__) << "app.execute() returned with status " << ret;
          }
     }
private:
     const int argc;
     char** const argv;
};

int
main (int argc, char **argv)
{
     testing::InitGoogleTest(&argc, argv);

     std::string strTestSuiteName = "mboct-octave-pkg: <<unknown testsuite>>", strTestName = "mboct-octave-pkg: <<unknown test>>";

     std::ostringstream os;

     for (int i = 0; i < argc; ++i) {
          bool bRemoveArg = false;

          if (0 == strcmp(argv[i], "--test-name")) {
               if (!(argc > i + 1)) {
                    std::cerr << argv[0] << ": missing argument for --test-name\n";
                    return 1;
               }

               strTestName = argv[i + 1];

               bRemoveArg = true;
          } else if (0 == strcmp(argv[i], "--test-suite-name")) {
               if (!(argc > i + 1)) {
                    std::cerr << argv[0] << ": missing argument for --test-suite-name\n";
                    return 1;
               }

               strTestSuiteName = argv[i + 1];

               bRemoveArg = true;
          }

          if (bRemoveArg) {
               for (int j = i; j + 2 <= argc; ++j) {
                    argv[j] = argv[j + 2];
               }

               argc -= 2;
               --i;
          } else {
               os << argv[i] << ' ';
          }
     }

     os << std::ends;

     const std::string strProgramArgs = os.str();

     testing::RegisterTest(strTestSuiteName.c_str(),
                           strTestName.c_str(),
                           nullptr,
                           strProgramArgs.c_str(),
                           __FILE__,
                           __LINE__,
                           [=]() -> GTestOctaveCLI* { return new GTestOctaveCLI(argc, argv); });

     return RUN_ALL_TESTS();
}
