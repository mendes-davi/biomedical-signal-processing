%%The efficacy of a transform depends on how much energy compaction is provided by the trans-
%%form. One way of measuring the amount of energy compaction afforded by a particular orthonormal
%%transform is to take a ratio of the arithmetic mean of the variances of the transform coefficient to their
%%geometric means. Reference: N.S. Jayant, P. Noll, Digital Coding of Waveforms, Prentice-Hall, 1984. 
%% transformCodingGain:
function [gtc] = transformCodingGain(xdc)
	% Join all the transform coefficients in a single array
	xdc = cellfun(@(data) data(:), xdc, 'UniformOutput', false);	
	xdc = vertcat(xdc{:});
	% Obtain Transform Coding Gain
	varAll = @(x) (abs(x-mean(x)).^2)/length(x);
	geomMeanVar = @(x) geomean(varAll(x));
	arithMeanVar = @(x) sum(varAll(x))/length(x);
	gtc = arithMeanVar(xdc)/geomMeanVar(xdc);
end