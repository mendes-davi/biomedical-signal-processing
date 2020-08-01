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
if isempty(fs); fs = 360; end
s_len = length(ecg_signals);

% Extract QRS Indexes
q_i = cell(1, s_len);
r_i = cell(1, s_len);
s_i = cell(1, s_len);
for n = 1:s_len
	[r_i{n}, ~] = rwave_detect(ecg_signals{n}, fs);	
	[q_i{n}, s_i{n}] = qswave_detect(ecg_signals{n}, r_i{n});
end

% SVM Params
alp = 0.7; % Percentage of data to the training stage
tol_win = 40; % Tolerance for the QRS position in window
win_samples = 1*fs;
train_overlap = 80; % Percentage of overlap in training windows
train_i = r_i;

% Extract Features
rand_set = randperm(s_len);
val_set_index = rand_set(1:round((1-alp)*s_len));
train_set_index = setdiff(rand_set,val_set_index);
% Training Features
[train_features, train_class] = getTrainFeatures(ecg_signals, train_set_index, train_i, win_samples, train_overlap, tol_win);
% Validation Features (same as train features but with no overlap)
[val_features, val_class] = getTrainFeatures(ecg_signals, val_set_index, train_i, win_samples, 80, tol_win);

% Perform Classification
svm = fitcsvm(train_features, train_class, 'KernelFunction', 'linear', 'Standardize', true, 'ClassNames', [0,1], 'Cost', [0, 1; 8, 0]);
% out_train = predict(svm, train_features);
out_val = predict(svm, val_features);

% Plot Confusion Matrix
% confusionChart(confusionmat(train_class, out_train), 'Training');
confusionChart(confusionmat(val_class, out_val), 'Validation');

% Get Session Results
disp('Validation Results:');
sessionResults(confusionmat(val_class, out_val));



%% sessionResults: Obtain ROC Metrics 
function sessionResults(confusion_matrix)
	% Metrics
	fpRate = @(cm) cm(1,2)/sum(cm(:,2));
	tpRate = @(cm) cm(1,1)/sum(cm(:,1));
	precision = @(cm) cm(1,1)/sum(cm(1,:));
	accuracy = @(cm) sum(diag(cm))/sum(cm(:));
	recall = @(cm) cm(1,1)/sum(cm(:,1));
	fMeasure = @(cm) 2/( 1/precision(cm) + 1/recall(cm) );

	% Display in console
	disp(['FP Rate is ' num2str(100*fpRate(confusion_matrix),4)]);
	disp(['TP Rate is ' num2str(100*tpRate(confusion_matrix),4)]);
	disp(['Precision is ' num2str(100*precision(confusion_matrix),4)]);
	disp(['Accuracy is ' num2str(100*accuracy(confusion_matrix),4)]);
	disp(['Recall is ' num2str(100*recall(confusion_matrix),4)]);
	disp(['F-Measure is ' num2str(100*fMeasure(confusion_matrix),4)]);
	disp(' ');
end

%% confusionChart: Plot Confusion Matrix Chart 
function [varargout] = confusionChart(C, chart_title)
	C(1,:) = 100*(C(1,:)/sum(C(1,:)));
	C(2,:) = 100*(C(2,:)/sum(C(2,:)));
	figure('units','normalized','outerposition',[0 0 1 1]);
	h = heatmap(C);
	h.ColorbarVisible = 'off';
	colormap white;
	title(chart_title);
	h.YLabel = 'True Class';
	h.XLabel = 'Predicted Class';
	set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
	set(gca,'FontSize',26);
	if nargout == 1
		varargout{1} = h;
	end
end