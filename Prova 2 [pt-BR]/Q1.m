clear all; close all; clc;

% Add Filterbanks2D to PATH
addpath('../filterbanks2d');
rehash path;

% P2 Signals Path
joinDataPath = @(file) ['/home/davi/Dropbox/processamento_sinais_biologicos_02_2019/sinais_prova_2/' file];

% Load Images
load(joinDataPath('example2.mat'), 'x');
levels = 3:1:5;
imgs = {x{6}, x{12}};
waveletf = {'db3', 'sym4', 'bior3.1'};
xd = cell(length(levels), length(imgs), length(waveletf));
xdc = cell(length(levels), length(imgs), length(waveletf));

% A)
try % Load saved data to improve runtime execution
	load('Q1.mat'); 
catch ME
	for im = 1:length(imgs)
		for wf = 1:length(waveletf)
			fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
			for l = 1:length(levels) 
				[h0, h1, g0, g1] = wfilters(waveletf{wf});
				[xd{l,im,wf}, xdc{l,im,wf}, ~] = qmf_decomposition_2d(imgs{im}, h0, h1, levels(l));
				subplot(1,length(levels),l);
				imshow(xd{l,im,wf}, []);
				gtc = transformCodingGain(xdc{l,im,wf});
				im_title = [int2str(im) '- For ' waveletf{wf} ' w. ' int2str(levels(l)) ' levels, GTC= ' num2str(gtc,5)];
				title(im_title);
				disp(im_title);
			end
			truesize(fig);
			% saveas(fig, [int2str(im) '_' waveletf{wf} '.png']);
		end
	end
	save('Q1.mat', 'xd', 'xdc');
end

% B)
NM = 30:100;
chosen_level = 5;
ilvl = find(levels == chosen_level);
for im = 1:length(imgs)
	figure('units', 'normalized', 'outerposition', [0 0 1 1]);
	for wf = 1:length(levels)
		im_title = ['SNR vs NM% : Image ' int2str(im) ' with ' int2str(chosen_level) ' levels'];
		[xq] = dwt2dQuantizer(xdc{ilvl,im,wf}, NM);
		xr = dwt2dReconstruction(xq, waveletf{wf}, size(imgs{im}));
		SNR = evaluateSNR(xr, imgs{im});
		plot(NM, SNR, 'LineWidth', 4);
		hold on;
	end
	title(im_title);
	legend(waveletf);
	xlim([0 100]);
	grid on;
	grid minor;
	set(get(gca,'YLabel'),'String','SNR [dB]');
	set(get(gca,'XLabel'),'String','NM [%]');
	set(findall(gcf,'type','text'), 'FontSize', 32, 'fontWeight', 'bold');
	set(gca,'FontSize', 26);
end

%% evaluateSNR: function description
function [snr_vals] = evaluateSNR(rimg, img)
	snr_vals = zeros(1, size(rimg,3));
	SNR = @(n_data, ref_data) mean( n_data(:).^ 2 ) / mean( (n_data(:) - ref_data(:)).^2 );
	for s = 1:size(rimg,3)
		snr_vals(s) = SNR(rimg(:,:,s), img);
	end
	snr_vals = 10*log10(snr_vals);
end