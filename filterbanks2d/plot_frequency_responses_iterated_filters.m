function plot_frequency_responses_iterated_filters(h);
	%f = linspace(0, 0.5, 20000);
	%z = exp(1j * 2 * pi * f);
	for n = 1 : length(h)
		h_ = h{n};
		H_ = 0;
		%for m = 1 : length(h_)
		%	H_ = H_ + h_(m) * z.^(-(m-1));
		%end
		[H_, w] = freqz(h_, [1], 20000);
		f = w / (2 * pi);
		plot(f, abs(H_));
		hold on;
	end
end
