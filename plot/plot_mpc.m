function [] = plot_mpc(option)
    rng('default');
    config = fill_config();
    pump = fill_pump_params(config);
    
    % initial conditions
    x1bar = config.a1 * 50;
    x2bar = config.a2 * (config.zveg / 1.3);
    wrbar = 0; webar = 0;
    best_u = 0;

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
        get_linear_model(config, pump, config.lambda, ... 
        x1bar, x2bar, best_u, wrbar, webar, wr_n, rn_n, temp_n, dew_pt_n, wind_n);
        
        best_u = get_best_u(A_hat, B_hat, C_hat, D_hat, L, yt, Wtilde, Q_bar, R_bar);
        
        wrbar = wr_n(1);
        webar = We(1);
        if webar < 0
            error("Negative evap");
        end
        [x1bar, x2bar] = get_next_state( ...
            config, pump, x1bar, x2bar, best_u, wrbar, webar ...
        );
        
        x_overtime_mpc(:, t + 2) = [x1bar, x2bar];
        best_u_overtime(:, t + 2) = best_u;
        we_overtime(:, t + 2) = webar;
        wr_overtime(:, t + 2) = wrbar;
        
        wrbar = mean(wr_overtime);
        webar = mean(we_overtime);
    end

    simulation_time_horizon = 0 : config.sim_length + 1;
    simulation_time_horizon = simulation_time_horizon * config.dt;

    figure(1)
    subplot(2,1,1);
    plot(simulation_time_horizon, x_overtime_mpc(1,:), '-b', 'linewidth', 2); hold on;
    legend('MPC');
    title('Water volume in x1 over time')
    xlabel('Time (seconds)');
    ylabel('x1 [m^3]');

    subplot(2,1,2);
    plot(simulation_time_horizon, x_overtime_mpc(2,:), '-b'); hold on;
    legend('MPC');
    title('Water volume in x2 over time');
    xlabel('Time (seconds)');
    ylabel('x2 [m^3]');

    figure(2)
    plot(simulation_time_horizon, abs(x_overtime_mpc(2,:) - config.a2*config.zveg), '-b');  hold on;
    legend('MPC');
    title('Deviation from desired x2 [m^3]');
    xlabel('Time (seconds)');

    figure(3)
    plot(simulation_time_horizon, best_u_overtime, '-b'); hold on;
    legend('MPC');
    title('Control input u over time');
    xlabel('Time (seconds)');
    ylabel('u');

    figure(4)
    plot(simulation_time_horizon, wr_overtime * config.a2);
    title('Rainfall rate tank 2 over time [m^3/s]')
    xlabel('Time (seconds)');

    figure(5)
    plot(simulation_time_horizon, we_overtime);
    title('Evaporation rate over time [m/s]'); xlabel('Time (seconds)');
end

