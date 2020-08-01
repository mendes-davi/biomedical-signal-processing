function xr = qmf_reconstruction_1level(x0, x1, g0, g1);
	v0 = upsample(x0, 2);
	v1 = upsample(x1, 2);
	y0 = conv(g0, v0);
	y1 = conv(g1, v1);
	xr = polynomial_sum(y0, y1);
end

function z = polynomial_sum(x, y);
	x1 = zeros(max([length(x); length(y)]), 1);
	y1 = x1;
	x1(1 : length(x)) = x;
	y1(1 : length(y)) = y;
	z = x1 + y1;
	if(size(x, 2) > size(x, 1))
		z = z.';
	end
end
