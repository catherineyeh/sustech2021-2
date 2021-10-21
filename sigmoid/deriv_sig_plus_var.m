% Inputs
%       y: variable
%       c: constant
% Output: The derivative of sig_plus_var.m with respect to y as a function
% of y

function dy = deriv_sig_plus_var(y, c)

 epsilon = 0.5;%0.01;

 dy = (-1/epsilon) * exp( (y-c)/epsilon ) * ( 1 + exp((y-c)/epsilon) )^(-2);

end
