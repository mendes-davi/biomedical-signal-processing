%% aditiveHarmonicNoise: Aditive Harmonic Noise with len_s s. duration for freq frequencies with limited max energy
function [x] = aditiveHarmonicNoise(x, fs, startp, len_s, freq, p_energy)
	len = round(len_s*fs);
	endp = startp + len;
	
	% Obtain RMS value for the segment
	max_energy = p_energy*rms(x(startp:endp));
	% Obtaind Max Amplitude for each sinusoid
	max_amp = (sqrt(2)*max_energy) / (sqrt(length(freq)));

	% Generate Noise
	sn = zeros(1, endp-startp+1);
	tn = linspace(0, len_s, endp-startp+1);
	for n = 1:length(freq)
		ramp = -0 + (max_amp-0)*randn;
		sn = sn + ramp*sin(2*pi*freq(n)*tn);
	end
	% Add Noise to signal
	x(startp:endp) = x(startp:endp) + sn(:);
end