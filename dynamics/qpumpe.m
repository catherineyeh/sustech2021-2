function q = qpumpe(x1, u, pump, config)
    rho = x1 / config.a1 + config.c_hat - config.d;
    npump_e = u * pump.b * smooth_sqrt(rho);
    sig1 = sig_minus_var(x1, config.a1*(config.zpump+config.zH));
    sig2 = sig_minus_var(-x2, -config.a2*config.zveg);
    q = npump_e * sig1 * sig2;
end

