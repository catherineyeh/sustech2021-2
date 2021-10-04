% Inputs
%       y: variable
%       c: constant
% Output: The derivative of sig_minus_var.m with respect to y

function dy = deriv_sig_minus_var(y, c)

% dy = (-1 / epsilon) * exp((c - y) / epsilon) * (1 + exp((c - y) / epsilon))^(-2);

%Please check below. I believe that it should be +1/epsilon not -1/epsilon.

epsilon = 0.01;

dy = (1 / epsilon) * exp((c - y) / epsilon) * (1 + exp((c - y) / epsilon))^(-2);

end

