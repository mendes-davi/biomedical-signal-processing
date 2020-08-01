function y = up2d(x, upsample_factor);
	if ~exist('upsample_factor')
		upsample_factor = 2;
	end
	y1 = upsample(x, upsample_factor);
	y1 = y1(1 : size(y1, 1) - (upsample_factor - 1), :);
	y2 = upsample(y1.', upsample_factor);
	y2 = y2(1 : size(y2, 1) - (upsample_factor - 1), :);
	y = y2.';
end
