clear all; close all; clc;

% Load Records
recs = 1:100;
A = loadSetRecords('A', recs, '../eeg_signals/');
E = loadSetRecords('E', recs, '../eeg_signals/');

% Feature Extractor Hyperparameters
fs = 173.61;
lwin_sec = 0.5;
win = hamming(round(lwin_sec*fs));
loverlap = round(lwin_sec*fs/5);
zeropad = false;
nbands = 4;
maxfreq = 40;

% Extract Features
A_RMS = []; E_RMS = []; 
A_RMV = []; E_RMV = [];
A_STD = []; E_STD = [];
A_E = []; E_E = [];
A_MEDFREQ = []; E_MEDFREQ = [];
A_MEANFREQ = []; E_MEANFREQ = [];
A_MODALFREQ = []; E_MODALFREQ = [];
for n = 1:length(recs) 
	% A Record Set
	warning('off', 'reshapeOverlap:ZeroPadW'); % Avoid overflow of warning messages while reshaping signal in featureExtractor
	[A_tf, A_ff] = featureExtractor(A(:,recs(n)), fs, win, loverlap, zeropad, [], [], nbands, [], maxfreq);
	A_RMS = [A_RMS A_tf.RMS];
	A_RMV = [A_RMV A_tf.RMV];
	A_STD = [A_STD A_tf.STD];
	A_E = [A_E; A_ff.E];
	A_MEDFREQ = [A_MEDFREQ; A_ff.MEDFREQ];
	A_MEANFREQ = [A_MEANFREQ; A_ff.MEANFREQ];
	A_MODALFREQ = [A_MODALFREQ; A_ff.MODALFREQ];
	% E Record Set
	[E_tf, E_ff] = featureExtractor(E(:,recs(n)), fs, win, loverlap, zeropad, [], [], nbands, [], maxfreq);
	E_RMS = [E_RMS E_tf.RMS];
	E_RMV = [E_RMV E_tf.RMV];
	E_STD = [E_STD E_tf.STD];	
	E_E = [E_E; E_ff.E];
	E_MEDFREQ = [E_MEDFREQ; E_ff.MEDFREQ];
	E_MEANFREQ = [E_MEANFREQ; E_ff.MEANFREQ];
	E_MODALFREQ = [E_MODALFREQ; E_ff.MODALFREQ];
end

% Plot Temporal Features
figure('units','normalized','outerposition',[0 0 1 1]);
scatter3(A_RMS,A_RMV,A_STD, 'filled');
hold on;
scatter3(E_RMS,E_RMV,E_STD, 'filled');
set(get(gca,'XLabel'),'String','RMS');
set(get(gca,'YLabel'),'String','RMV');
set(get(gca,'ZLabel'),'String','STD');
title('Temporal Features');
legend('Set A', 'Set E');

% Plot Frequency Features
figure('units','normalized','outerposition',[0 0 1 1]);
legend_titles = {};
for n = 1:nbands
	scatter3(A_MEANFREQ(:,n),A_MODALFREQ(:,n),A_MEDFREQ(:,n), 'filled');
	hold on;
	scatter3(E_MEANFREQ(:,n),E_MODALFREQ(:,n),E_MEDFREQ(:,n), 'filled');
	legend_titles{end+1} = ['A Rec. - F. Band ' int2str(n)];
	legend_titles{end+1} = ['E Rec. - F. Band ' int2str(n)];
end
hold off;
set(get(gca,'XLabel'),'String','MEANFREQ');
set(get(gca,'YLabel'),'String','MODALFREQ');
set(get(gca,'ZLabel'),'String','MEDFREQ');
title('Frequency Features - Modal & Mean & Median Frequencies');
legend(legend_titles);

% Plot Frequency Features - Energy
legend_titles = {};
figure('units','normalized','outerposition',[0 0 1 1]);
for n = 1:nbands
	scatter(A_MEANFREQ(:,n),A_E(:,n));
	hold on;
	scatter(E_MEANFREQ(:,n),E_E(:,n));
	legend_titles{end+1} = ['A Rec. - F. Band ' int2str(n)];
	legend_titles{end+1} = ['E Rec. - F. Band ' int2str(n)];
end
grid on;
hold off;
set(get(gca,'XLabel'),'String','Mean Frequency');
set(get(gca,'YLabel'),'String','Energy in Band');
title('Frequency Features - Energy vs Mean Frequency');
legend(legend_titles);


% Generate Tables
table_names = {'RMS', 'RMV', 'STD', 'E', 'MEDFREQ', 'MEANFREQ', 'MODALFREQ'};
A_temporal_features = table(A_RMS(:), A_RMV(:), A_STD(:), 'VariableNames', table_names(1:3));
E_temporal_features = table(E_RMS(:), E_RMV(:), E_STD(:), 'VariableNames', table_names(1:3));
A_frequency_features = table(A_E, A_MEDFREQ, A_MEANFREQ, A_MODALFREQ, 'VariableNames', table_names(4:end));
E_frequency_features = table(E_E, E_MEDFREQ, E_MEANFREQ, E_MODALFREQ, 'VariableNames', table_names(4:end));

% Write Tables
writetable(A_temporal_features, 'A_temporalFeatures.csv');
writetable(E_temporal_features, 'E_temporalFeatures.csv');
writetable(A_frequency_features, 'A_frequencyFeatures.csv');
writetable(E_frequency_features, 'E_frequencyFeatures.csv');
