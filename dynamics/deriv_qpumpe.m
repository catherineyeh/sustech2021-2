function [dqdx1, dqdx2, dqdu] = deriv_qpumpe(x1, x2, u, pump, config)

rho = x1/config.a1 + config.c_hat - config.d;
    
npump_e = u * pump.b * smooth_sqrt(rho);

c1 = config.a1*(config.zpump + config.zH);

sig1 = sig_minus_var(x1, c1);

deriv_sig1_x1 = deriv_sig_minus_var(x1, c1);

c2 = config.a2*config.zveg;
    
sig2 = sig_plus_var(x2, c2);

deriv_sig2_x2 = deriv_sig_plus_var(x2, c2);

dqdx1 = u * pump.b * deriv_smooth_sqrt(rho) * 1/config.a1 * sig1 * sig2 + ...
        npump_e * deriv_sig1_x1 * sig2;
    
dqdx2 = npump_e * sig1 * deriv_sig2_x2;
    
dqdu = pump.b * smooth_sqrt(rho) * sig1 * sig2;

end

