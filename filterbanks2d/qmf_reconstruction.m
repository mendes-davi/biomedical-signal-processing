function [x, xdelay, compensatory_delay] = qmf_reconstruction(xdc, h0, h1, g0, g1);
	N1 = length(xdc{length(xdc)});
	levels = length(xdc) - 1;
	[~, A, d] = evaluate_decomposition_synthesis_filters(h0, h1, g0, g1);
	g = filter_iterator(g0, g1, levels);
	compensatory_delay = d;
	column_vector = (size(xdc{1}, 1) > size(xdc{1}, 2));
	upsample_factor = 2 ^ levels;
	signal_length = 0;
	for n = 1 : 2
		xdc{n} = upsample(xdc{n}(:), upsample_factor);
		xdc{n} = xdc{n}(1 : length(xdc{n}) - upsample_factor + 1);
		xdc{n} = conv(g{n}, xdc{n});
		if length(xdc{n}) > signal_length
			signal_length = length(xdc{n});
		end
	end
	for n = 3 : levels + 1
		xdc{n} = [zeros(compensatory_delay, 1); xdc{n}(:)];
		compensatory_delay = compensatory_delay + 2 ^ (n - 2) * d;
		upsample_factor = upsample_factor / 2;
		xdc{n} = upsample(xdc{n}, upsample_factor);
		xdc{n} = xdc{n}(1 : length(xdc{n}) - upsample_factor + 1);
		xdc{n} = conv(g{n}, xdc{n});
		if length(xdc{n}) > signal_length
			signal_length = length(xdc{n});
		end
	end
	xdelay = zeros(signal_length, 1);
	for n = 1 : levels + 1
		xdelay = xdelay + ...
		[xdc{n}; zeros(signal_length - length(xdc{n}), 1)];
	end
	xdelay = xdelay / A;
	if ~column_vector
		xdelay = xdelay.';
	end
	N = 2 * N1 - length(h1) + 1;
	x = xdelay(1 + compensatory_delay : length(xdelay));
	x = x(1 : N);
end
