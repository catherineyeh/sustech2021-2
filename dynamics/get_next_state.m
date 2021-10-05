function [x1_plus1, x2_plus1] = get_next_state(config, x1bar, x2bar, ubar, wrbar, webar)
% get next state with non-linear model

% Non-linear model:
f01 = wrbar * config.ain - qout_e(config, x1bar) - qpump_e(config, x1bar, x2bar, ubar);
f02 = wrbar * config.a2 + qpump_e(config, x1bar, x2bar, ubar) - webar - qdrain(config, x2bar);
x1_plus1 = x1bar + f01 * config.dt;
x2_plus1 = x2bar + f02 * config.dt;

end

