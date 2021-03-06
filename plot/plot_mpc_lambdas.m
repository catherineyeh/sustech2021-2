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
    % this is low x1bar
    % x1bar = config.a1 * (config.zo / 1.3);
    
    %this is high x1bar
    x1bar = config.a1 * (config.zo * 1.3);
    
    %this is low x2bar
    x2bar = config.a2 * (config.zveg / 1.3);
    
    % this is high x2bar (desired x2bar = 3.144)
    % x2bar = config.a2 * (config.zveg * 1.3);
    % x2bar = 3.5; % not very interesting, it's too wet., perhaps
    % interesting in dry weather...
    % x2bar = 3.2; 
    
    wrbar = 0; webar = 0;
    best_u = 0;
    total_x2_deviation = 0;
    
    % load data, do we need to load this for each lambda or just for the
    % first lambda?
    [wr, rn, temp, dew_pt, wind] = get_data(option, config);
    
    % initialize arrays
    x_overtime_mpc = zeros(2, config.sim_length + 1);
    best_u_overtime = zeros(1, config.sim_length + 1);
    best_qpump_overtime = zeros(1, config.sim_length + 1);
    we_overtime = zeros(1, config.sim_length + 1);
    wr_overtime = zeros(1, config.sim_length + 1);
    
    x_overtime_mpc(:, 1) = [x1bar; x2bar];
    best_u_overtime(:, 1) = best_u;
    best_qpump_overtime(:, 1) = 0;
    we_overtime(:, 1) = webar;
    wr_overtime(:, 1) = wrbar;
    
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
        
        [x1bar, x2bar, qpump] = get_next_state( ...
            config, pump, x1bar, x2bar, best_u, wrbar, webar ...
        );
        
        % x2bar (m^3), config.a2*config.zveg = (m^2)*(m)
        total_x2_deviation = abs(x2bar - config.a2*config.zveg) + total_x2_deviation;
        % has units of m^3
        
        %x_overtime_mpc(:, t + 2) = [x1bar, x2bar];
        %Should we be storing the next state as a column vector?
        x_overtime_mpc(:, t + 2) = [x1bar; x2bar];
        
        best_u_overtime(:, t + 2) = best_u;
        best_qpump_overtime(:, t + 2) = qpump;
        we_overtime(:, t + 2) = webar;
        wr_overtime(:, t + 2) = wrbar;
        
        wrbar = mean(wr_overtime);
        webar = mean(we_overtime);
    
    end
    
    x2_deviations(1, i) = total_x2_deviation; % for ith value of lambda
    myXLIM = [0 12];
    %config.lambdas = [0.00001, 0.0001, 0.001, 0.01, 0.1];
    
    figure(6)
    subplot(1,2,1);
    plot(simulation_time_horizon, x_overtime_mpc(1,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        %legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title('MPC: Water volume in cistern', 'FontSize', 16, 'interpreter', 'latex')
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$x_1$ (m$^3$)', 'interpreter', 'latex', 'FontSize', 16);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end

    subplot(1,2,2);
    plot(simulation_time_horizon, x_overtime_mpc(2,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        title('MPC: Water volume in green roof', 'FontSize', 16, 'interpreter', 'latex');
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$x_2$ (m$^3$)', 'FontSize', 16, 'interpreter', 'latex');
        desired_x2 = config.a2 * config.zveg * ones(size(simulation_time_horizon));
        plot(simulation_time_horizon, desired_x2, 'linestyle', ':', 'color', 'k', 'linewidth', 2);
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'Desired volume', 'interpreter', 'latex', 'FontSize', 14);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(7)
    plot(simulation_time_horizon, abs(x_overtime_mpc(2,:) - config.a2*config.zveg), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2);  hold on;
    if i == N_LAMBDAS
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title('MPC: Deviation from desired $x_2$ (m$^3$)', 'FontSize', 16, 'interpreter', 'latex');
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(8)
    plot(simulation_time_horizon, best_u_overtime, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title('MPC: Control input', 'FontSize', 16, 'interpreter', 'latex');
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$u$ (no units)',  'FontSize', 16, 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(9)
    plot(simulation_time_horizon, best_qpump_overtime, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title('MPC: Pump flow rate', 'FontSize', 16, 'interpreter', 'latex');
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$q_{pump}(x,u)$ (m$^3$/s)',  'FontSize', 16, 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    if i == N_LAMBDAS
        figure(10)
        set(gcf,'color','w');
        subplot(1,2,1)
        plot(simulation_time_horizon, wr_overtime, 'linewidth', 2);
        title('Precipitation rate', 'FontSize', 16, 'interpreter', 'latex')
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$w_r$ (m/s)',  'FontSize', 16, 'interpreter', 'latex');
        xlim(myXLIM);
        set(gca,'FontSize',14);
        
        subplot(1,2,2)
        plot(simulation_time_horizon, we_overtime, 'linewidth', 2);
        title('Evapotranspiration rate', 'FontSize', 16, 'interpreter', 'latex');
        xlabel('Time (h)', 'FontSize', 16, 'interpreter', 'latex');
        ylabel('$w_e$ (m$^3$/s)',  'FontSize', 16, 'interpreter', 'latex');
        xlim(myXLIM);
        set(gca,'FontSize',14);
       
    end
end
    %set(groot,'defaultAxesTickLabelInterpreter','latex');
    %a = get(gca, 'XTickLabel');
    %set(gca, 'XTickLabel', a, 'fontsize', 16);
    figure(11)
    set(gcf,'color','w'); 
    
    sum_deviation_len = 1:size(config.lambdas,2);
    
    %why are we dividing by 4 here?
    %scatter(sum_deviation_len, x2_deviations/4, 'MarkerEdgeColor', 'k',...
    %          'MarkerFaceColor', 'k',...
    %          'LineWidth', 2.5); 
    
    scatter(sum_deviation_len, x2_deviations, 'MarkerEdgeColor', 'k',...
              'MarkerFaceColor', 'k',...
              'LineWidth', 2.5);
    title('MPC: Total deviation from desired $x_2$ (m$^3$)', 'FontSize', 16, 'interpreter', 'latex');
    xticks([1 2 3 4 5])
    xticklabels({config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5})
    set(gca,'FontSize',14);
    

    
end

