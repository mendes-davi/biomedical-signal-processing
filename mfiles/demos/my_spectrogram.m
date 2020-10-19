clear all; close all; clc;

% A ideia é gerar um sinal do tipo chirp, são sinais que a freq. aumenta com o tempo.
% Nesse caso faremos um chirp linear e observaremos uma reta no espectrograma.
% A ideia do espectrograma é poder analisar o comportamento das frequências ao longo do tempo.
% Para tal, usamos a Transformada de Fourier Janelada (Short Time FT / Windowed FT)...
% Também será usada uma função que recorta o nosso sinal em janelas que se sobrepõe para obter uma
% observação mais detalhada.
% Para o exemplo usaremos uma janela do tipo retangular e sobreposição de 1/4 da duração da janela.

% Generate Chirp Signal
fs = 2048;
fchirp = @(t) 20*t;
[x, t] = chirpGenerator(10, 8, fs, fchirp);

% Plot STFT Spectrogram
win = ones(1, 256);
lwin = length(win);
stftSpectrogram(x, fs, win, lwin/4, 1024);
% saveas(gcf, 'linear_chirp_spectrogram.png');

%% chirpGenerator: Generate Chirp Signals
function [x, t] = chirpGenerator(amp, duration, fs, chirp_fun)
	t = 0: 1/fs : duration;
	x = amp*sin(2*pi*chirp_fun(t).*t);
end

%% stftSpectrogram: Spectrogram using Short-Time FT
function [varargout] = stftSpectrogram(x, fs, win, loverlap, nfft, zeropad)
	% Treat Inputs
	if ~exist('loverlap', 'var') || isempty(loverlap)
		loverlap = 0;
	end
	x = double(x(:));
	win = double(win(:));
	lwin = length(win);
	if ~exist('nfft', 'var') || isempty(nfft)
		nfft = lwin;
	end
	if ~exist('zeropad', 'var')
		zeropad = false;
	end

	% Reshape Signal without Zero Padding
	x = reshapeOverlap(x, lwin, loverlap, zeropad);

	% Split Apply Function
	spect_vals = @(col) 10*log10(abs(fftshift(fft(win.*col, nfft))).^2);
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
			ylabel(hcb, 'Energy/Frequency (dB/(Hz/sample))');
			set(get(gca,'YLabel'),'String', ['Frequency (Hz/sample) - Fres ' num2str(fs/nfft, 2) ' Hz']);
			ticks = linspace(1, size(x,1), 16);
			yticks('manual');
			yticks(ticks);
			fv_label = arrayfun(@num2str, round(flip(ticks)*fs/nfft, 1), 'UniformOutput', false);
			labelf = @(freq) [freq ' Hz'];
			fv_label = cellfun(labelf, fv_label, 'UniformOutput', false);
			yticklabels('manual');
			yticklabels(fv_label);
			set(get(gca,'XLabel'),'String',['Windows (' int2str(lwin) ' samples - Tres ' num2str(1000*lwin/fs, 5) ' ms)']);
			set(findall(gcf,'type','text'), 'FontSize', 22, 'fontWeight', 'bold');
			set(gca,'FontSize',22);
		case 1 % Return Spectrogram as matrix
			varargout{1} = x;
		otherwise
			error('Error in varargout! Provide the right number of outputs.');
	end
end

%% reshapeOverlap: Provides a reshape function that allows overlapping
function [x] = reshapeOverlap(x, lwin, loverlap, zeropad)
	x = double(x(:));
	if ~exist('loverlap', 'var') || isempty(loverlap)
		loverlap = 0;
	end
	if ~exist('zeropad', 'var') % Enables Zero Padding by default
		zeropad = true;
	end
	if zeropad
		% Zero Padding if needed based on window length and overlapping conditions
		n_win = ceil((length(x)-lwin)/(lwin-loverlap));
		pad_size = n_win*(lwin-loverlap)+lwin - length(x);
		x(length(x)+pad_size) = 0;
		warning('reshapeOverlap:ZeroPadW', ['Zero Padding in ' int2str(pad_size) ' elements.']);
	else
		n_win = floor((length(x)-lwin)/(lwin-loverlap));
		missed_elements = ceil((length(x)-lwin)/(lwin-loverlap))*(lwin-loverlap)+lwin - length(x);
		if missed_elements > 0
			warning('reshapeOverlap:ZeroPadW', ['Reshaped Signal doesn''t contains ' int2str(missed_elements) ' elements because Zero Padding is false']);
		end
	end
	% Reshape Signal
	ov_x = zeros(lwin,n_win);
	for n = 0:n_win
		strp = n*(lwin-loverlap)+1;
		ov_x(:,n+1) = x(strp : strp+lwin-1);
	end
	x = ov_x;
end
