function status = run_tests_parallel_handler(idx, pkg_files)
  printf("%d:%s\n", idx, pkg_files{idx});
  [status.N, status.NMAX] = test(pkg_files{idx});
endfunction
