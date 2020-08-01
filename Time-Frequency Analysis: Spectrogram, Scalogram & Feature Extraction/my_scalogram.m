clear all; close all; clc;

% Add Functions to PATH
addpath('../filterbanks/');
rehash path;

% Generate WEIRD Frequency Mod. Signal to test scalogram
fs = 100;
t = 0:1/fs:2;
x = (t.^2).*real((-1).^(fs.*t)) + sin(10*t);

% Plot Signal
figure;
plot(t,x);
title('Signal in Time Domain');
set(get(gca,'XLabel'),'String','Time [s]');
set(get(gca,'YLabel'),'String','Amplitude');
% saveas(gcf, 'scalogram_signal.png');

% Plot Scalogram
levels = 2;
sc = dwtScalogram(x, fs, 'haar', levels);
% saveas(gcf, 'scalogram.png');

% Plot Energy vs Time per Scale
figure;
legends = cell(1,levels+1);
for s = 1:levels+1
	plot(sc(s,:), 'LineWidth', 2);
	hold on;
	legends{s} = ['Scale' int2str(s)];
end
grid on;
legend(legends);
set(get(gca,'YLabel'),'String','Energy/Coefficient [%]');
set(get(gca,'XLabel'),'String','Wavelet Coefficients');
title('Energy/Coefficient per Scale');
% saveas(gcf, 'energy_scalogram.png');
