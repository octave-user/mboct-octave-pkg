##  Copyright (C) 2018(-2024) Reinhard <octave-user@a1.net>

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

oct_OBJ:=spawn.@OBJEXT@ shell.@OBJEXT@ gtest_fail.@OBJEXT@

oct_FILE:=__mboct_octave_proc__.oct

bin_FILES:=$(oct_FILE)

if USE_GTEST
  bin_PROGRAMS=gtest-octave-cli
  gtest_octave_cli_SOURCES=gtest-octave-cli.cc
endif

all-local: $(bin_FILES)

clean-local:
	rm -f $(bin_FILES) $(oct_OBJ)

distclean-local:
	rm -f oct-alt-includes.h

%.@OBJEXT@: %.cc
	$(MKOCTFILE) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(oct_FILE): $(oct_OBJ)
	$(MKOCTFILE) $^ $(LDFLAGS) $(LIBS) -o $@

gtest-octave-cli$(EXEEXT): gtest-octave-cli.@OBJEXT@
	$(MKOCTFILE) --link-stand-alone $^ $(LDFLAGS) $(LIBS) -o $@

.PHONY: clean-local distclean-local
