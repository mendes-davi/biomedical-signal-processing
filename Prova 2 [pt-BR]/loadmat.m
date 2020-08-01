%% loadmat: Load .mat signals in a given folder path
function [signals, fs, s_name] = loadmat(s_path, s_fieldname)
% Load signals into a cell array
	signals = {};
	s_name = {};
	dir_files = dir(s_path);
	for f = 1:length(dir_files)
		if contains(dir_files(f).name, '.mat')
			MAT = load([s_path dir_files(f).name]);
			signals{end+1} = MAT.(s_fieldname);
			s_name{end+1} = dir_files(f).name;
			% Check for sampling frequency
			try
				fs = MAT.fs;
			catch ME
				switch ME.identifier
					case 'MATLAB:nonExistentField' 
						if ~exist('fs', 'var')
							fs = [];
						end
					otherwise
						rethrow(ME);
				end
			end
		end
	end
	if isempty(fs)
		warning('Sampling Frequency (fs) is empty in MAT files!');
	end
end
