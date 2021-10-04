function [dqdx1, dqdx2, dqdu] = deriv_qpumpe(x1, x2, u, pump, config)

rho = x1 / config.a1 + config.c_hat - config.d;
    
npump_e = u * pump.b * smooth_sqrt(rho);

sig1 = sig_minus_var(x1, config.a1*(config.zpump+config.zH));

deriv_sig1_x1 = deriv_sig_minus_var(x1, config.a1*(config.zpump+config.zH));
    
sig2 = sig_plus_var(x2, config.a2*config.zveg);

dqdx1 = u * pump.b * deriv_smooth_sqrt(rho) * 1/config.a1 * sig1 * sig2 + ...
        npump_e * deriv_sig1_x1 * sig2;
    
% MPC start here: need to check these two derivatives.
    dqdx2 = u * pump.b * smooth_sqrt(rho) * ...
        sig_minus_var(x1, config.a1*(config.zpump+config.zH)) * ...
        deriv_sig_minus_var(-x2, -config.a2*config.zveg, config.epsilon);
    
    dqdu = pump.b * sig_minus_var(x1, config.a1*(config.zpump+config.zH)) * ...
        sig_minus_var(-x2, -config.a2*config.zveg);
    
end

