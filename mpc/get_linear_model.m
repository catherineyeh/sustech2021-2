function [A_hat, B_hat, C_hat, D_hat, L, ...
         Wtilde, yt, R_bar, Q_bar, We] = ... 
get_linear_model(config, pump, lambda, ... 
        x1bar, x2bar, ubar, wrbar, webar, wr_n, rn_n, temp_n, dew_pt_n, wind_n)
    
% Non-linear model (same as f^epsilon on paper) evaluated at x1bar, x2bar, wrbar, webar:
f01 = wrbar*config.a_in - qoute(x1bar, config) - qpumpe(x1bar, x2bar, ubar, pump, config);
f02 = wrbar*config.a2 + qpumpe(x1bar, x2bar, ubar, pump, config) - webar - qdraine(config, x2bar);

% Linearize Non-linear model
[dqout_dx1, dqout_dx2, dqout_du] = deriv_qoute(x1bar, config);
[dqpump_dx1, dqpump_dx2, dqpump_du] = deriv_qpumpe(x1bar, x2bar, ubar, pump, config);
[dqdrain_dx1, dqdrain_dx2, dqdrain_du] = deriv_qdraine(x2bar, config);
df01_dx1 = - dqout_dx1 - dqpump_dx1;
df01_dx2 = - dqout_dx2 - dqpump_dx2;
df01_du = - dqout_du - dqpump_du;
df01_dwr = config.a_in;
df01_dwe = 0;
df02_dx1 = dqpump_dx1 - dqdrain_dx1;
df02_dx2 = dqpump_dx2 - dqdrain_dx2;  % get Nan for dqdrain_dx2
df02_du = dqpump_du - dqdrain_du;
df02_dwr = config.a2;
df02_dwe = -1;

Ap = config.dt * [df01_dx1 df01_dx2; df02_dx1 df02_dx2] + eye(2);
Bp = config.dt * [df01_du; df02_du];
%Cp = config.dt * [df01_dwr df01_dwe; df02_dwr df02_dwe];
%I think that the code uses w = [we; wr] later in this function
Cp = config.dt * [df01_dwe df01_dwr; df02_dwe df02_dwr];
bp = config.dt * [f01; f02];

Ap_bar = Ap;
Bp_bar = Bp / config.a2;
Cp_bar = Cp / config.a2;
ztilde_veg = config.zveg - x2bar/config.a2;
s = [0; ztilde_veg];
bp_bar = (Ap - eye(2)) * s - Bp * ubar / config.a2 + bp / config.a2;

A_hat = A_tilde_matrix(config.lookahead, Ap_bar);
B_hat = Matrix_tilde(config.lookahead, Ap_bar, Bp_bar); % I believe that this is correct.
C_hat = Matrix_tilde(config.lookahead, Ap_bar, Cp_bar);
D_hat = Matrix_tilde(config.lookahead, Ap_bar, eye(2));
L = b_bar_matrix(config.lookahead, bp_bar);

yt = -s;

We = compute_We(config, rn_n, temp_n, dew_pt_n, wind_n);
Wr = wr_n;
W = [We(:) Wr(:)]';
W = W(:);
if size(W) ~= size(b_bar_matrix(config.lookahead, [webar; wrbar]))
    error("size mismatch between W and b_bar_matrix(config.lookahead, [webar; wrbar])");
end

Wtilde = W - b_bar_matrix(config.lookahead, [webar; wrbar]);

R_bar = Diag(config.lookahead, lambda);
if ~isequal(R_bar, eye(config.lookahead)*lambda)
    error("wrong R_bar");
end

Q = [0 0; 0 1];
Q_bar = Diag(config.lookahead, Q);


end

