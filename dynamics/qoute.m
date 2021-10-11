function qout_answer = qoute(x1, config)
    gamma = (x1 / config.a1) - config.zo;
    qout_answer = config.cout * smooth_sqrt(gamma)
end

