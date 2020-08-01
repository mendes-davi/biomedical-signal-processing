clear all; close all; clc;

alterSignal = @(x) upsample(downsample(x,2),2) + circshift(upsample(-x(2:2:end),2),1);
Ha = [-0.3327 0.8069 -0.4599 -0.1350 0.0854 0.0352]
Hb = alterSignal(flip(Ha)) % (-1^n)Ha[m-n]
Ga = -alterSignal(Ha) % -(-1^n)Ha
Gb = alterSignal(Hb) % (-1^n)Hb

h1 = Ha;
h0 = Hb;
g1 = Gb;
g0 = Ga;


addpath('../filterbanks/');
h = filter_iterator(h0, h1, 4);
plot_frequency_responses_iterated_filters(h);
