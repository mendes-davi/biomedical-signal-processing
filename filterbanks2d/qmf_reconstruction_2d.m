function [xr, xdelay, compensatory_delay, y] = qmf_reconstruction_2d(xdc, h0, h1, g0, g1, rows, columns);
	[~, A, d] = evaluate_decomposition_synthesis_filters(h0, h1, g0, g1);
	levels = (length(xdc) - 1) / 3;
	g_ll = g0(:) * (g0(:).');
	g_hl = g1(:) * (g0(:).');
	g_lh = g0(:) * (g1(:).');
	g_hh = g1(:) * (g1(:).');
	g{1} = g_ll;
	g{2} = g_hl;
	g{3} = g_lh;
	g{4} = g_hh;
	upsample_factors = [2; 2; 2; 2];
	compensatory_delays = [0; 0; 0; 0];
	for n = 2 : levels
		[g, upsample_factors, compensatory_delays] = ...
		iterate2dfilters(g, upsample_factors, g_ll, ...
		compensatory_delays, d);
	end
	xr = 0;
	for n = 1 : length(xdc)
		x = xdc{n};
		x = image_delay(x, compensatory_delays(n));
		x = up2d(x, upsample_factors(n));
		x = conv2(g{n}, x);
		xr = add_images(xr, x);
		y{n} = x;
	end
	xdelay = xr;
	compensatory_delay = 2 * compensatory_delays(end) + d;
	xr = xr(compensatory_delay + 1 : end, ...
	compensatory_delay + 1 : end);
	xr = xr(1 : rows, 1 : columns);
end
