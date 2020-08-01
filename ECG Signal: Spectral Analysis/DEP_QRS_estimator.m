clear all; close all; clc;

% ECG Signals
ecg_signals_path = '~/Dropbox/processamento_sinais_biologicos_02_2019/programas_sinais_exemplos/sinais_ecg/';
signalfield_name = 'x';

% Load Signals
[ecg_signals, fs] = loadmat_signals(ecg_signals_path, signalfield_name);
ecg = ecg_signals{1}(:,1); % multi-channel signal

% Perform R-Wave Detection
[qrs_i_raw, qrs_amp_raw] = rwave_detect(ecg, fs, 1.3);

% Segment QRS Complex in order to find Q and S
PR_len = round(0.12 * fs);
RT_len = round(0.28 * fs);
ecg_seg = zeros(PR_len + RT_len + 1, length(qrs_i_raw));
qrs_seg = [];
q_i = zeros(1, length(qrs_i_raw));
r_i = zeros(1, length(qrs_i_raw));
for s = 1:length(qrs_i_raw)
	ecg_seg(:,s) = -ecg(qrs_i_raw(s)-PR_len : qrs_i_raw(s)+RT_len);	
	[~,locs] = findpeaks(ecg_seg(:,s));
	tmp_q = locs(locs < PR_len);
	tmp_r = locs(locs > PR_len);
	q_i(s) = qrs_i_raw(s) - PR_len + tmp_q(end);
	r_i(s) = qrs_i_raw(s) - PR_len + tmp_r(1);
	qrs_seg = [qrs_seg; ecg(q_i(s) : r_i(s))];
end

% Plot FFT
figure('units','normalized','outerposition',[0 0 1 1]);
X = fft(qrs_seg - mean(qrs_seg));
plot(linspace(-fs/2, fs/2, length(X)), fftshift(abs(X)));
title('FFT');
xlabel('Frequencies (hertz)');
ylabel('|X_c(f)|');
grid on;

% Plot Periodogram
figure('units','normalized','outerposition',[0 0 1 1]);
pxx = periodogram(qrs_seg);
plot(linspace(0, fs/2, length(pxx)),10*log10(pxx));
hold on;
title('QRS Complex Periodogram');
xlabel('Frequencies (hertz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;

% Plot Results
figure('units','normalized','outerposition',[0 0 1 1]);
plot(qrs_seg);
title('QRS Complex Concatenated Side by Side');

figure('units','normalized','outerposition',[0 0 1 1]);
plot(ecg);
title('Annotated ECG Signal');
hold on;
stem(qrs_i_raw, qrs_amp_raw, 'LineStyle', 'none');
stem(q_i, ecg(q_i), 'LineStyle', 'none');
stem(r_i, ecg(r_i), 'LineStyle', 'none');
hold off;

%% load_signals: Load .mat signals in a given folder path
function [signals, fs] = loadmat_signals(s_path, s_fieldname)
% Load signals into a cell array
	signals = {};
	dir_files = dir(s_path);
	for f = 1:length(dir_files)
		if contains(dir_files(f).name, '.mat')
			MAT = load([s_path dir_files(f).name]);
			signals{end+1} = MAT.(s_fieldname);
			
			% Check for sampling frequency
			try
				fs = MAT.fs;
			catch ME
				switch ME.identifier
					case 'MATLAB:nonExistentField' 
						if ~exist('fs', 'var')
							fs = [];
						end
					otherwise
						rethrow(ME);
				end
			end
		end
	end
	if isempty(fs)
		warning('Sampling Frequency (fs) is empty in MAT files!');
	end
end
