function out = sig_minus_var(y, c)
% Inputs
%       y: variable
%       c: constant
%       epsilon: parameter in sigmoid function
    epsilon = 0.01;
    out = 1 / (1 + exp((c - y) / epsilon));

end

