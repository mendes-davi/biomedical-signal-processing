function [Na, Nb] = Nx(N1, Nh);
	Nfa = 2 * N1;
	Nfb = 2 * N1 - 1;
	Na = Nfa - Nh + 1;
	Nb = Nfb - Nh + 1;
end
