clear all; close all; clc;

% Add Functions to PATH
addpath("../utils_P1/");
rehash path;

% Load A & D Sets
sets_PATH = '~/Dropbox/processamento_sinais_biologicos_02_2019/programas_sinais_exemplos/sinais_eeg_epilepsia_e_grupo_controle/sinais/';
rec = 1:1:100;
A = loadSetRecords('A', rec, sets_PATH);
D = loadSetRecords('D', rec, sets_PATH);

% Feature Extractor Basic Params
fs = 173.61;
win = hamming(round(5*fs)); % 5 sec. win
loverlap = length(win)/2; % 50% overlap (2.5s)
zeropad = false; % no zero padding while reshaping windowed signal
iirfilter = @butter;
boverlap = 0;
nbands = {};
bands = {};

% Strategy 1 Params
nbands{1} = 5;
bands{1} = [0 4; 4 7; 7 15; 16 31; 32 fs/2]./fs;
% Strategy 2 Params
nbands{2} = 10;
bands{2} = [];
% Strategy 3 Params
nbands{3} = 1;
bands{3} = [];

A_ff = cell(length(rec), 3);
D_ff = cell(length(rec), 3);
A_tf = cell(length(rec), 3); % Temporal Feature - RMS Value
D_tf = cell(length(rec), 3); % Temporal Feature - RMS Value 
try
	load('A-D_features.mat');
catch ME
	if ~isequal(ME.identifier, 'MATLAB:load:couldNotReadFile')
		rethrow(ME);
	end
	% Apply featureExtractor to all the records
	for n = 1:length(rec)
		% First Strategy
		[A_tf{n,1}, A_ff{n,1}] = featureExtractor(A(:,n), fs, win, loverlap, zeropad, iirfilter, bands{1}, nbands{1}, boverlap);
		[A_tf{n,1}, D_ff{n,1}] = featureExtractor(D(:,n), fs, win, loverlap, zeropad, iirfilter, bands{1}, nbands{1}, boverlap);
		% Second Strategy
		x = A(:,n);
		fmfunc = @(fm) abs(0.95*bandpower(x, fs, [0 (length(x)-1)*fs/(2*length(x))]) - bandpower(x, fs, [0 fm]));
		fm = fminsearch(fmfunc, 1); % Find fm starting in 1 Hz
		[A_tf{n,2}, A_ff{n,2}] = featureExtractor(A(:,n), fs, win, loverlap, zeropad, iirfilter, bands{2}, nbands{2}, boverlap, fm);
		x = D(:,n);
		fmfunc = @(fm) abs(0.95*bandpower(x, fs, [0 (length(x)-1)*fs/(2*length(x))]) - bandpower(x, fs, [0 fm]));
		fm = fminsearch(fmfunc, 1); % Find fm starting in 1 Hz
		[D_tf{n,2}, D_ff{n,2}] = featureExtractor(D(:,n), fs, win, loverlap, zeropad, iirfilter, bands{2}, nbands{2}, boverlap, fm);
		% Third Strategy
		[A_tf{n,3}, A_ff{n,3}] = featureExtractor(A(:,n), fs, win, loverlap, zeropad, iirfilter, bands{3}, nbands{3}, boverlap);
		[D_tf{n,3}, D_ff{n,3}] = featureExtractor(D(:,n), fs, win, loverlap, zeropad, iirfilter, bands{3}, nbands{3}, boverlap);
	end
end

A_all_features = cell(1, 3);
D_all_features = cell(1, 3);
for s = [1,2]
	for n = 1:size(A_ff,1)
		A_all_features{s} = [A_all_features{s}; A_ff{n,s}{:,1}];
		D_all_features{s} = [D_all_features{s}; D_ff{n,s}{:,1}];
		A_all_features{3} = [A_all_features{3}; A_tf{n,3}{:,1} A_ff{n,3}{:,2:end}];
		D_all_features{3} = [D_all_features{3}; D_tf{n,3}{:,1} D_ff{n,3}{:,2:end}];
	end
end
save('A-D_selectedFeatures.mat', 'A_all_features', 'D_all_features');
