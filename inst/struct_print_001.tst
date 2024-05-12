## struct_print.m:01
%!function param = load_struct(fname)
%! source(fname);
%!test
%! try
%! param.x = 1;
%! param.y = 1.5;
%! param.s = "hello";
%! param.A = rand(3,4);
%! param.v = rand(3,1);
%! param.w = rand(1,4);
%! param.m.x = 4;
%! param.m.y = rand(4,5);
%! param.m.s = "hello";
%! param.m.w.x = 1.75;
%! param.m.w.a = rand(4,5);
%! param.n(1).i = 1;
%! param.n(2).i = 2;
%! param.n(3).i = 3;
%! param.k(1).m.z = 1;
%! param.k(2).m.z = 2;
%! param.k(3).m.z = 3;
%! param.l(1).m(1).x = 11;
%! param.l(1).m(2).x = 12;
%! param.l(2).m(1).x = 21;
%! param.l(2).m(2).x = 22;
%! param.q{1}.b = true;
%! param.q{1}.z = 4 + 2j;
%! param.q{1}.i = int32(100);
%! param.q{2}.x = 1;
%! param.q{3}{1} = "test1";
%! param.q{3}{2} = 2;
%! param.q{3}{3} = zeros(3,2);
%! fd = -1;
%! fname = "";
%! unwind_protect
%! [fd, fname, msg] = mkstemp(fullfile(tempdir(), "print_struct_XXXXXX"), true);
%! struct_print(param, fd);
%! fclose(fd);
%! fd = -1;
%! param2 = load_struct(fname);
%! assert(param, param2, eps);
%! unwind_protect_cleanup
%!  if (fd ~= -1)
%!    fclose(fd);
%!  endif
%!  if (numel(fname))
%!    [~] = unlink(fname);
%!  endif
%! end_unwind_protect
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
%!error struct_print();
%!error struct_print(1,2,3,4);
