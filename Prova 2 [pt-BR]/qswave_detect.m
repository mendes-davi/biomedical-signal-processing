%% qswave_detect: Detect Q and S wave segments based on R location 
function [q_i, s_i] = qswave_detect(ecg, r_i) %TODO: optimize and refactor try catch
	s_i = zeros(length(r_i), 1);
	q_i = zeros(length(r_i), 1);
	th = 1;
	%% QS Wave Detect
	for pt = 1:length(r_i)
		% S
		n = 1;
		try 
			while (ecg(r_i(pt)+n) + th) >= ecg(r_i(pt)+n+1)
				n = n + 1;
			end
			s_i(pt) = r_i(pt)+n;
		catch ME
			switch ME.identifier
				case 'MATLAB:badsubscript' % R points near the end of the signal could trigger bad subscript (maybe? idk)
					continue;	
				otherwise
					rethrow(ME);
			end
		end
		% R
		try 
			n = -1;
			while (ecg(r_i(pt)+n) + th) >= ecg(r_i(pt)+n-1)
				n = n - 1;
			end
			q_i(pt) = r_i(pt)+n;
		catch ME
			switch ME.identifier
				case 'MATLAB:badsubscript'
					continue;	
				otherwise
					rethrow(ME);
			end
		end
	end
end