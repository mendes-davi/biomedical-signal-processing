function [perfect_reconstruction, A, d] = evaluate_decomposition_synthesis_filters(h0, h1, g0, g1, tol);
	if ~exist('tol')
		tol = 1e-8;
	end
	h0_ = alternate_coefficients_signals(h0);
	h1_ = alternate_coefficients_signals(h1);
	alias_term = polynomial_sum(conv(h0_, g0), conv(h1_, g1));
	perfect_reconstruction = ~(any(~(abs(alias_term) < tol)));
	%perfect_reconstruction = (sum(abs(alias_term) < tol) == length(alias_term));
	lti_term = polynomial_sum(conv(h0, g0), conv(h1, g1));
	k = find(abs(lti_term) >= tol);
	perfect_reconstruction = ((length(k) == 1) & perfect_reconstruction);
	if ~perfect_reconstruction
		k = find(abs(lti_term) == max(abs(lti_term)));
		k = k(1);
	end
	A = lti_term(k) / 2;
	d = k - 1;
end

function h_ = alternate_coefficients_signals(h);
	h_ = h;
	h_(2 : 2 : length(h_)) = -h_(2 : 2 : length(h_));
end

function z = polynomial_sum(x, y);
	x1 = zeros(max([length(x); length(y)]), 1);
	y1 = x1;
	x1(1 : length(x)) = x;
	y1(1 : length(y)) = y;
	z = x1 + y1;
	if(size(x, 2) > size(x, 1))
		z = z.';
	end
end
