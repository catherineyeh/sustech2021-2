function B_tilde = Matrix_tilde(N, Ap_bar, Bp_bar)
% Input
%   N: time steps
%   Ap_bar: 2x2
%   Bp_bar: Bp_bar (2x1), Cp_bar (2x1) or I (2x2)

dimi = size(Ap_bar,1);
dimj = size(Bp_bar, 2);
B_tilde = zeros(N*dimi,N*dimj);

n = 0;
for i=1:dimi:N*dimi
    n = n+1;
    for j=1:dimj:N*dimj
        if n-j < 0
            B_tilde(i:i+dimi-1,j:j+dimj-1) = zeros(dimi,dimj);
        else
            B_tilde(i:i+dimi-1,j:j+dimj-1) = Ap_bar^(n-j) * Bp_bar;
        end
    end
end

end
