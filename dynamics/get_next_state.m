function [x1_plus1, x2_plus1] = get_next_state(config, pump, x1bar, x2bar, ubar, wrbar, webar)
% get next state with non-linear model

% Non-linear model:
f01 = wrbar * config.a_in - qoute(x1bar, config) - qpumpe(x1bar, x2bar, ubar, pump, config);
f02 = wrbar * config.a2 + qpumpe(x1bar, x2bar, ubar, pump, config) - webar - qdraine(config, x2bar);
x1_plus1 = x1bar + f01 * config.dt;
x2_plus1 = x2bar + f02 * config.dt;

end

