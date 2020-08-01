clear all; close all; clc;

% Load SVM data and other Params
load('qrs_svm_r-data.mat');
center_win = round(win_samples/2)-round(tol_win/2):round(win_samples/2)+round(tol_win/2);
hit_wins = find(val_class == out_val);
size(hit_wins)
hit_wins = find(val_class(hit_wins) == 1);
size(hit_wins)
hit_features = val_features(hit_wins,:);

n_subplots = 4;
figure('units','normalized','outerposition',[0 0 1 1]);
for n = 1:n_subplots
	subplot(1,n_subplots,n);
	r = randi(size(hit_features,1));
	plot(hit_features(r,:), 'k', 'LineWidth', 2);
	max_pos = find(hit_features(r,:) == max(hit_features(r,:)));
	hold on;
	grid minor;
	stem(max_pos, hit_features(r,max_pos), 'r', 'filled', 'MarkerSize', 8, 'LineStyle', 'none');
	ylim([min(hit_features(r,:))-20 max(hit_features(r,:))+20]);
	xlim([0 360]);
end
