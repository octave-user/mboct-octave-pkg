## pdf_merge.m:02
%!demo
%! try
%! output_name = tempname();
%! hnd = [];
%! hnd(end + 1) = figure("visible", "off");
%! sombrero();
%! hnd(end + 1) = figure("visible", "off");
%! peaks();
%! for i=1:numel(hnd)
%!   fname{i} = sprintf("%s_%d.pdf", output_name, i);
%!   graphics_toolkit(hnd(i), "gnuplot");
%!   pdf_create(hnd(i), fname{i});
%! endfor
%! pdf_merge(fname, [output_name, ".pdf"]);
%! [err] = unlink([output_name, ".pdf"]);
%! assert(err, 0);
%! catch
%!   gtest_error = lasterror();
%!   gtest_fail(gtest_error, evalin("caller", "__file"));
%!   rethrow(gtest_error);
%! end_try_catch
