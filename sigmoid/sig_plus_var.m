%We call this "sig_plus_var" since +y is included in the sigmoid function
% Inputs
%       y: variable
%       c: constant
%       epsilon: parameter in sigmoid function

function out = sig_plus_var(y, c)

    epsilon = 0.5; %0.01;
    
    out = 1 / ( 1 + exp((y-c)/epsilon) );

end