clear; close all; clc;

[h0, h1, g0, g1] = wfilters('db42');
%[h0, h1, g0, g1] = wfilters('haar');


[perfect_reconstruction, A, d] = evaluate_decomposition_synthesis_filters(h0, h1, g0, g1);

load('ecg06.mat', 'x');
x = x(1:1000);
[xd, x0, x1] = qmf_decomposition_1level(x, h0, h1);
xr = qmf_reconstruction_1level(x0, x1, g0, g1);

xr_advanced = xr(d + 1 : length(x) + d);

figure; plot(x)
figure; plot(xd);
figure; plot(xr);
figure; plot(xr_advanced);
figure; plot(xr_advanced - x);

snr_db = 20 * log10(norm(x) / norm(xr_advanced - x));
disp([num2str(snr_db) 'dB'])
