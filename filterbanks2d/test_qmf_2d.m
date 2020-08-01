clear all; close all; clc;

% x = zeros(128, 128);
% x(10 : 92, 40:60) = 1;
% x(40 : 60, 10 : 92) = 1;
load('head.mat', 'x');
imshow(x, [])
levels = 4;
[h0, h1, g0, g1] = wfilters('sym8');
[xd, xdc, h] = qmf_decomposition_2d(x, h0, h1, levels);
figure; imshow(xd, [])
[xr, xdelay, compensatory_delay, y] = qmf_reconstruction_2d(xdc, h0, h1, g0, g1, size(x, 1), size(x, 2));
figure; imshow(xr, [])
