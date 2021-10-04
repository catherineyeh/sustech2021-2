function [Atilde, Btilde, C1tilde, C2tilde, Dtilde, ...
         dtilde, Wr1tilde, Wr2tilde, Wetilde, yt, We, Rtilde, Qtilde] = ... 
get_linear_model(config, lambda, ... 
        x1bar, x2bar, best_u, wrbar, webar, ...
        wr1_n, wr2_n, rn_n, temp_n, dew_pt_n, wind_n)
% Non-linear model:
f01 = wrbar * config.ain - qout_e(config, x1bar) - qpump_e(config, x1bar, x2bar, ubar);
f02 = wrbar * config.a2 + qpump_e(config, x1bar, x2bar, ubar) - webar - qdrain(config, x2bar);

% Linearize Non-linear model
[dqout_dx1, dqout_dx2, dqout_du] = deriv_qoute(x1bar, config);
[dqpump_dx1, dqpump_dx2, dqpump_du] = deriv_qpumpe(x1bar, x2bar, ubar, pump, config);
[dqdrain_dx1, dqdrain_dx2, dqdrain_du] = deriv_qdraine(x2bar, config);
df01_dx1 = - dqout_dx1 - dqpump_dx1;
df01_dx2 = - dqout_dx2 - dqpump_dx2;
df01_du = - dqout_du - dqpump_du;
df01_dwr = 1;
df01_dwe = 0;
df02_dx1 = dqpump_dx1 - dqdrain_dx1;
df02_dx2 = dqpump_dx2 - dqdrain_dx2;
df02_du = dqpump_du - dqdrain_du;
df02_dwr = 1;
df02_dwe = -1;

Ap = config.dt * [df01_dx1 df01_dx2; df02_dx1 df02_dx2] + eye(2);
Bp = config.dt * [df01_du; df02_du];
Cp = config.dt * [df01_dwr df01_dwe; df02_dwr df02_dwe];
bp = config.dt * [f01; f02];

Ap_bar = Ap;
Bp_bar = Bp / config.a2;
Cp_bar = Cp / config.a2;
bp_bar = (Ap - eye(2)) * s - Bp * best_u / config.a2 + bp / config.a2;

end

