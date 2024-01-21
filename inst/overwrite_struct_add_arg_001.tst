## overwrite_struct_add_arg.m:01
%!test
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
%! assert(ov.data.x, 2);
%! assert(ov.data.opts.y, zeros(3, 3));
%! assert(ov.data.opts.name.z, "123");
%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x1=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y1=zeros(3, 3)", "data.opts.name.z=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
%!error
%! ov.data.x = 1;
%! ov.data.opts.y = rand(3, 3);
%! ov.data.opts.name.z = "abc";
%! ovd = struct()([]);
%! args = {"data.x=2", "data.opts.y=zeros(3, 3)", "data.opts.name.z2=\"123\""};
%! for i=1:numel(args)
%!   ovd = overwrite_struct_add_arg(ovd, args{i});
%! endfor
%! options.verbose = false;
%! ov = overwrite_struct(ov, ovd, options);
