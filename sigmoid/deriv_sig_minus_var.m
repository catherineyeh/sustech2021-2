function dy = deriv_sig_minus_var(y, c, epsilon)
% Inputs
%       y: variable
%       c: constant
dy = (1 / epsilon) * exp((c - y) / epsilon) * (1 + exp((c - y) / epsilon))^(-2);

end

