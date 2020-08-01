function [xr, xdelay, compensatory_delay] = qmf_reconstruction_2d(xdc, h0, h1, g0, g1);
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
	for n = 2: levels
		[g, upsample_factors] = ...
		iterate2dfilters(g, upsample_factors, g_ll);
	end
	xr = 0;
	for n = 1 : length(xdc)
		x = up2d(xdc{n}, upsample_factors(n));
		x = conv2(g{n}, x);
		% fazer o atraso necessário em x
		xr = xr + x; % considerar o caso de tamanhos diferentes
	end
end
