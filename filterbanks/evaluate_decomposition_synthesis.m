clear all; close all; clc;

% Using haar filters
[h0, h1, g0, g1] = wfilters('haar');

% Test Functions
[perfect_reconstruction, A, d] = eval_decomposition_synthesis_filters(h0, h1, g0, g1)

%% qmf_decomposition_1level: function description
function [s_decomposition] = qmf_decomposition_1level(signal, h0, h1)
	w0 = conv(h0, signal);
	w1 = conv(h1, signal);
	x0 = downsample(w0,2);
	x1 = downsample(w1,2);
	s_decomposition = [x0(:); x1(:)];
end

%% qmf_reconstruction_1level: function description
function [s_reconstruction] = qmf_reconstruction_1level(s_decomposition, g0, g1)
	v0 = upsample(s_decomposition(:,1));
	v1 = upsample(s_decomposition(:,2));
	v0 = conv(v0, g0);
	v1 = conv(v1, g1);
	s_reconstruction = polynomial_sum(v0,v1);
end

%% eval_decomposition_synthesis_filters: evaluate perfect reconstruction, amplitude scaling and delay in synthesis filters
function [perfect_reconstruction, A, d] = eval_decomposition_synthesis_filters(h0, h1, g0, g1, tol)
	if ~exist('tol', 'var')
		tol = 1e-8;
	end
	
	% Check Alias Term
	h0_ = alternate_coeffs_signals(h0);
	h1_ = alternate_coeffs_signals(h1);
	alias_term = polynomial_sum(conv(h0_,g0), conv(h1_, g1));
	perfect_reconstruction = ~(any(~abs(alias_term < tol)));
	
	% Check LTI Term
	lti_term = polynomial_sum(conv(h0,g0), conv(h1,g1));
	k = find(abs(lti_term) >= tol);
	perfect_reconstruction = (perfect_reconstruction & (length(k) == 1));

	if ~perfect_reconstruction
		k = find(abs(lti_term) == max(abs(lti_term)));
		A = lti_term(k);
		d = k - 1;
	else
		d = k - 1; % 1 indexing
		A = lti_term(k);
	end
end

%% polynomial_sum: function description
function [psum] = polynomial_sum(a,b)
	len_diff = abs(length(a) - length(b));
	if length(a) > length(b)
		b(length(b)+1:length(b)+len_diff) = zeros(1,len_diff); % REFACTOR TO COLUNM VECTOR
	else
		a(length(a)+1:length(a)+len_diff) = zeros(1,len_diff);
	end
	psum = a + b;
end


%% alternate_coeffs_signals: Alternate the signal filter coefficients in order to produce F(-z)
function [coeffs_] = alternate_coeffs_signals(f_coeffs)
	coeffs_ = f_coeffs;
	coeffs_(2:2:length(coeffs_)) = -coeffs_(2:2:length(coeffs_));
end