function [] = plot_mpc_lambdas(option)
% plots mpc overlaid
% 
rng('default');
config = fill_config();
pump = fill_pump_params(config);

x2_deviations = zeros(1, size(config.lambdas,2));

%number of time steps, duration of [t, t+1) is config.dt in seconds
%config.dt = 1 sec
simulation_time_horizon = 0 : config.sim_length + 1; 

%converting units of sim_time_horizon to hours
%may not need multiplication by config.dt here, but config.dt = 1 in our example
simulation_time_horizon = simulation_time_horizon / 3600 * config.dt;

N_LAMBDAS = size(config.lambdas, 2);

for i = 1 : N_LAMBDAS
    
    disp(['Evaluating lambda value ', num2str(i)]);
    % initial conditions
    % x1bar = config.a1 * 50;
    % the value of x1bar seems enormous since the max height of tank 1 is
    % no more than 2m
    %
    x1bar = config.a1 * (config.zo / 1.3);
    x2bar = config.a2 * (config.zveg / 1.3);
    wrbar = 0; webar = 0;
    best_u = 0;
    total_x2_deviation = 0;
    
    % load data, do we need to load this for each lambda or just for the
    % first lambda?
    [wr, rn, temp, dew_pt, wind] = get_data(option, config);
    
    % initialize arrays
    x_overtime_mpc = zeros(2, config.sim_length + 1);
    best_u_overtime = zeros(1, config.sim_length + 1);
    we_overtime = zeros(1, config.sim_length + 1);
    wr_overtime = zeros(1, config.sim_length + 1);
    
    % MPC loop  
    for t = 0 : config.sim_length
        
        if ~isfinite(x1bar) || ~isfinite(x2bar) || ~isfinite(best_u)
            x1bar
            x2bar
            best_u
            error(['t =', num2str(t)]);
        end
        
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
        
        % x2bar (m^3), config.a2*config.zveg = (m^2)*(m)
        total_x2_deviation = abs(x2bar - config.a2*config.zveg) + total_x2_deviation;
        % has units of m^3
        
        %x_overtime_mpc(:, t + 2) = [x1bar, x2bar];
        %Should we be storing the next state as a column vector?
        x_overtime_mpc(:, t + 2) = [x1bar; x2bar];
        
        best_u_overtime(:, t + 2) = best_u;
        we_overtime(:, t + 2) = webar;
        wr_overtime(:, t + 2) = wrbar;
        
        wrbar = mean(wr_overtime);
        webar = mean(we_overtime);
    
    end
    
    x2_deviations(1, i) = total_x2_deviation; % for ith value of lambda

    figure(6)
    subplot(2,1,1);
    plot(simulation_time_horizon, x_overtime_mpc(1,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 4); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex', 'FontSize', 16);
    title('Water volume in cistern over time', 'FontSize', 18, 'interpreter', 'latex')
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$x_1$ (m$^3$)', 'interpreter', 'latex', 'FontSize', 16);

    subplot(2,1,2);
    plot(simulation_time_horizon, x_overtime_mpc(2,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 4); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex', 'FontSize', 16);
    title('Water volume in green roof over time', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$x_2$ (m$^3$)', 'FontSize', 16, 'interpreter', 'latex');

    figure(7)
    plot(simulation_time_horizon, abs(x_overtime_mpc(2,:) - config.a2*config.zveg), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 4);  hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex');
    title('Deviation from desired $x_2$ (m$^3$)', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');

    figure(8)
    plot(simulation_time_horizon, best_u_overtime, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 4); hold on;
    legend('$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$', 'interpreter', 'latex');
    title('Proportion of max aggregate flow rate by pumps in series over time', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$u$ (no units)',  'FontSize', 16, 'interpreter', 'latex');

    figure(9)
    plot(simulation_time_horizon, wr_overtime, 'linewidth', 4);
    title('Precipitation rate over time', 'FontSize', 18, 'interpreter', 'latex')
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$w_r$ (m/s)',  'FontSize', 16, 'interpreter', 'latex');

    figure(10)
    plot(simulation_time_horizon, we_overtime, 'linewidth', 4);
    title('Evapotranspiration rate over time', 'FontSize', 18, 'interpreter', 'latex');
    xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
    ylabel('$w_e$ (m$^3$/s)',  'FontSize', 16, 'interpreter', 'latex');
end
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    a = get(gca, 'XTickLabel');
    set(gca, 'XTickLabel', a, 'fontsize', 16);
    figure(11)
    
    sum_deviation_len = 1:size(config.lambdas,2);
    
    %why are we dividing by 4 here?
    %scatter(sum_deviation_len, x2_deviations/4, 'MarkerEdgeColor', 'k',...
    %          'MarkerFaceColor', 'k',...
    %          'LineWidth', 2.5); 
    
    scatter(sum_deviation_len, x2_deviations, 'MarkerEdgeColor', 'k',...
              'MarkerFaceColor', 'k',...
              'LineWidth', 2.5);
    title('Cumulative deviation from desired $x_2$ using MPC (m$^3$)', 'FontSize', 18, 'interpreter', 'latex');
    xticks([1 2 3 4 5])
    xticklabels({'$\lambda=0.001$', '$\lambda=0.01$', '$\lambda=0.1$', '$\lambda=1$', '$\lambda=10$'})

    
end

