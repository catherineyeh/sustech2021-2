% Inputs
%       y: variable
%       c: constant

function dy = deriv_sig_minus_var(y, c, epsilon)

% dy = (-1 / epsilon) * exp((c - y) / epsilon) * (1 + exp((c - y) / epsilon))^(-2);

%Please check below. I believe that it should be +1/epsilon not -1/epsilon.

dy = (1 / epsilon) * exp((c - y) / epsilon) * (1 + exp((c - y) / epsilon))^(-2);

end

