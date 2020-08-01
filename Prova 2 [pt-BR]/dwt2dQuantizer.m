%% dwt2dQuantizer: Quantization for NM% coeffs in 2D-DWT
function [xq] = dwt2dQuantizer(xdc, NM)
	xq = cell(1, length(NM));
	% Obtain decomposition sizes
	sizes = cellfun(@size, xdc, 'UniformOutput', false);
	% Stack data into single array
	xdc = cellfun(@(x) x(:), xdc, 'UniformOutput', false);
	xdc = vertcat(xdc{:});

	% Sort
	[xdc_sort, I] = sort(xdc, 'descend', 'ComparisonMethod', 'abs');
	mpI = 1:1:length(xdc);
	mpI = mpI(I); % map indexes according to sorted data
	NM = round(length(xdc) * (NM/100));
	for n = 1:length(NM)	
		% Quantize using Nm[%]
		tmp = zeros(length(xdc),1);
		tmp(mpI(1:NM(n))) = xdc_sort(1:NM(n));
		
		% Undo data stacking
		tmp_cell = cell(1,length(sizes));
		for k = 1:length(sizes)
			nelements = prod(sizes{k});
			tmp_cell{k} = reshape(tmp(1:nelements), sizes{k});
			tmp(1:nelements) = [];	
		end
		xq{n} = tmp_cell;
	end
end
