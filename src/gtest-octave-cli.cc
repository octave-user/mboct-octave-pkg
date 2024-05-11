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
#include "gtest-octave.h"

class GTestOctaveCLI: public GTestOctaveBase {
public:
     GTestOctaveCLI(int argc, char* argv[])
          :GTestOctaveBase(argc, argv) {
     }

     virtual int Execute() override {
          octave_block_async_signals ();

          octave::sys::env::set_program_name (argv[0]);

          octave::cli_application app (argc, argv);

          return app.execute();
     }

     static GTestOctaveBase* Allocate(int argc, char** argv) {
          return new GTestOctaveCLI(argc, argv);
     }
     
     static int Run(int argc, char** argv) {
          return GTestOctaveBase::Run(argc, argv, &Allocate);
     }
};

int
main (int argc, char **argv)
{
     return GTestOctaveCLI::Run(argc, argv);
}
