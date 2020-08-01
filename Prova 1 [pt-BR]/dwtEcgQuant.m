%% dwtEcgQuant: DWT Compression scheme using a given percentage (NM%) of the transform coefficients
function [xq, len] = dwtEcgQuant(x, filter_type, levels, NM)
	xq = cell(1, length(NM));
	
	% Treat Inputs
	if class(filter_type) == 'char' 
		[h0, h1, ~, ~] = wfilters(filter_type);
	elseif class(filter_type) == 'cell' 
		h0 = filter_type{1};
		h1 = filter_type{2};
	else
		error('Error in filter_type! Provide {h0, h1} as a cell array or use MATLAB std filters!');
	end
	
	% Perform Decomposition
	[xd, xdc, ~] = qmf_decomposition(x, h0, h1, levels);
	% Get length of each level
	len = cellfun(@length, xdc);
	% Sort
	[xd_sort, I] = sort(xd, 'descend', 'ComparisonMethod', 'abs');
	mpI = 1:1:length(xd);
	mpI = mpI(I); % map indexes according to sorted data
	% Quantize using Nm[%]
	NM = round(length(x) * (NM/100));
	for n = 1:length(NM)
		tmp = zeros(length(xd),1);
		tmp(mpI(1:NM(n))) = xd_sort(1:NM(n));
		xq{n} = tmp;
	end	
end