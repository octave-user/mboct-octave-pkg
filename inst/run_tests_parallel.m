## Copyright (C) 2016(-2025) Reinhard <octave-user@a1.net>
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
## @deftypefn {Function File} @var{status} = run_tests_parallel(@var{number_of_processors}, @var{package_names})
## Distribute the execution of all test functions from a package to multiple processes
## @var{package_names} @dots{} Cell array of package names
## @end deftypefn

function status = run_tests_parallel(number_of_processors, package_names)
  pkg_files = {};

  for i=1:numel(package_names)
    pkg("load", package_names{i});
    pkg_list = pkg('list', '-verbose', package_names{i});
    pkg_files = {pkg_files{:}, dir(fullfile(pkg_list{1}.dir, '*.m')).name, dir(fullfile(pkg_list{1}.dir, '*.tst')).name};
  endfor

  opt.number_of_processors = number_of_processors;
  opt.number_of_parameters = numel(pkg_files);

  if (~ispc())
    opt.redirect_stdout = fullfile(tempdir(), sprintf("run_tests_parallel_%04x_%%03d.out", getpid()));
  endif

  opt.reuse_subprocess = false;
  status = run_parallel(opt, @run_tests_parallel_handler, pkg_files);

  N = [[status{:}].N];
  NMAX = [[status{:}].NMAX];

  idx_failed = find(N < NMAX);

  for i=1:numel(idx_failed)
    fprintf(stderr, "test %4d: \"%s\" %3d/%3d tests failed\n", idx_failed(i), pkg_files{idx_failed(i)}, NMAX(idx_failed(i)) - N(idx_failed(i)),  NMAX(idx_failed(i)));
    if (~ispc())
      fprintf(stderr, "content of output file \"%s\" for test %d:\n", sprintf(opt.redirect_stdout, idx_failed(i)), idx_failed(i));
      spawn_wait(spawn("awk", {'{printf("  >> ");print;}', sprintf(opt.redirect_stdout, idx_failed(i))}));
    endif
  endfor

  fprintf(stderr, "%d/%d tests passed\n", sum(N), sum(NMAX));

  if (~ispc())
    for i=1:opt.number_of_parameters
      [status, msg] = unlink(sprintf(opt.redirect_stdout, i));
    endfor
  endif

  if (~isempty(idx_failed))
    error("%d/%d tests failed", sum(NMAX) - sum(N), sum(NMAX));
  endif
endfunction
