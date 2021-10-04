function [dqdx1, dqdx2, dqdu] = deriv_qoute(x1, config)
    dqdx1 = config.cout * deriv_smooth_sqrt(x1);
    dqdx2 = 0;
    dqdu = 0;
end

