clear; close all; clc;

[h0, h1] = wfilters('db4');
Ni = 20;

h = filter_iterator(h0, h1, Ni);

for n = 1 : length(h)
	figure;
	plot(0 : length(h{n}) - 1, h{n});
end
