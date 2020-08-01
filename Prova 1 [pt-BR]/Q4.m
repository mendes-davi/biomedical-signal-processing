clear all; close all; clc;

% Add QMF Functions to PATH
addpath('../filterbanks/');
rehash path;

DATA = load('ecg_1.mat', '-mat');
x = DATA.x(:); fs = DATA.fs; 

% Process Data
NM = 5:100;
[xq, len] = dwtEcgQuant(x, 'db4', 4, NM);
[rx] = dwtEcgRec(xq, len, 'db4');

% Distortion Evaluation Metrics
SNR = @(ref_data, n_data) mean( n_data.^ 2 ) / mean( (n_data - ref_data).^2 );
PRD = @(ref_data, n_data) sqrt( (sum((ref_data - n_data).^ 2)) / (sum((ref_data).^2)) )*100;
% Compression Evaluation Metric (CR - Compression Ratio = OriginalSize/CompressedSize)
cr = length(x)./round(length(x) * (NM/100));

% Evaluate Distortion
snr = zeros(1, length(NM));
prd = zeros(1, length(NM));
for n = 1:length(rx)
	prd(n) = PRD(x, rx{n});
	snr(n) = SNR(x, rx{n});
end

% Plot Results
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
plot(NM, 10*log10(snr), 'LineWidth', 5);
hold on;
grid on;
grid minor;
title("DWT ECG Compression - db4 with 4 levels: SNR vs NM");
set(get(gca,'YLabel'),'String','SNR [dB]');
set(get(gca,'XLabel'),'String','N_m [%]');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',32);
% Annotate 30+ dB Point
y = ceil(interp1(10*log10(snr), NM, [30], 'linear'));
db30 = find(NM == y);
stem(y, 10*log10(snr(db30)), 'filled', 'MarkerSize', 12);
legend('SNR vs NM', [num2str(10*log10(snr(db30)),3) ' dB Marker (NM = ' int2str(y) ')'], 'Location', 'northwest');

% PRD vs CR
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
plot(cr, prd, 'LineWidth', 5);
legend('PRD vs CR');
grid on;
grid minor;
xlim([0 13]);
title("DWT ECG Compression - db4 with 4 levels: PRD vs CR");
set(get(gca,'YLabel'),'String','PRD [%]');
set(get(gca,'XLabel'),'String','CR');
set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
set(gca,'FontSize',32);

% Plot Signal in time domain and reconstruction error
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
subplot(2,1,1);
start_time = 2; end_time = 6;
x_seg = x(start_time*fs:end_time*fs);
plot(linspace(start_time, end_time, length(x_seg)), rx{y}(start_time*fs : end_time*fs), 'LineWidth', 4);
hold on;
plot(linspace(start_time, end_time, length(x_seg)), x_seg, '--', 'LineWidth', 4);
title('Comparison: 30+ dB SNR Reconstructed Signal vs Original Signal');
l = legend([num2str(10*log10(snr(db30)),3) ' dB Marker (NM = ' int2str(y) ')'], 'Original Signal', 'Location', 'northwest');
set(findall(gcf,'type','text'), 'FontSize', 28, 'fontWeight', 'bold');
set(gca,'FontSize',28);
l.FontSize = 14;
hold off;
subplot(2,1,2);
area(linspace(start_time, end_time, length(x_seg)), abs(x_seg-rx{y}(start_time*fs : end_time*fs)), 'FaceColor', 'b', 'FaceAlpha', .3, 'EdgeAlpha', .3);
set(get(gca,'XLabel'),'String','Time [s]');
title('Absolute Reconstruction Error');
set(findall(gcf,'type','text'), 'FontSize', 28, 'fontWeight', 'bold');
set(gca,'FontSize',28);