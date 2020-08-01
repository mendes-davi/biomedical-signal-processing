clear all; close all; clc;

% Load Features
load('A-D_selectedFeatures.mat', 'A_all_features', 'D_all_features');
sessions = 500;

% Perform SVM Classification
confusion_matrix = zeros(2,2,sessions,3);
for s = 1:sessions
	disp(s);
	for n = 1:3
		[svm, out_train, out_val, c_train, c_val, f_train, f_val] = svm2ClassRandperm(0.8, A_all_features{n}, D_all_features{n});
		confusion_matrix(:,:,n,s) = confusionmat(out_val, c_val);
	end
end

% Plot Confusion Matrix Chart
for n = 1:3
	chart_title =  ['Strategy ' int2str(n) ' - Validation in ' int2str(sessions) ' sessions.'];
	confusionChart(mean(confusion_matrix(:,:,n,:),4), chart_title);
end

% ROC Metrics
plotSessionResults(confusion_matrix);

%% plotSessionResults: Obtain ROC Metrics 
function plotSessionResults(confusion_matrix)
	% Metrics
	fpRate = @(cm) cm(1,2)/sum(cm(:,2));
	tpRate = @(cm) cm(1,1)/sum(cm(:,1));
	precision = @(cm) cm(1,1)/sum(cm(1,:));
	accuracy = @(cm) sum(diag(cm))/sum(cm(:));
	recall = @(cm) cm(1,1)/sum(cm(:,1));
	fMeasure = @(cm) 2/( 1/precision(cm) + 1/recall(cm) );

	% Display in console
	disp(['FP Rate is ' num2str(fp_val(confusion_matrix),4)]);
	disp(['TP Rate is ' num2str(tp_val(confusion_matrix),4)]);
	disp(['Precision is ' num2str(precision_val(confusion_matrix),4)]);
	disp(['Accuracy is ' num2str(accuracy_val(confusion_matrix),4)]);
	disp(['Recall is ' num2str(recall_val(confusion_matrix),4)]);
	disp(['F-Measure is ' num2str(fMeasure_val(confusion_matrix),4)]);
	disp(' ');
end

%% confusionChart: Plot Confusion Matrix Chart 
function [varargout] = confusionChart(C, chart_title)
	C = round(100*C/(sum(C(:))/2),2);
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
