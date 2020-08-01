function [xd, xdc, h] = qmf_decomposition(x, h0, h1, levels);
	h = filter_iterator(h0, h1, levels);
	xdc{levels + 1} = [];
	downsample_factor = 1;
	xd = [];
	for n = levels + 1 : -1 : 2
		downsample_factor = downsample_factor * 2;
		xdc{n} = downsample(conv(h{n}, x), downsample_factor);
		xd = [xdc{n}(:); xd];
	end
	xdc{1} = downsample(conv(h{1}, x), downsample_factor);
	xd = [xdc{1}(:); xd];
	if size(x, 2) > size(x, 1)
		xd = xd.';
	end
end
