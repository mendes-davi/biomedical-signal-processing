%% svm2ClassRandperm: Performs SVM Classification using random permutation for the features
function [svm, out_train, out_val, c_train, c_val, f_train, f_val] = svm2ClassRandperm(a, feat_p, feat_n)
	rp = randperm(size(feat_p, 1));
	n = round(a * size(feat_p, 1));
	m = size(feat_p, 1) - n;
	r_train = rp(1 : n);
	r_val = rp(n + 1 : end);
	f_train = [feat_p(r_train, :); feat_n(r_train, :)];
	c_train = [ones(n, 1); zeros(n, 1)];
	f_val = [feat_p(r_val, :); feat_n(r_val, :)];
	c_val = [ones(m, 1); zeros(m, 1)];
	svm = fitcsvm(f_train, c_train, 'KernelFunction', 'rbf', 'Standardize', true, 'ClassNames', [0,1]);
	out_train = predict(svm, f_train);
	out_val = predict(svm, f_val);
end