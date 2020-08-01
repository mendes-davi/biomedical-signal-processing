%% dwt2dReconstruction: Provides a simple wrapper to reconstruct multiple images using qmf_reconstruction_2 
function [xr] = dwt2dReconstruction(xdc, waveletf, img_size)
	[h0, h1, g0, g1] = wfilters(waveletf);
	xr = zeros(img_size(1), img_size(2), length(xdc));
	for n = 1:length(xdc)
		[xr(:,:,n), ~, ~, ~] = qmf_reconstruction_2d(xdc{n}, h0, h1, g0, g1, img_size(1), img_size(2));
	end	
end
