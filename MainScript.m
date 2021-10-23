% Main Script for Yeh and Chapman, Sustech 2021

close all; clearvars; clc;

init_type = 'low-low';     % low initial values for x1 and x2
%init_type = 'high-low';   % high initial value for x1, low initial value for x2
%init_type = 'high-high';  % high initial values for x1 and x2

plot_results("wet", init_type)
