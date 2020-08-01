clear all; close all; clc;

% Test Signal: Linear Chirp
fs = 1024;
t = linspace(0, 8, 8*fs);
fchirp = @(t) 9*t;
x = 10*sin(2*pi*fchirp(t).*t);

win = hann(256);
lwin = length(win);
spectrogram(x, fs, win); 

%% spectrogram: function description
function [varargout] = spectrogram(x, fs, win, loverlap, nfft)
	% Treat Inputs
	narginchk(3,5);
	x = double(x(:));
	win = double(win(:));
	lwin = length(win);
	if ~exist('loverlap', 'var') || isempty(loverlap)
		loverlap = 0;
	end
	if ~exist('nfft', 'var') || isempty(nfft)
		nfft = lwin;
	end
	
	% Zero Padding if needed based on window length
	pad_size = ceil(length(x)/lwin)*lwin - length(x);
	x(length(x)+pad_size) = 0;
	% Reshape Signal
	if loverlap > 0
		ov_x = [];
		ov_x(:,1) = x(1:lwin);
		for n = 1:length(x)/loverlap-(lwin/loverlap)
			ov_x(:,n+1) = x(n*loverlap+1 : n*loverlap+lwin);	
		end
		x = ov_x;
	else 
		x = reshape(x, lwin, []);
	end	
	% Split Apply Function
	spect_vals = @(col) 20*log10(abs(fftshift(fft(win.*col, nfft))).^2);
	x = splitapply(spect_vals, x, 1:size(x,2));
	% Remove the bottom half of the spectrogram
	x = x(1:floor(end/2),:);
	
	% Provide Outputs (Plot or Matrix)
	switch nargout
		case 0 % Plot Spectrogram
			figure('units','normalized','outerposition',[0 0 1 1]);
			imagesc(x);
			colormap jet;
			hcb = colorbar;
			ylabel(hcb, 'Power/Frequency (dB/(Hz/sample))');
			set(get(gca,'YLabel'),'String', ['Frequency (Hz/sample) - Fres ' num2str((fs/2)/lwin, 2) ' Hz']); % TODO: Review Fres
			set(get(gca,'XLabel'),'String',['Windows (' int2str(lwin) ' samples - Tres ' num2str(1000*lwin/fs, 2) ' ms)']); % TODO: Review Tres
		case 1 % Return Spectrogram as matrix
			varargout{1} = x;		
		otherwise
			error('Error in varargout! Provide the right number of outputs.');
	end
end
