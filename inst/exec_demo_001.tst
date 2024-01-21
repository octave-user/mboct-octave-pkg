## exec_demo.m:01
%!test
%! exec_demo(which("exec_demo"), 2, 1, "test");
%! assert(evalin("base", "__exec_demo_x"), 1);
%! assert(evalin("base", "__exec_demo_y"), 2);
%! assert(evalin("base", "__exec_demo_z"), 3);
%! evalin("base", "clear __exec_demo_x __exec_demo_y __exec_demo_z");
