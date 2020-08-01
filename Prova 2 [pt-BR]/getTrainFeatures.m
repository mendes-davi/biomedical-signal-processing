%% getTrainFeatures: function description
function [train_features, train_class] = getTrainFeatures(ecg_signals, train_set_index, train_i, win_samples, train_overlap, tol_win)
	w_indexes = reshapeOverlap(1:length(ecg_signals{1}), win_samples, round(win_samples * train_overlap/100), false);
	train_features = zeros(win_samples, length(train_set_index)*size(w_indexes,2));
	train_class = [];
	center_win = round(win_samples/2)-round(tol_win/2):round(win_samples/2)+round(tol_win/2);
	for n = 1:length(train_set_index)
		% Reshape Overlap ECG Signal
		ecg_w = reshapeOverlap(ecg_signals{train_set_index(n)}, win_samples	, round(win_samples * train_overlap/100), false);
		% Insert into Train Features Array
		col = 1+(n-1)*size(w_indexes,2);
		train_features(:,col:col+size(w_indexes,2)-1) = ecg_w;
		% Get QRS Index points
		qrs_i = train_i{train_set_index(n)};
		% Iterate over all windows to assign a class label	
		for s = 1:size(ecg_w,2)
			% Get current window indexes (center +- win_tol)
			c_win_i = w_indexes(center_win,s);
			% Assign Class
			train_class(end+1) = any(ismember(qrs_i, c_win_i));
		end
	end
	train_class = train_class(:);
	train_features = transpose(train_features);
end
