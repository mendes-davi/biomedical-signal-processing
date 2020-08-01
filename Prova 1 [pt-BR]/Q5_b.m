clear all; close all; clc;

% Add Functions to PATH
addpath("../utils_P1/");
rehash path;

% Load Signals
rec = 1;
sets = {'A', 'B', 'C', 'D', 'E'};
for n = 1:length(sets)
	r.(sets{n}) = loadSetRecords(sets{n}, rec, '../eeg_signals/');
end

% Set Feature Extractor Params
% function [temporal_features, frequency_features] = featureExtractor(data, fs, win, loverlap, zeropad, iirfilter, bands, nbands, boverlap, maxfreq, fmaxorder, ftol, fnum, fden)
fs = 173.61;
win = hamming(round(5*fs)); % 5 sec. win
loverlap = length(win)/2; % 50% overlap (2.5s)
zeropad = false; % no zero padding while reshaping windowed signal
iirfilter = @butter;
nbands = 5;
bands = [0 4; 4 7; 7 15; 16 31; 32 fs/2]./fs;
boverlap = 0;

% Iterate for all sets
rtf = cell(1, length(sets));
rff = cell(1, length(sets));
mtf = [];
mff = [];
for n = 1:length(sets)
	% Extract Features
	[rtf{n}, rff{n}] = featureExtractor(r.(sets{n}), fs, win, loverlap, zeropad, iirfilter, bands, nbands, boverlap);
	mtf(n,:) = mean(rtf{n}{:,:},1);
	mff(n,:) = 100*mean(rff{n}{:,1},1)/sum(mean(rff{n}{:,1},1));
end

mean_TF = array2table(mtf, 'VariableNames', {'RMS','RMV','STD'});
mean_FF = array2table(mff, 'VariableNames', {'Delta', 'Teta', 'Alfa', 'Beta', 'Gama'});
% fv_label = arrayfun(@num2str, 1:10, 'UniformOutput', false)