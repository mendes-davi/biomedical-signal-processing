clear all; close all; clc;

N = 1024;
Nh = 11;

N_ = N_output_h1(N, Nh);
[Na, Nb] = Nx(N_, Nh);

Na_ = N_output_h1(Na, Nh)
Nb_ = N_output_h1(Nb, Nh)
