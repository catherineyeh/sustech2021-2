% Inputs
%       y: variable
%       c: constant
% Output: The derivative of sig_plus_var.m with respect to y

function dy = deriv_sig_plus_var(y, c, epsilon)

 dy = (-1/epsilon) * exp( (y-c)/epsilon ) * ( 1 + exp((y-c)/epsilon) )^(-2);

end
