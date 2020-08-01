clear all; close all; clc;
rng('default'); % initialize the random number generator to make the results in this example repeatable. 

% Load Signal
emg = load('emg1.mat', '-mat');

% Calculate FFT
np2 = 2^nextpow2(length(emg.x));
emg.X = abs(fftshift(fft(emg.x, np2)));
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
area(linspace(-0.5*emg.fs, 0.5*emg.fs, np2), 10*log10(emg.X), 'FaceColor','b','FaceAlpha',.8,'EdgeAlpha',.02,'EdgeColor','k');
grid on;
grid minor;
set(get(gca,'XLabel'),'String','Frequencies [Hz]');
set(get(gca,'YLabel'),'String','Magnitude [dB]');
title('FFT - EMG Signal');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',26);

% Add Harmonic Events in EMG Signal
emg.xn = emg.x;
freq = linspace(0.75*emg.fs/2, 0.9*emg.fs/2, 200);
% First Event in 1s
emg.xn = aditiveHarmonicNoise(emg.xn, emg.fs, round(1*emg.fs), 100e-3, freq, 0.7);
% First Event in 2s
emg.xn = aditiveHarmonicNoise(emg.xn, emg.fs, round(2*emg.fs), 100e-3, freq, 0.7);
% First Event in 3s
emg.xn = aditiveHarmonicNoise(emg.xn, emg.fs, round(3*emg.fs), 100e-3, freq, 0.7);

% Calculate FFT
emg.Xn = abs(fftshift(fft(emg.xn, np2)));
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
area(linspace(-0.5*emg.fs, 0.5*emg.fs, np2), 10*log10(emg.X), 'FaceColor','b','FaceAlpha',.2,'EdgeAlpha',.02,'EdgeColor','k');
hold on;
area(linspace(-0.5*emg.fs, 0.5*emg.fs, np2), 10*log10(emg.Xn), 'FaceColor','r','FaceAlpha',.7,'EdgeAlpha',.02,'EdgeColor','k');
grid on;
grid minor;
legend('Original Signal', 'Harmonic Events');
set(get(gca,'XLabel'),'String','Frequencies [Hz]');
set(get(gca,'YLabel'),'String','Magnitude [dB]');
title('FFT - EMG Signal with Harmonic Events');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',26);

% Scalogram Functions to PATH
addpath('../utils_P1/');
addpath('../filterbanks/');
rehash path;
% Set Colormap
gray_ = flipud(gray);
% Plot Scalogram
dwtScalogram(emg.xn, emg.fs, 'db2', 3);
colormap(gray_);
title('Scalogram: db2 - 3 Levels for EMG with Events');
dwtScalogram(emg.x, emg.fs, 'db2', 3);
a = dwtScalogram(emg.x(0.8*emg.fs:1.2*emg.fs), emg.fs, 'db2', 3);
title('Scalogram: db2 - 3 Levels for EMG');
colormap(gray_);
% Scalogram
dwtScalogram(emg.xn, emg.fs, 'dmey', 3);
colormap(gray_);
title('Scalogram: dmey - 3 Levels for EMG with Events');

% Spectrogram
win = hamming(round(150e-3*emg.fs));
stftSpectrogram(emg.xn, emg.fs, win, length(win)/2, 2^nextpow2(length(win)));
title('STFT Spectrogram: Hamming Window for EMG with Events');

dwtScalogram(emg.xn, emg.fs, 'dmey', 4);
colormap(gray_);
title('Scalogram: dmey - 4 Levels for EMG with Events');
