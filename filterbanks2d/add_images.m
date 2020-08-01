function z = add_images(x, y);
	rows = max([size(x, 1) size(y, 1)]);
	columns = max([size(x, 2) size(y, 2)]);
	x(rows + 1, columns + 1) = 0;
	y(rows + 1, columns + 1) = 0;
	z = x + y;
	z = z(1 : rows, 1 : columns);
end
