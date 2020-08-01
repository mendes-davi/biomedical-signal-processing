function h = filter_iterator(h0, h1, levels);
	h{levels + 1} = h1;
	aux = h0;
	for n = levels : -1 : 2
		h_ = upsample(h{n + 1}, 2);
		h_ = h_(1 : length(h_) - 1);
		h{n} = conv(h_, h0);
		aux = upsample(aux, 2);
		aux = aux(1 : length(aux) - 1);
		aux = conv(aux, h0);
	end
	h{1} = aux;
end
