%% rwave_detect: Perform R-wave detection in ECG Signals (filtering, derivative filtering and squaring) 
function [qrs_i_raw, qrs_amp_raw] = rwave_detect(ecg, fs)
	qrs_amp_raw = [];
	qrs_i_raw = [];
	delay = 0;

	% Bandpass Filtering
	Wn = [0.5 18]*2/fs; % Cut off (based on fs)
	N = 3; % Filter Order
	[a, b] = butter(N, Wn); % Design Butterworth Filter
	ecg_f = filtfilt(a, b, ecg); % Perform Zero-Phase Filtering
	ecg_f = ecg_f / max(abs(ecg_f));

	% Derivative Filtering
	h_d = [-1 -2 0 2 1]*(1/8);
	ecg_d = conv(ecg_f, h_d); % Perform Derivative Filtering
	ecg_d = ecg_d / max(ecg_d); % Normalize Values
	delay = delay + 2; % Delay of filtering is 2 samples.

	% Squaring 
	ecg_s = ecg_d.^2;

	%% Moving average 
	tfrac = 0.085;
	m_d = ones(1 ,round(tfrac*fs))/round(tfrac*fs);
	ecg_m = conv(ecg_s , m_d);
	delay = delay + round((length(m_d)-1)/2);

	% Find Peaks
	% MinPeakDistance: no RR wave can occour in 200 msec time distance
	% MinPeakHeight: Threshold values based on integrated signal mean
	min_peak_h = 1.5*mean(ecg_m);
	[~,locs] = findpeaks(ecg_m, 'MINPEAKDISTANCE', round(0.2*fs), 'MinPeakHeight', min_peak_h);

	locs = locs - delay;
	w = 6;
	for pt = 1:length(locs)
		ind = locs(pt)-w/2:locs(pt)+w/2;
		ecg_cut = ecg(ind); 
		is_inv = mean(ecg_cut) < 0;
		if is_inv; ecg_cut = -ecg_cut; end
		R = max(ecg_cut);
		R_i = find(ecg_cut == R,1);
		locs(pt) = ind(1)-1+R_i;
	end

	qrs_amp_raw = ecg(locs);
	qrs_i_raw = locs;

	% figure('units', 'normalized', 'outerposition', [0 0 1 1]);
	% plot(ecg_f);
	% hold on;
	% plot(circshift(ecg_m,-delay));
	% stem(qrs_i_raw, ecg_f(qrs_i_raw), 'r', 'filled', 'LineStyle', 'none');
	% legend('ECG', 'M', 'R');
end
