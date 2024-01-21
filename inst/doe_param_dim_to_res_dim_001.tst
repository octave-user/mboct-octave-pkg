## doe_param_dim_to_res_dim.m:01
%!test
%! assert(doe_param_dim_to_res_dim(int32([4, 3, 8, 10])), int32(4 * 3 * 8 * 10));
