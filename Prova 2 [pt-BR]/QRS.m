clear all; close all; clc;

% Add Functions to PATH
addpath('../EXER1-ECG_DEP');
addpath('../utils_P1');
addpath('../P1');
rehash path;

% ECG Signals
ecg_signals_path = '~/Dropbox/processamento_sinais_biologicos_02_2019/sinais_prova_2/ecg/';
signalfield_name = 'val';

% Load Signals
[ecg_signals, fs, s_name] = loadmat(ecg_signals_path, signalfield_name);
fs = 360;
rand_signal = randi(length(ecg_signals));
% rand_signal = 14;
disp(['Using Signal: ' s_name{rand_signal} ' Number: ' int2str(rand_signal)]);
ecg = ecg_signals{rand_signal}(:);

% Perform R-Wave Detection
[qrs_i, qrs_amp] = rwave_detect(ecg, fs);
[pan_qrs_amp, pan_qrs_i, ~] = pan_tompkin(ecg,fs, 0);

disp(['Reference QRS Indexes contains ' int2str(length(pan_qrs_i)) ' points.']);
disp(['Obtained QRS Indexes contains ' int2str(length(qrs_i)) ' points.']);
disp(['--- ' int2str(length(find(qrs_i == pan_qrs_i))) ' points in both sets ---']);
disp('Me:');
disp(qrs_i);
disp('Pan-Tompkins:');
disp(pan_qrs_i(:));

% Use QS wave detect
[q_i, s_i] = qswave_detect(ecg, qrs_i);

figure('units', 'normalized', 'outerposition', [0 0 1 1]);
plot(ecg,'k', 'LineWidth', 2);
ylim([min(ecg)-50  max(ecg)+50]);
xlim([0 length(ecg)]);
grid on;
grid minor;
hold on;
stem(qrs_i, qrs_amp, 'r', 'filled', 'LineStyle', 'none', 'MarkerSize', 8);
stem(s_i, ecg(s_i), 'b', 'filled', 'LineStyle', 'none', 'MarkerSize', 8);
stem(q_i, ecg(q_i), 'g', 'filled', 'LineStyle', 'none', 'MarkerSize', 8);
legend('ECG', 'R', 'S', 'Q');
