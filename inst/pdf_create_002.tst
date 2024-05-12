## pdf_create.m:02
%!demo
%! try
%! output_name = "";
%! y = rand(3, 5);
%! h = zeros(1, rows(y));
%! unwind_protect
%! output_name = tempname();
%! for i=1:rows(y)
%!   h(i) = figure("visible","off");
%!   graphics_toolkit(h(i), "gnuplot");
%!   plot(y(i, :), sprintf("-;y%d;%d", i, i));
%! endfor
%! pdf_create(h, output_name);
%! unwind_protect_cleanup
%! if (numel(output_name))
%!   err = unlink([output_name, ".pdf"]);
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
