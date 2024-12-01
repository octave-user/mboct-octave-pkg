function status = run_tests_parallel(number_of_processors, package_names)
  pkg_files = {};
  
  for i=1:numel(package_names)
    pkg("load", package_names{i});
    pkg_list = pkg('list', '-verbose', package_names{i});
    pkg_files = {pkg_files{:}, dir(fullfile(pkg_list{1}.dir, '*.m')).name, dir(fullfile(pkg_list{1}.dir, '*.tst')).name};
  endfor

  opt.number_of_processors = number_of_processors;
  opt.number_of_parameters = numel(pkg_files);
  opt.redirect_stdout = fullfile(tempdir(), sprintf("run_tests_parallel_%04x_%%03d.out", getpid()));
  opt.reuse_subprocess = false;
  status = run_parallel(opt, @run_tests_parallel_handler, pkg_files);

  N = [[status{:}].N];
  NMAX = [[status{:}].NMAX];

  idx_failed = find(N < NMAX);

  for i=1:numel(idx_failed)
    fprintf(stderr, "test %4d: \"%s\" %3d/%3d tests failed\n", idx_failed(i), pkg_files{idx_failed(i)}, NMAX(idx_failed(i)) - N(idx_failed(i)),  NMAX(idx_failed(i)));
  endfor

  fprintf(stderr, "%d/%d tests passed\n", sum(N), sum(NMAX));

  for i=1:opt.number_of_parameters
    [status, msg] = unlink(sprintf(opt.redirect_stdout, i));
  endfor
  
  if (~isempty(idx_failed))
    error("%d/%d tests failed", sum(NMAX) - sum(N), sum(NMAX));
  endif
endfunction



