function q_drain = qdraine(config, x2)
    sig3 = sig_minus_var(x2, config.zcap);
    q_drain = config.a2 * config.K * ((x2/config.a2 + config.zsoil)/config.zsoil) * sig3;
end

