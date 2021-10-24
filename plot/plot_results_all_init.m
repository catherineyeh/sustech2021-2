% obtains one scatter plot of performance for all initial conditions

function plot_results_all_init(x2_deviations_mpc, x2_deviations_onoff, N_INIT, init_type)

config = fill_config();

% Getting y-axis bounds for scatter plot
myMIN = min([x2_deviations_mpc{1},x2_deviations_onoff{1}]);
myMAX = max([x2_deviations_mpc{1},x2_deviations_onoff{1}]);
for i = 2 : N_INIT
    myMIN = min( [myMIN, x2_deviations_mpc{i},x2_deviations_onoff{i}] );
    myMAX = max( [myMAX, x2_deviations_mpc{i},x2_deviations_onoff{i}] );
end

EXTRA = 500;
yMIN = myMIN - EXTRA;
yMAX = myMAX + EXTRA;

markertype = {'o', 'd', 's'};
markercolor ={'k', 'b', 'm'};

figure
set(gcf,'color','w'); 
sum_deviation_len = 1:size(config.lambdas,2);

for i = 1 : N_INIT
    
    subplot(1,2,1);
    scatter(sum_deviation_len, x2_deviations_mpc{i}, 'filled', markercolor{i}, markertype{i}, 'LineWidth', 2.5);
    hold on;
    if i == N_INIT
        %legend(init_type{1}, init_type{2}, init_type{3}, 'interpreter', 'latex');
        title('MPC', 'interpreter', 'latex');
        ylabel('Total $|x_2 - x_2^*|$ over time (m$^3$)', 'interpreter', 'latex');
        xticks([1 2 3 4 5]);
        xticklabels({config.lambda1, config.lambda2, config.lambda3, config.lambda4, config.lambda5});
        ylim([yMIN yMAX]); grid on;
        set(gca,'FontSize',14);
    end
    
    subplot(1,2,2);
    scatter(sum_deviation_len, x2_deviations_onoff{i}, 'filled', markercolor{i}, markertype{i}, 'LineWidth', 2.5);
    hold on;
    if i == N_INIT
        legend(init_type{1}, init_type{2}, init_type{3}, 'interpreter', 'latex');
        title('On/Off', 'interpreter', 'latex');
        xticks([1 2 3 4 5]);
        xticklabels({config.u1, config.u2, config.u3, config.u4, config.u5});
        ylim([yMIN yMAX]); grid on;
        set(gca,'FontSize',14);
    end

end

%'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineWidth', 2.5);