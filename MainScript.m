% Main Script for Yeh and Chapman, Sustech 2021

close all; clearvars; clc;

N_INIT = 3;
x2_deviations_mpc = cell(N_INIT,1);
x2_deviations_onoff = cell(N_INIT,1);
init_type = cell(N_INIT,1);
N_FIG = 4; % number of figures generated for each initial condition

init_type{1} = 'low-low';   % low initial values for x1 and x2
init_type{2} = 'high-low';  % high initial value for x1, low initial value for x2
init_type{3} = 'high-high'; % high initial values for x1 and x2

for i = 1 : N_INIT

    [x2_deviations_mpc{i}, x2_deviations_onoff{i}] = plot_results_init("wet", init_type{i}, i, N_FIG);

end

plot_results_all_init(x2_deviations_mpc, x2_deviations_onoff, N_INIT, init_type);
