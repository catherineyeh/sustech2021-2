function [dq_dx1, dq_dx2, dq_du] = deriv_qdraine(x2, config)
dq_dx1 = 0;
dq_du = 0;
dq_dx2 = config.K / config.zsoil + deriv_sig_minus_var(x2, config.zcap, config.epsilon);
end

