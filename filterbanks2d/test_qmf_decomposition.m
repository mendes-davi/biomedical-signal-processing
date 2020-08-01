clear all; close all; clc;

load('ecg06.mat', 'x');
x = x(1 : 1024);
[h0, h1, g0, g1] = wfilters('bior6.8');

for levels = 4 : 4
	[xd, xdc, h] = qmf_decomposition(x, h0, h1, levels);
	figure
	plot_frequency_responses_iterated_filters(h);
	figure;
	plot(xd);
	title(['Transformada db5 do sinal de ECG, com ' num2str(levels)])
	hold on;
	M = max(xd);
	m = min(xd);
	l = 1;
	plot([l l], [m M], 'r', 'linewidth', 4);
	for n = 1 : levels + 1
		l = l + length(xdc{n});
		plot([l l], [m M], 'r', 'linewidth', 4)
	end
	[xr, xdelay, compensatory_delay] = qmf_reconstruction(xdc, h0, h1, g0, g1);
end

pause;

close all
plot(x); title('Sinal original')
figure;
plot(xr); title('Sinal reconstruído')
figure;
plot(xr(1:length(x))-x)
title('Erro de reconstrução')

figure;
plot(x, 'b', 'linewidth', 5);
hold on; plot(xr, 'r--', 'linewidth', 5)
