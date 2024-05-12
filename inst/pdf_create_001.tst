## pdf_create.m:01
%!test
%! try
%! output_name = "";
%! h = zeros(1, 2);
%! unwind_protect
%! output_name = [tempname(), ".pdf"];
%! h(1) = figure("visible","off");
%! sombrero();
%! h(2) = figure("visible","off");
%! peaks();
%! for i=1:numel(h)
%!   graphics_toolkit(h, "gnuplot");
%! endfor
%! pdf_create(h, output_name);
%! unwind_protect_cleanup
%! if (numel(output_name))
%!   [err] = unlink(output_name);
%!   assert(err, 0);
%! endif
%! for i=1:numel(h)
%!  if(isfigure(h(i)))
%!   close(h(i));
%!  endif
%! endfor
%! end_unwind_protect
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
