function [A_hat, B_hat, C_hat, D_hat, L, ...
         Wtilde, yt, R_bar, Q_bar] = ... 
get_linear_model(config, lambda, ... 
        x1bar, x2bar, best_u, wrbar, webar)
    
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
s = [0; config.zveg];
bp_bar = (Ap - eye(2)) * s - Bp * best_u / config.a2 + bp / config.a2;

A_hat = A_tilde_matrix(config.lookahead, Ap_bar);
B_hat = Matrix_tilde(config.lookahead, Ap_bar, Bp_bar);
C_hat = Matrix_tilde(config.lookahead, Ap_bar, Cp_bar);
D_hat = Matrix_tilde(config.lookahead, Ap_bar, eye(2));
L = b_bar_matrix(N, bp_bar);

yt = -s;

% CY todo: how to construct Wtilde
Wtilde = zeros(2*config.lookahead, 2);

R_bar = Diag(config.lookahead, lambda);
Q = [0 0; 0 1];
Q_bar = Diag(config.lookahead, Q);

end

