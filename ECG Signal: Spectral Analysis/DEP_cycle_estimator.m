clear all; close all; clc;
 
load('ECG_1.mat', 'fs', 'x');
x = x(:, 1);
 
t = 0 : (1/fs) : (length(x) + 1000) / fs;
t = t(1 : length(x));

% Plot an EKG sample 
plot(t(1 : fs * 3), x(1 : fs * 3));
title('ECG Signal');
xlabel('Time (seconds)');
ylabel('x_c(t)');
grid on;

% Plot FFT
figure;
X = fft(x - mean(x));
plot(linspace(-fs/2, fs/2, length(X)), fftshift(abs(X)));
title('FFT');
xlabel('Frequencies (hertz)');
ylabel('|X_c(f)|');
grid on;

% Short Time FT
twin = round(1 * fs);
x_win = padarray(x, twin*ceil(length(x)/twin) - length(x), 'post'); % Prune array to reshape
x_win = reshape(x_win, twin, []);
PSD = @(blk_struct) abs(fft(blk_struct.data)).^2;
x_winPSD = blockproc(x_win, [twin 1], PSD);
x_meanPSD = mean(x_winPSD');
% Plot PSD
figure;
x_psd_db = 10*log10(x_meanPSD(1 : end/2));
plot(linspace(0, fs/2, length(x_psd_db)), x_psd_db, 'LineWidth', 2);
title('Avg. PSD');
xlabel('Frequencies (hertz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;

% Plot Periodogram
figure;
pxx = periodogram(x_win);
plot(linspace(0, fs/2, length(pxx)),10*log10(pxx));
title('Periodogram');
xlabel('Frequencies (hertz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
