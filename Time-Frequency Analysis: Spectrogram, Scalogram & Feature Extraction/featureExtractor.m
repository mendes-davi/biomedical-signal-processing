%% featureExtractor: function description
function [temporal_features, frequency_features] = featureExtractor(data, fs, win, loverlap, zeropad, iirfilter, bands, nbands, boverlap, maxfreq, fmaxorder, ftol, fnum, fden)

	if ~exist('iirfilter', 'var') || isempty(iirfilter)
		iirfilter = @butter;
	end
	if ~exist('fmaxorder', 'var') || isempty(fmaxorder)
		fmaxorder = 15;
	end
	if ~exist('boverlap', 'var') || isempty(boverlap)
		boverlap = 0.25;
	end
	if ~exist('ftol', 'var') || isempty(ftol)
		ftol = 1e-5;
	end
	if ~exist('maxfreq', 'var') || isempty(maxfreq)
		maxfreq = fs/2;
	end
	if ~exist('zeropad', 'var') || isempty(zeropad)
		zeropad = false;
	end
	lwin = length(win);
	% Reshape Signal
	data = reshapeOverlap(data, lwin, loverlap, zeropad);
	s_data = size(data);
	% Perform Window Multiplication
	win_matrix = repelem(win, 1, s_data(2)); 
	data = data.*win_matrix;

	% Extract temporal features
	rMeanVal = @(w) mean(abs(w)); % Rectified Mean Value
	RMS = splitapply(@rms, data, 1:s_data(2));
	STD = splitapply(@std, data, 1:s_data(2));
	RMV = splitapply(rMeanVal, data, 1:s_data(2));

	%% Extract frequency features
	% Evaluate Filtering bands
	if ~exist('bands', 'var') || isempty(bands)
		maxnfreq = maxfreq / fs;
		bands = [ (0 : maxnfreq / nbands : maxnfreq * (1 - 1/nbands)).' (maxnfreq / nbands : maxnfreq / nbands : maxnfreq).'];
		bands(2:end,1) = bands(2:end,1) - boverlap / 2 * maxnfreq / nbands;
		bands(1:end-1,2) = bands(1:end-1,2) + boverlap / 2 * maxnfreq / nbands;
	end
	% Fix bands if nbands = 1 (The cutoff frequencies must be within the interval of (0,1))
	if isequal(nbands,1)
		bands(2) = bands(2) - ftol;
	end
	% Design Filters
	if (~exist('fnum', 'var') || isempty(fnum)) && (~exist('fnum', 'var') || isempty(fnum))
		fnum = cell(1, nbands);
		fden = cell(1, nbands);
		for b = 1 : nbands
			[fnum{b}, fden{b}] = iir_design(iirfilter, fmaxorder, ftol, bands(b, :));
		end
	end
	% Perform Filtering
	nfft = 2^(nextpow2(lwin));
	freq = linspace(0,fs/2, nfft);
	getEnergy = @(w) norm(w)^2;
	magfft = @(w) abs(fft(w-mean(w), nfft)); % Use zero-mean version!!
	fdata = zeros(s_data(1), s_data(2), nbands);
	fftdata = zeros(nfft, s_data(2), nbands);
	E = zeros(s_data(2), nbands);
	MEDFREQ = zeros(s_data(2), nbands);
	MEANFREQ = zeros(s_data(2), nbands);
	MODALFREQ = zeros(s_data(2), nbands);
	for b = 1:nbands
		fdata(:,:,b) = filter(fnum{b}, fden{b}, data, [], 1); % Filtering along the cols
		E(:,b) = splitapply(getEnergy, fdata(:,:,b), 1:s_data(2)); % Obtain Energy
		MEANFREQ(:,b) = meanfreq(fdata(:,:,b), fs); % Obtain Mean Frequency
		MEDFREQ(:,b) = medfreq(fdata(:,:,b), fs); % Obtain Median Frequency
		fftdata(:,:,b) = splitapply(magfft, fdata(:,:,b), 1:s_data(2)); % Obtain Frequency Response
		[~,I] = max(fftdata(:,:,b), [], 1);
		MODALFREQ(:,b) = freq(I);
	end
	table_names = {'RMS', 'RMV', 'STD', 'E', 'MEDFREQ', 'MEANFREQ', 'MODALFREQ'};
	temporal_features = table(RMS(:), RMV(:), STD(:), 'VariableNames', table_names(1:3));
	frequency_features = table(E, MEDFREQ, MEANFREQ, MODALFREQ, 'VariableNames', table_names(4:end));
end

% iir_design: function description
function [num, den] = iir_design(iir_type, maximum_order, filter_tol, bands)
	not_finished = 1;
	order = maximum_order;
	bands_ = bands;
	mode = 'bandpass';
	if bands(1) == 0
		bands_ = bands(2);
		mode = 'low';
	end
	if bands(2) == 0.5
		bands_ = bands(1);
		mode = 'high';
	end
	while not_finished
		[num, den] = iir_type(order, bands_ * 2, mode);
		not_finished = any(abs(roots(den)) > 1 - filter_tol);
		order = order - 1;
	end
end