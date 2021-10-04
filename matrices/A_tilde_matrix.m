function A_tilde = A_tilde_matrix(N, Ap_bar)
% Discription: Computes A_tilde
% Input:
%   Ap_bar: 2x2 matrix

dimi = size(Ap_bar,1);
dimj = size(Ap_bar,2);
A_tilde = zeros(N*dimi, dimj);
for i=1:2:N*dimi
    A_tilde(i:i+dimi-1,:) = Ap_bar^i;  % The syntax A^2 is equivalent to A*A
end

end

