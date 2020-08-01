clear all; close all; clc;

% Load EMG & ECG Data
emg = load('emg_1.mat');
ecg = load('ecg_1.mat');

% Calculate FFT
if(length(emg.x) > length(ecg.x)); np2 = 2^nextpow2(length(emg.x)); else np2 = 2^nextpow2(length(ecg.x)); end
emg.X = abs(fftshift(fft(emg.x, np2)));
ecg.X = abs(fftshift(fft(ecg.x, np2)));
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
area(linspace(-0.5*emg.fs, 0.5*emg.fs, np2), 10*log10(emg.X), 'FaceColor','b','FaceAlpha',.6,'EdgeAlpha',.015,'EdgeColor','k');
hold on;
grid on;
grid minor;
area(linspace(-0.5*ecg.fs, 0.5*ecg.fs, np2), 10*log10(ecg.X), 'FaceColor','r','FaceAlpha',.6,'EdgeAlpha',.015,'EdgeColor','k');
ylim([-35 65]);
legend('EMG', 'ECG');
set(get(gca,'XLabel'),'String','Frequencies [Hz]');
set(get(gca,'YLabel'),'String','Magnitude [dB]');
title('FFT - ECG & EMG Signals');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',26);

% Calculate Band Power for ECG & EMG
ecg.tp = bandpower(ecg.x-mean(ecg.x), ecg.fs, [0 ecg.fs/2]); % Using zero-mean signal for a fair comparison! 
ecg.bp = bandpower(ecg.x-mean(ecg.x), ecg.fs, [2 40]);
disp(['ECG power % between 2-40 Hz = ' num2str(100*(ecg.bp/ecg.tp),2) '%.']);
emg.tp = bandpower(emg.x, emg.fs, [0 emg.fs/2]); 
emg.bp = bandpower(emg.x, emg.fs, [2 150]); 
disp(['EMG power % between 2-150 Hz = ' num2str(100*(emg.bp/emg.tp),2) '%.']);

% DFT Filtering
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(2,1,1);
area(linspace(-0.5*ecg.fs, 0.5*ecg.fs, np2), 10*log10(ecg.X), 'FaceColor','b','FaceAlpha',.5,'EdgeAlpha',.015,'EdgeColor','k');
hold on;
ecg.Xf = fft(ecg.x, np2);
ecg.Xf = dftFiltering(ecg.Xf, ecg.fs, [58 62]);
ecg.Xf = dftFiltering(ecg.Xf, ecg.fs, [0 5]);
area(linspace(-0.5*ecg.fs, 0.5*ecg.fs, np2), 10*log10(abs(fftshift(ecg.Xf))), 'FaceColor','b','FaceAlpha',.8,'EdgeAlpha',.015,'EdgeColor','k');
set(get(gca,'XLabel'),'String','Frequencies [Hz]');
set(get(gca,'YLabel'),'String','Magnitude [dB]');
title('DFT Filtering for Powerline & Baseline Wandering');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',24);
subplot(2,1,2);
plot(linspace(0, length(ecg.x)/ecg.fs, length(ecg.x)), ecg.x-mean(ecg.x), 'LineWidth', 3);
hold on;
xr = real(ifft(ecg.Xf));
xr = xr(1:10*ecg.fs);
plot(linspace(0, length(xr)/ecg.fs, length(xr)), xr , 'LineWidth', 3);
set(get(gca,'XLabel'),'String','Time [s]');
set(get(gca,'YLabel'),'String','Amplitude');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',24);
l = legend('Original Signal (zero-mean)', 'DTF Filtered');
l.FontSize = 20;

% FIR Filtering
forder = 150;
low = 8/ecg.fs;
band = [56*2/ecg.fs 64*2/ecg.fs];
h = fir1(forder, [low band]);
hnd = fvtool(h,1);
hnd.Fs = ecg.fs;
hnd.FrequencyRange='[0, Fs/2)';
ecg.xf = filter(h,1, ecg.x);

figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(2,1,1);
area(linspace(-0.5*ecg.fs, 0.5*ecg.fs, np2), 10*log10(abs(fftshift(fft(ecg.xf, np2)))), 'FaceColor','b','FaceAlpha',.8,'EdgeAlpha',.015,'EdgeColor','k');
hold on;
area(linspace(-0.5*ecg.fs, 0.5*ecg.fs, np2), 10*log10(ecg.X), 'FaceColor','b','FaceAlpha',.4,'EdgeAlpha',.015,'EdgeColor','k');
set(get(gca,'XLabel'),'String','Frequencies [Hz]');
set(get(gca,'YLabel'),'String','Magnitude [dB]');
title('FIR Filtering for Powerline & Baseline Wandering');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',24);

subplot(2,1,2);
plot(linspace(0, length(ecg.x)/ecg.fs, length(ecg.x)), ecg.x-mean(ecg.x), 'LineWidth', 3);
hold on;
plot(linspace(0, length(ecg.xf)/ecg.fs, length(ecg.xf)), ecg.xf , 'LineWidth', 3);
set(get(gca,'XLabel'),'String','Time [s]');
set(get(gca,'YLabel'),'String','Amplitude');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',24);
l = legend('Original Signal (zero-mean)', 'FIR Filtered');
l.FontSize = 20;


%% dftFiltering: function description
function [X] = dftFiltering(X, fs, fc)
	N = length(X);
	k1 = round(fc(1) * N / fs + 1); % Considering 0 <= fc <= fs/2
	k2 = round(fc(2) * N / fs + 1);
	k3 = round((fs-fc(2)) * N / fs + 1);
	k4 = round((fs-fc(1)) * N / fs + 1);
	if k4 > length(X) 
		k4 = length(X); 
		k3 = k3-1; 
	end % Exception for low cut freq. = 0 Hz (k4 overflows to length(X)+1)
	X(k1:k2) = 0;
	X(k3:k4) = 0;
	disp(['For ' int2str(fc(1)) '-' int2str(fc(2)) 'Hz, using: ' int2str(k1) ' to ' int2str(k2) ' and ' int2str(k3) ' to ' int2str(k4) '.']);
end