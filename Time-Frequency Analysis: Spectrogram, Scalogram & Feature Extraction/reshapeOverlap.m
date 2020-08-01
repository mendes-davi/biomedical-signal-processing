%% reshapeOverlap: function description
function [x] = reshapeOverlap(x, lwin, loverlap, zeropad)
	x = double(x(:));
	if ~exist('loverlap', 'var') || isempty(loverlap)
		loverlap = 0;
	end
	if ~exist('zeropad', 'var') % Enables Zero Padding by default
		zeropad = true;
	end
	if zeropad
		% Zero Padding if needed based on window length and overlapping conditions
		n_win = ceil((length(x)-lwin)/(lwin-loverlap));
		pad_size = n_win*(lwin-loverlap)+lwin - length(x);
		x(length(x)+pad_size) = 0;
		warning('reshapeOverlap:ZeroPadW', ['Zero Padding in ' int2str(pad_size) ' elements.']);
	else
		n_win = floor((length(x)-lwin)/(lwin-loverlap));
		missed_elements = ceil((length(x)-lwin)/(lwin-loverlap))*(lwin-loverlap)+lwin - length(x);
		if missed_elements > 0
			warning('reshapeOverlap:ZeroPadW', ['Reshaped Signal doesn''t contains ' int2str(missed_elements) ' elements because Zero Padding is false']);
		end
	end
	% Reshape Signal
	ov_x = zeros(lwin,n_win);
	for n = 0:n_win
		strp = n*(lwin-loverlap)+1;
		ov_x(:,n+1) = x(strp : strp+lwin-1);
	end
	x = ov_x;
end
