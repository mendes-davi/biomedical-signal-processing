function N = N_output_h1(N_, Nh)
	x = randn(N_, 1);
	h = randn(Nh, 1);
	y = conv(h, x);
	z = downsample(y, 2);
	N = length(z);
end
