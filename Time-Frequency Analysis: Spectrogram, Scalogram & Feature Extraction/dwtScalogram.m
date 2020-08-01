%% dwtScalogram: function description
function [varargout] = dwtScalogram(x, fs, filter_type, levels)
	% Treat Inputs
	if class(filter_type) == 'char' 
		[h0, h1, ~, ~] = wfilters(filter_type);
	elseif class(filter_type) == 'cell' 
		h0 = filter_type{1};
		h1 = filter_type{2};
	else
		error('Error in filter_type! Provide {h0, h1} as a cell array or use MATLAB std filters!');
	end

	% Perform Decomposition
	[~, xdc, ~] = qmf_decomposition(x, h0, h1, levels);

	% Interpolate frame
	len_xdc = cellfun(@length, xdc);
	max_len = max(len_xdc(:));
	frame = zeros(levels+1,max_len);
	for l = 1:levels+1
		xi = linspace(0, length(x)*fs, length(xdc{l}));
		xq = linspace(0, length(x)*fs, max_len);
		y = xdc{l}.^2;
		y = 100 * y/sum(y);
		frame(l,:) = interp1(xi, y, xq, 'nearest');
	end

	figure('units','normalized','outerposition',[0 0 1 1]);
	imagesc(frame);
	title('Scalogram');
	colormap parula;
	hcb = colorbar;
	ylabel(hcb, 'Energy/Coefficient [%]');
	set(get(gca,'XLabel'),'String','Time');
	set(gca,'YTick', 1:levels+1);
	fv_label = arrayfun(@num2str, levels+1:-1:1, 'UniformOutput', false);
	yticklabels('manual');
	yticklabels(fv_label);
	set(get(gca,'YLabel'),'String','Scale');
	set(findall(gcf,'type','text'), 'FontSize', 22, 'fontWeight', 'bold');
	set(gca,'FontSize',16);

	% Provide Outputs
	if nargout == 1
		varargout{1} = frame;
	elseif nargout > 1
		error('Error with varargout outputs!');
	end
end

