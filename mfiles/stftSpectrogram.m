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
