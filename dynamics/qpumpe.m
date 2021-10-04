function q = qpumpe(x1, x2, u, pump, config)

    rho = x1 / config.a1 + config.c_hat - config.d;
    
    npump_e = u * pump.b * smooth_sqrt(rho);
    
    sig1 = sig_minus_var(x1, config.a1*(config.zpump+config.zH));
    
    sig2 = sig_plus_var(x2, config.a2*config.zveg);
    
    %sig2 = sig_minus_var(-x2, -config.a2*config.zveg);
    %I wrote new functions sig_plus_var.m and deriv_sig_plus_var.m to avoid negative sign errors.
    
    q = npump_e * sig1 * sig2;
    
end

%Very nice function -- it looks just like the math in our paper :)
