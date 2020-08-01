function plot_frequency_responses_iterated_filters(h)
	for n = 1 : length(h)
		h_ = h{n};
		H_ = 0;
		[H_, w] = freqz(h_, [1], 20000);
		f = w / (2 * pi);
		plot(f, abs(H_));
		hold on;
	end
end
