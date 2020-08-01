function [xd, x0, x1] = qmf_decomposition_1level(x, h0, h1);
	w0 = conv(h0, x);
	w1 = conv(h1, x);
	x0 = downsample(w0, 2);
	x1 = downsample(w1, 2);
	xd = [x0(:); x1(:)];
	if size(x, 1) < size(x, 2)
		xd = xd.';
	end
end
