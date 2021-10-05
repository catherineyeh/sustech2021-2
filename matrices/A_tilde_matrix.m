function A_tilde = A_tilde_matrix(N, Ap_bar)
% Discription: Computes A_tilde
% Input:
%   Ap_bar: 2x2 matrix

dimi = size(Ap_bar,1);
dimj = size(Ap_bar,2);
A_tilde = zeros(N*dimi, dimj);
power = 1;
for i=1:dimi:N*dimi
    A_tilde(i:i+dimi-1,:) = Ap_bar^(power);  % The syntax A^2 is equivalent to A*A
    power = power + 1;
end

end

