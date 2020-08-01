clear all; close all; clc;
% path add to dropbox folder
addpath('/Users/davimendes/Dropbox/processamento_sinais_biologicos_02_2019/programas_sinais_exemplos/filterbanks');

% Test Filter Iterator
% [h0, h1] = wfilters('db5');
% H = filter_iterator(h0, h1, 20);
% for f = 1:length(H)
% 	figure;
% 	plot(0:length(H{f}) - 1, H{f});
% end

load('ecg06.mat');
levels = 4;
[xd] = qmf_decomposition(x, h0, h1, levels);







%% filter_iterator: function description
function [h] = filter_iterator(h0, h1, levels)
	h{levels+1} = h1;
	h_f = h0;
	for n = levels : -1 : 2
		h_up = upsample(h{n+1}, 2);
		h_up = h_up(1 : length(h_up) - 1); % Remove zeros in the end
		h{n} = conv(h_up, h0);

		h_f = upsample(h_f, 2);
		h_f = h_f(1 : length(h_f) - 1);
		h_f = conv(h_f, h0);
	end
	h{1} = h_f;
end

%% qmf_decomposition: function description
function [xd] = qmf_decomposition(x, h0, h1, levels)
	h = filter_iterator(h0, h1, levels);
	xd = cell(1, levels + 1);
	downsample_factor = 1;
	for n = levels+1 : -1 : 2 
		downsample_factor = 2 * downsample_factor;
		xd{n} = downsample(conv(h{n}, x), downsample_factor);
	end
	xd{1} = downsample(conv(h{1}, x), downsample_factor);
end

%% qmf_reconstruction: function description
function [xr, c_delay] = qmf_reconstruction(xdc, h0, h1, g0, g1)
	levels = length(xd) - 1; % calculate levels
	G = filter_iterator(g0, g1, levels);
	[~, ~, d] = eval_decomposition_synthesis_filters(h0, h1, g0, g1); % calculate delay based on filters
	c_delay = d;
	signal_len = [];
	iscol = size(xdc{1}, 2) > size(xdc{1}, 1);
	upsample_factor = 2^levels;
	
	% Perform Reconstruction
	for n = 1:2
		xdc{n} = upsample(xdc{n}(:), upsample_factor);
		xdc{n} = xdc{n}(1 : length(xdc{n})-upsample_factor+1);
		xdc{n} = conv(G{n}, xdc{n});
		signal_len = [signal_len length(xdc{n})];
	end
	for n = 3:levels+1
		xdc{n} = [zeros(c_delay, 1); xdc{n}(:)];
		c_delay = c_delay + 2^(n-2)*d;
		upsample_factor = upsample_factor / 2;
		xdc{n} = upsample(xdc{n}, upsample_factor);
		xdc{n} = xdc{n}(1 : length(xdc{n})-upsample_factor+1);
		xdc{n} = conv(G{n}, xdc{n});
		signal_len = [signal_len length(xdc{n})];
	end

	% Sum Reconstructed Values
	signal_len = max(signal_len);
	xr = zeros(signal_len, 1);
	for n = 1:levels+1
		xr = xr + [xdc{n}; zeros(signal_len - length(xdc{n}), 1)];
	end
	xr = xr(c_delay+1 : end) / A;
end
