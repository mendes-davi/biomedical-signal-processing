function [recs] = loadSetRecords(rset, nrecord, dataPath)
	% Treat Inputs
	if isempty(nrecord)
		nrecord = 1:100;
	end
	if ~exist('dataPath', 'var')
		dataPath = [];
	end

	% Load Signals
	recs = zeros(4097, length(nrecord));
	file_prefix = {'Z', 'O', 'N', 'F', 'S'};
	for n = 1:length(nrecord)
		try
			rec_fname = sprintf('%sset%c/%c%.3d.txt', dataPath, rset, file_prefix{rset-'A'+1}, nrecord(n));
			recs(:,n) = load(rec_fname, '-ascii');
		catch ME
			switch ME.identifier
				case 'MATLAB:load:couldNotReadFile'
					rec_fname = sprintf('%sset%c/%c%.3d.TXT', dataPath, rset, file_prefix{rset-'A'+1}, nrecord(n));
					recs(:,n) = load(rec_fname, '-ascii');
				otherwise
					rethrow(ME);
			end
		end
	end
end

