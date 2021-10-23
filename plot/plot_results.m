function [] = plot_results(option, init_type)

rng('default');
config = fill_config();
pump = fill_pump_params(config);

x2_deviations_mpc = zeros(1, size(config.lambdas,2)); x2_deviations_onoff = x2_deviations_mpc;

%number of time steps, duration of [t, t+1) is config.dt in seconds, config.dt = 1 sec
simulation_time_horizon = 0 : config.sim_length + 1; 

%converting units of sim_time_horizon to hours
%may not need multiplication by config.dt here, but config.dt = 1 in our example
simulation_time_horizon = simulation_time_horizon / 3600 * config.dt;

% load data
[wr, rn, temp, dew_pt, wind] = get_data(option, config);

N_LAMBDAS = length(config.lambdas); N_MAXUS = length(config.onoffu);
if N_LAMBDAS ~= N_MAXUS, error('number of lambdas and max us should be the same.'); end

x1_LOW = config.a1 * (config.zo / 1.3);    % low x1bar
x1_HIGH = config.a1 * (config.zo * 1.3);   % high x1bar
x2_LOW = config.a2 * (config.zveg / 1.3);  % low x2bar
x2_HIGH = config.a2 * (config.zveg * 1.3); % high x2bar

for i = 1 : N_LAMBDAS % same as number of us
    disp(['Evaluating lambda and maxu value ', num2str(i), init_type]);
    
    % initial conditions
    if strcmp(init_type, 'low-low')
        x1bar_mpc = x1_LOW; 
        x2bar_mpc = x2_LOW;
    elseif strcmp(init_type, 'high-low')
        x1bar_mpc = x1_HIGH;
        x2bar_mpc = x2_LOW;
    elseif strcmp(init_type, 'high-high')
        x1bar_mpc = x1_HIGH;
        x2bar_mpc = x2_HIGH;
    else
        error('initial condition type not supported');
    end
    
    x1bar_onoff = x1bar_mpc;
    x2bar_onoff = x2bar_mpc;
    
    wrbar = 0; 
    webar = 0;
    best_u_mpc = 0; 
    best_u_onoff = 0;
    total_x2_deviation_mpc = 0; 
    total_x2_deviation_onoff = 0;
    
    % initialize arrays
    x_overtime_mpc = zeros(2, config.sim_length + 1); 
    x_overtime_onoff = zeros(2, config.sim_length + 1);
    best_u_overtime_mpc = zeros(1, config.sim_length + 1); 
    best_u_overtime_onoff = zeros(1, config.sim_length + 1);
    we_overtime = zeros(1, config.sim_length + 1); 
    wr_overtime = zeros(1, config.sim_length + 1);
    
    x_overtime_mpc(:, 1) = [x1bar_mpc; x2bar_mpc]; 
    x_overtime_onoff(:, 1) = [x1bar_onoff; x2bar_onoff];
    best_u_overtime_mpc(:, 1) = best_u_mpc; 
    best_u_overtime_onoff(:, 1) = best_u_onoff;
    we_overtime(:, 1) = webar;
    wr_overtime(:, 1) = wrbar;
    
    % Control loops 
    for t = 0 : config.sim_length
        
        if ~isfinite(x1bar_mpc) || ~isfinite(x2bar_mpc) || ~isfinite(best_u_mpc)
            x1bar_mpc
            x2bar_mpc
            best_u_mpc
            error(['t =', num2str(t)]);
        end
       
        wr_n = get_lookahead(config.lookahead, t+1, wr);
        rn_n = get_lookahead(config.lookahead, t+1, rn);
        dew_pt_n = get_lookahead(config.lookahead, t+1, dew_pt);
        wind_n = get_lookahead(config.lookahead, t+1, wind);
        temp_n = get_lookahead(config.lookahead, t+1, temp);
        
        [A_hat, B_hat, C_hat, D_hat, L, Wtilde, yt, R_bar, Q_bar, We] = ... 
        get_linear_model(config, pump, config.lambdas(i), ... 
        x1bar_mpc, x2bar_mpc, best_u_mpc, wrbar, webar, wr_n, rn_n, temp_n, dew_pt_n, wind_n);
        
        best_u_mpc = get_best_u(A_hat, B_hat, C_hat, D_hat, L, yt, Wtilde, Q_bar, R_bar);
        best_u_onoff = get_onoff_u(config, x1bar_onoff, x2bar_onoff, i);
        
        wrbar = wr_n(1);
        webar = We(1);
        
        [x1bar_mpc, x2bar_mpc] = get_next_state(config, pump, x1bar_mpc, x2bar_mpc, best_u_mpc, wrbar, webar);
        [x1bar_onoff, x2bar_onoff] = get_next_state(config, pump, x1bar_onoff, x2bar_onoff, best_u_onoff, wrbar, webar);
        
        % x2bar (m^3), config.a2*config.zveg = (m^2)*(m)
        total_x2_deviation_mpc = abs(x2bar_mpc - config.a2*config.zveg) + total_x2_deviation_mpc; % has units of m^3
        total_x2_deviation_onoff = abs(x2bar_onoff - config.a2*config.zveg) + total_x2_deviation_onoff;
        
        x_overtime_mpc(:, t + 2) = [x1bar_mpc; x2bar_mpc];
        x_overtime_onoff(:, t + 2) = [x1bar_onoff; x2bar_onoff];
        
        best_u_overtime_mpc(:, t + 2) = best_u_mpc;
        best_u_overtime_onoff(:, t + 2) = best_u_onoff;
        we_overtime(:, t + 2) = webar;
        wr_overtime(:, t + 2) = wrbar;
        
        wrbar = mean(wr_overtime);
        webar = mean(we_overtime);
    
    end
    
    x2_deviations_mpc(1, i) = total_x2_deviation_mpc; % for ith value of lambda
    x2_deviations_onoff(1, i) = total_x2_deviation_onoff; % for ith value of u
    myXLIM = [0 12];
    
    figure(6)
    subplot(1,2,1);
    plot(simulation_time_horizon, x_overtime_mpc(1,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        title(['MPC, ',init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        ylabel('$x_1$ (m$^3$)', 'interpreter', 'latex');
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    subplot(1,2,2);
    plot(simulation_time_horizon, x_overtime_onoff(1,:),'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        title(['On/Off, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        legend(config.u1, config.u2, config.u3, config.u4, config.u5,'interpreter', 'latex', 'FontSize', 14);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(7)
    subplot(1,2,1);
    plot(simulation_time_horizon, x_overtime_mpc(2,:), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        title(['MPC, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        ylabel('$x_2$ (m$^3$)', 'interpreter', 'latex');
        desired_x2 = config.a2 * config.zveg * ones(size(simulation_time_horizon));
        plot(simulation_time_horizon, desired_x2, 'linestyle', ':', 'color', 'k', 'linewidth', 2);
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, '$x_2^*$', 'interpreter', 'latex', 'FontSize', 14);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    subplot(1,2,2);
    plot(simulation_time_horizon, x_overtime_onoff(2,:),'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        title(['On/Off, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        plot(simulation_time_horizon, desired_x2, 'linestyle', ':', 'color', 'k', 'linewidth', 2);
        legend(config.u1, config.u2, config.u3, config.u4, config.u5,'$x_2^*$','interpreter', 'latex', 'FontSize', 14);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(8)
    subplot(1,2,1);
    plot(simulation_time_horizon, abs(x_overtime_mpc(2,:) - config.a2*config.zveg), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2);  hold on;
    if i == N_LAMBDAS
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title(['MPC, ', init_type], 'interpreter', 'latex');
        ylabel('$|x_2 - x_2^*|$ (m$^3$)', 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    subplot(1,2,2);
    plot(simulation_time_horizon, abs(x_overtime_onoff(2,:) - config.a2*config.zveg), 'linestyle', config.styles(i), 'color', config.colors(i), 'linewidth', 2);  hold on;
    if i == N_LAMBDAS
        legend(config.u1, config.u2, config.u3, config.u4, config.u5, 'interpreter', 'latex', 'FontSize', 14);
        title(['On/Off, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    figure(9)
    subplot(1,2,1);
    plot(simulation_time_horizon, best_u_overtime_mpc, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        legend(config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5, 'interpreter', 'latex', 'FontSize', 14);
        title(['MPC, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        ylabel('$u$ (no units)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    subplot(1,2,2);
    plot(simulation_time_horizon, best_u_overtime_onoff, 'color', config.colors(i), 'linestyle', config.styles(i), 'linewidth', 2); hold on;
    if i == N_LAMBDAS
        legend(config.u1, config.u2, config.u3, config.u4, config.u5, 'interpreter', 'latex', 'FontSize', 14);
        title(['On/Off, ', init_type], 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gcf,'color','w'); set(gca,'FontSize',14);
    end
    
    if i == N_LAMBDAS
        figure(10)
        set(gcf,'color','w');
        subplot(1,2,1)
        plot(simulation_time_horizon, wr_overtime, '-k', 'linewidth', 2);
        title('Precipitation', 'interpreter', 'latex')
        xlabel('Time (h)', 'interpreter', 'latex');
        ylabel('$w_r$ (m/s)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gca,'FontSize',14);
        subplot(1,2,2)
        plot(simulation_time_horizon, we_overtime, '-k', 'linewidth', 2);
        title('Evapotranspiration', 'interpreter', 'latex');
        xlabel('Time (h)', 'interpreter', 'latex');
        ylabel('$w_e$ (m$^3$/s)', 'interpreter', 'latex');
        xlim(myXLIM);
        set(gca,'FontSize',14);
    end
end

    EXTRA = 500;
    yMIN = min([x2_deviations_mpc,x2_deviations_onoff]) - EXTRA;
    yMAX = max([x2_deviations_mpc,x2_deviations_onoff]) + EXTRA;
    figure(11)
    set(gcf,'color','w'); 
    sum_deviation_len = 1:size(config.lambdas,2);
    
    %why are we dividing by 4 here?
    %scatter(sum_deviation_len, x2_deviations/4, 'MarkerEdgeColor', 'k',...
    %          'MarkerFaceColor', 'k',...
    %          'LineWidth', 2.5); 
    
    subplot(1,2,1);
    scatter(sum_deviation_len, x2_deviations_mpc, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineWidth', 2.5);
    title(['MPC, ', init_type], 'interpreter', 'latex');
    ylabel('Total $|x_2 - x_2^*|$ over time (m$^3$)', 'interpreter', 'latex');
    xticks([1 2 3 4 5]);
    xticklabels({config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5});
    ylim([yMIN yMAX]); grid on;
    set(gca,'FontSize',14);
    
    subplot(1,2,2);
    scatter(sum_deviation_len, x2_deviations_onoff, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineWidth', 2.5);
    title(['On/Off, ', init_type],'interpreter', 'latex');
    xticks([1 2 3 4 5]);
    xticklabels({config.u1, config.u2, config.u3, config.u4, config.u5});
    ylim([yMIN yMAX]); grid on;
    set(gca,'FontSize',14);
    
end

% this is high x2bar (desired x2bar = 3.144)
    % x2bar = config.a2 * (config.zveg * 1.3);
    % x2bar = 3.5; % not very interesting, it's too wet., perhaps
    % interesting in dry weather...
    % x2bar = 3.2; 

