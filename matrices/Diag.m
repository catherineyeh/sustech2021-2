function Q_tilde = Diag(N, Q)
% Discription: computes Q_tilde and R_tilde
% Input:
%   N: timestep
%   Q: matrix on the diaganol
dimi = size(Q,1);
dimj = size(Q,2);
Q_tilde = zeros(N*dimi,N*dimj);

for i=1:dimi:N*dimi
    for j=1:dimj:N*dimj
        if i==j
            Q_tilde(i:i+dimi-1,j:j+dimj-1) = Q;
        end
    end
end
            
end

