#!/usr/bin/env gtest-octave-cli

## Copyright (C) 2024(-2024) Reinhard <octave-user@a1.net>
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

clear all;

args = argv();

pkg_name = "";
func_name = "";
output_file = "";

idx = int32(0);

while (++idx <= numel(args))
  switch(args{idx})
    case {"--package-name", "-p"}
      pkg_name = args{++idx};
    case {"--function-name", "-f"}
      func_name = args{++idx};
    case {"--output-file", "-o"}
      output_file = args{++idx};
    case {"--help", "-h"}
      fprintf(stderr, "gtest_test_exec\n");
      fprintf(stderr, "\t\t\t--package-name|-p <pkg_name>\n");
      fprintf(stderr, "\t\t\t--function-name|-f <func_name>\n");
      fprintf(stderr, "\t\t\t--output-file|-o <output_file>\n");
      return;
  endswitch
endwhile

try
  if (isempty(pkg_name))
    error("missing argument --package-name <PKG_NAME>");
  endif

  sigterm_dumps_octave_core(false);

  pkg("load", pkg_name);

  if (isempty(func_name))
    pkg_list = pkg('list', pkg_name);

    printf("__run_test_suite__('%s','%s')\n", pkg_list{1}.dir, pkg_list{1}.dir);

    [PASS, FAIL, XFAIL, XBUG, SKIP, RTSKIP, REGRESS] = __run_test_suite__({pkg_list{1}.dir}, {pkg_list{1}.dir});

    printf("PASS=%d, FAIL=%d, XFAIL=%d, XBUG=%d, SKIP=%d, RTSKIP=%d, REGRESS=%d\n", PASS, FAIL, XFAIL, XBUG, SKIP, RTSKIP, REGRESS);

    if (PASS < 1 || FAIL > 0 || REGRESS > 0)
      error("__run_test_suite__({'%s'},{'%s'}) failed", pkg_list{1}.dir, pkg_list{1}.dir);
    endif
  else
    which_func_name = which(func_name);

    if (~isempty(which_func_name))
      func_name = which_func_name;
    endif

    if (isempty(output_file))
      test_args = {"normal"};
    else
      test_args = {"verbose", output_file};
    endif

    printf("test('%s')\n", func_name);

    [N, NMAX, NXFAIL, NBUG, NSKIP, NRTSKIP, NREGRESSION] = test(func_name, test_args{:});

    printf("\"%s\":\"%s\": N=%d, NMAX=%d, NXFAIL=%d, NBUG=%d, NSKIP=%d, NRTSKIP=%d, NREGRESSION=%d\n", pkg_name, func_name, N, NMAX, NXFAIL, NBUG, NSKIP, NRTSKIP, NREGRESSION);

    if (N < NMAX || NREGRESSION)
      error("test(\"%s\") failed", func_name);
    endif
  endif
catch
  printf("FAILED\n");
  exit(1);
end_try_catch

printf("PASSED\n");
