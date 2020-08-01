function y = image_delay(x, rows, columns);
	if ~exist('columns')
		columns = rows;
	end
	y = zeros(size(x, 1) + rows, size(x, 2) + columns);
	y(rows + 1 : size(y, 1), columns + 1 : size(y, 2)) = x;
end
