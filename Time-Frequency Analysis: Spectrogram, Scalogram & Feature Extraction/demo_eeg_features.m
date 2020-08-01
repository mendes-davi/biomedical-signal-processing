clear all; close all; clc;

A1 = loadSetRecords('A', 1, '../eeg_signals/');
E1 = loadSetRecords('E', 1, '../eeg_signals/');
fs = 173.61;
lwin_sec = 0.8;
win = hamming(round(lwin_sec*fs));
loverlap = round(lwin_sec*fs/5);
nbands = 5;

% [features_table] = featureExtractor(data, fs, win, loverlap, zeropad, iirfilter, bands, nbands, boverlap, maxfreq, fmaxorder, ftol, fnum, fden)
[A_tf, A_ff] = featureExtractor(A1, fs, win, loverlap, false, [], [], nbands);
[E_tf, E_ff] = featureExtractor(E1, fs, win, loverlap, false, [], [], nbands);

% Plot Results
figure;
scatter(A_tf.RMS, A_tf.RMV, 'filled', 'd');
hold on;
grid on;
scatter(E_tf.RMS, E_tf.RMV, 'filled', 'o');
legend('A1 Record', 'E1 Record', 'Location', 'northwest');
set(get(gca,'XLabel'),'String','RMS Value');
set(get(gca,'YLabel'),'String','RMV Value');
title('Feature Comparison: RMS vs RMV');
set(findall(gcf,'type','text'), 'FontSize', 22, 'fontWeight', 'bold');
set(gca, 'FontSize', 16);

figure;
legend_titles = {};
for b = 1:nbands
	scatter(A_ff.MEANFREQ(:,b), A_ff.MEDFREQ(:,b), 'filled', 'd');
	hold on;
	scatter(E_ff.MEANFREQ(:,b), E_ff.MEDFREQ(:,b), 'filled', 'o');
	legend_titles{end+1} = ['A Rec. - F. Band ' int2str(b)];
	legend_titles{end+1} = ['E Rec. - F. Band ' int2str(b)];
end
l = legend(legend_titles, 'Location', 'northwest', 'NumColumns', 2);
set(get(gca,'XLabel'),'String','Mean Frequency Value');
set(get(gca,'YLabel'),'String','Median Frequency Value');
title('Mean vs Median Frequency per Band');
set(findall(gcf,'type','text'), 'FontSize', 22, 'fontWeight', 'bold');
set(gca, 'FontSize', 16);
l.FontSize = 8;
grid on;

% legend('A1 Record', 'E1 Record', 'Location', 'northwest');
% set(get(gca,'XLabel'),'String','RMS Value');
% set(get(gca,'YLabel'),'String','RMV Value');
% title('Feature Comparison: RMS vs RMV');
% set(findall(gcf,'type','text'), 'FontSize', 22, 'fontWeight', 'bold');
% set(gca,'FontSize',18);
