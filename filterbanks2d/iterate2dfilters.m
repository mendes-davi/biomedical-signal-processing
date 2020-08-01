function [hi, downsample_factors_i, compensatory_delays_i] = iterate2dfilters(h, downsample_factors, h_ll, compensatory_delays, d);
	if ~exist('compensatory_delays')
		compensatory_delays = [0; 0; 0; 0];
	end
	if ~exist('d')
		d = 1;
	end
	hi{length(h) + 3} = h{length(h)};
	% n = compensatory_delays(end) / d + 1;
	downsample_factors_i = [zeros(3, 1); downsample_factors];
	compensatory_delays_i = [compensatory_delays; ...
	zeros(3, 1) + 2 * compensatory_delays(end) + d];
	for n = 5 : length(h) + 2
		hi{n} = h{n - 3};
	end
	hi{1} = conv2(h_ll, up2d(h{1}));
	hi{2} = conv2(h_ll, up2d(h{2}));
	hi{3} = conv2(h_ll, up2d(h{3}));
	hi{4} = conv2(h_ll, up2d(h{4}));
	downsample_factors_i(1 : 4) = downsample_factors(1) * 2;
end
