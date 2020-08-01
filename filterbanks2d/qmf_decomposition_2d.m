function [xd, xdc, h] = qmf_decomposition_2d(x, h0, h1, levels);
	h_ll = h0(:) * (h0(:).');
	h_hl = h1(:) * (h0(:).');
	h_lh = h0(:) * (h1(:).');
	h_hh = h1(:) * (h1(:).');
	h{1} = h_ll;
	h{2} = h_hl;
	h{3} = h_lh;
	h{4} = h_hh;
	downsample_factors = [2; 2; 2; 2];
	for n = 2 : levels
		[h, downsample_factors] = ...
		iterate2dfilters(h, downsample_factors, h_ll);
	end
	n = length(h);
	xdc{n} = down2d(conv2(h{n}, x), downsample_factors(n));
	for n = 1 : length(h) - 1
		xdc{n} = down2d(conv2(h{n}, x), downsample_factors(n));
	end
	xd = zeros(size(x));
	n = length(xdc);
	central_row = size(x, 1);
	central_column = size(x, 2);
	while n > 1
		central_row = floor(central_row / 2);
		central_column = floor(central_column / 2);
		xdcn = image_trim(xdc{n}, central_row, central_column);
		xdcn1 = image_trim(xdc{n - 1}, central_row, ...
		central_column);
		xdcn2 = image_trim(xdc{n - 2}, central_row, ...
		central_column);
		xd(central_row + 1 : 2 * central_row, ...
		central_column + 1 : 2 * central_column) = ...
		abs(xdcn) / max(abs(xdcn(:)));
		xd(1 : central_row, ...
		central_column + 1 : 2 * central_column) = ...
		abs(xdcn2) / max(abs(xdcn2(:)));
		xd(central_row + 1 : 2 * central_row, ...
		1 : central_column) = abs(xdcn1) / max(abs(xdcn1(:)));
		n = n - 3;
	end
	xdcn = image_trim(xdc{1}, central_row, central_column);
	xd(1 : central_row, 1 : central_column) = ...
	abs(xdcn) / max(abs(xdcn(:)));
end

function y = down2d(x, f);
	y1 = downsample(x, f);
	y2 = downsample(y1.', f);
	y = y2.';
end

function y = image_trim(x, rows, columns);
	rows_remove = size(x, 1) - rows;
	columns_remove = size(x, 2) - columns;
	half_rows_remove = floor(rows_remove / 2);
	half_columns_remove = floor(columns_remove / 2);
	y = x(1 + half_rows_remove : half_rows_remove + rows, ...
	1 + half_columns_remove : half_columns_remove + columns);
end

