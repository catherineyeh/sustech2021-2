function [dqdx1, dqdx2, dqdu] = deriv_qoute(x1, config)

gamma = (x1 / config.a1) - config.zo;

dqdx1 = config.cout * deriv_smooth_sqrt(gamma) * 1/config.a1;

dqdx2 = 0;

dqdu = 0;

end

% Remember the chain rule. Before it was written:
% dqdx1 = config.cout * deriv_smooth_sqrt(x1);
% but qout_answer = config.cout * smooth_sqrt(gamma);
% so we need to take the derivative of gamma as well.
  

