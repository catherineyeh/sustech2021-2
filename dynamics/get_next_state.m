function [x1_plus1, x2_plus1] = get_next_state(config, pump, x1bar, x2bar, ubar, wrbar, webar)
% get next state with non-linear model

% Smoothed non-linear model:
% f01 = wrbar * config.a_in - qoute(x1bar, config) - qpumpe(x1bar, x2bar, ubar, pump, config);
% f02 = wrbar * config.a2 + qpumpe(x1bar, x2bar, ubar, pump, config) - webar - qdraine(config, x2bar);

% Exact qout
if x1bar/config.a1 > config.zo
    qout = config.cout * sqrt(x1bar/config.a1 - config.zo);
else
    qout = 0;
end

% Exact qpump
if (x2bar/config.a2 >= config.zveg) || (x1bar/config.a1 < config.zpump + config.zH)
    qpump = 0;    
else
    %pump_struct = fill_pump_params(config);
    max_pump_rate = pump.b * sqrt( x1bar/config.a1 + config.c_hat - config.d );
    qpump = ubar * max_pump_rate;
end

% Exact qdrain
if x2bar < config.zcap
    qdrain = 0;
else
    MyRatio = ( x2bar/config.a2 + config.zsoil ) / config.zsoil;
    qdrain = config.K * config.a2 * MyRatio;
end

f01 = wrbar * config.a_in - qout - qpump;
f02 = wrbar * config.a2 + qpump - webar - qdrain;

x1_plus1 = x1bar + f01 * config.dt;
x2_plus1 = x2bar + f02 * config.dt;

if x1_plus1 < 0 || x2_plus1 < 0
    error('getting negative volumes');
end

end


    



