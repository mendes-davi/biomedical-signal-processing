%% chirpGenerator: Generate Chirp Signals
function [x, t] = chirpGenerator(amp, duration, fs, chirp_fun)
	t = 0: 1/fs : duration;
	x = amp*sin(2*pi*chirp_fun(t).*t);
end
