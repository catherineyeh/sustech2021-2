function [] = plot_mpc_lambdas(option)
% plots mpc overlaid
% 
rng('default');
config = fill_config();
pump = fill_pump_params(config);

x2_deviations = zeros(1, size(config.lambdas,2));

for i = 1 : size(config.lambdas, 2)
    
    % initial conditions
    x1bar = config.a1 * 50;
    x2bar = config.a2 * (config.zveg / 1.3);
    wrbar = 0; webar = 0;
    best_u = 0;
    total_x2_deviation = 0;
    
    % load data
    [wr, rn, temp, dew_pt, wind] = get_data(option, config);
    
    % initialize arrays
    x_overtime_mpc = zeros(2, config.sim_length + 1);
    best_u_overtime = zeros(1, config.sim_length + 1);
    we_overtime = zeros(1, config.sim_length + 1);
    wr_overtime = zeros(1, config.sim_length + 1);
    
    % MPC loop  
    for t = 0 : config.sim_length
        wr_n = get_lookahead(config.lookahead, t+1, wr);
        rn_n = get_lookahead(config.lookahead, t+1, rn);
        dew_pt_n = get_lookahead(config.lookahead, t+1, dew_pt);
        wind_n = get_lookahead(config.lookahead, t+1, wind);
        temp_n = get_lookahead(config.lookahead, t+1, temp);
        
        
        [A_hat, B_hat, C_hat, D_hat, L, Wtilde, yt, R_bar, Q_bar, We] = ... 
        get_linear_model(config, pump, config.lambdas(i), ... 
        x1bar, x2bar, best_u, wrbar, webar, wr_n, rn_n, temp_n, dew_pt_n, wind_n);
        best_u = get_best_u(A_hat, B_hat, C_hat, D_hat, L, yt, Wtilde, Q_bar, R_bar);
        
        wrbar = wr_n(1);
        webar = We(1);
        
        [x1bar, x2bar] = get_next_state( ...
            config, pump, x1bar, x2bar, best_u, wrbar, webar ...
        );
        
        total_x2_deviation = abs(x2bar - config.zveg) + total_x2_deviation;
        
        x_overtime_mpc(:, t + 2) = [x1bar, x2bar];
        best_u_overtime(:, t + 2) = best_u;
        we_overtime(:, t + 2) = webar;
        wr_overtime(:, t + 2) = wrbar;
        
        wrbar = mean(wr_overtime);
        webar = mean(we_overtime);
    end
    
    x2_deviations(1, i) = total_x2_deviation
    
    simulation_time_horizon = 0 : config.sim_length + 1;
    simulation_time_horizon = simulation_time_horizon / 3600 * config.dt;

    figure(6)
    subplot(2,1,1);
    plot(simulation_time_horizon, x_overtime_mpc(1,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex', 'FontSize', 16);
    title('Water volume in $x_1$ over time', 'FontSize', 18, 'interpreter', 'latex')
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$x_1$ [m$^3$]', 'interpreter', 'latex', 'FontSize', 16);

    subplot(2,1,2);
    plot(simulation_time_horizon, x_overtime_mpc(2,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex', 'FontSize', 16);
    title('Water volume in $x_2$ over time', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$x_2$ [m$^3$]', 'FontSize', 16, 'interpreter', 'latex');

    figure(7)
    plot(simulation_time_horizon, abs(x_overtime_mpc(2,:) - config.a2*config.zveg), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2);  hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex');
    title('Deviation from desired $x_2$ [m$^3$]', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');

    figure(8)
    plot(simulation_time_horizon, best_u_overtime, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 2); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex');
    title('Control input u over time', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('u',  'FontSize', 16, 'interpreter', 'latex');

    figure(9)
    plot(simulation_time_horizon, wr_overtime * config.a2, 'linewidth', 2);
    title('Rainfall rate tank 2 over time [m$^3$/s]', 'FontSize', 18, 'interpreter', 'latex')
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');

    figure(10)
    plot(simulation_time_horizon, we_overtime, 'linewidth', 2);
    title('Evaporation rate over time [m/s]', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (hours)', 'FontSize', 16, 'interpreter', 'latex');
end
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    a = get(gca, 'XTickLabel');
    set(gca, 'XTickLabel', a, 'fontsize', 16);
    figure(11)
    sum_deviation_len = 1:size(config.lambdas,2);
    scatter(sum_deviation_len, x2_deviations/4, 'MarkerEdgeColor', 'k',...
              'MarkerFaceColor', 'k',...
              'LineWidth', 2.5); 
    title('MPC Sum of deviation from desired x2 [m$^3$/hour]', 'FontSize', 18, 'interpreter', 'latex');
    xticks([1 2 3 4 5])
    xticklabels({'$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$'})

    
end

