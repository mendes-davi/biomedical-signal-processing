%% dwtEcgRec: DWT Reconstruction for the dwtEcgQuant function
function [rx] = dwtEcgRec(xq, len, filter_type)
	rx = cell(1, length(xq));

	% Treat Inputs
	if class(filter_type) == 'char' 
		[h0, h1, g0, g1] = wfilters(filter_type);
	elseif class(filter_type) == 'cell' 
		h0 = filter_type{1};
		h1 = filter_type{2};
		g0 = filter_type{3};
		g1 = filter_type{4};
	else
		error('Error in filter_type! Provide {h0, h1} as a cell array or use MATLAB std filters!');
	end

	% Split decomposition array
	levels = length(len) - 1;
	qxdc = cell(1, length(xq));
	for n = 1:length(xq) % Iterate over all signals
		qxdc{n} = cell(1,levels);
		for l = 1:length(len) % Split for each level
			qxdc{n}{l} = xq{n}(1:len(l));
			xq{n}(1:len(l)) = [];
		end

		% Perform QMF Reconstruction
		[rx{n}, ~, ~] =  qmf_reconstruction(qxdc{n}, h0, h1, g0, g1);
	end
end