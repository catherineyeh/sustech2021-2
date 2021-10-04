function bbar_matrix = b_bar_matrix(N, b_bar)
% Discription: Computes b_bar_matrix
% Input:
%   b_bar: 2x1 matrix

dimi = size(b_bar,1);
dimj = size(b_bar,2);
bbar_matrix = zeros(N*dimi, dimj);
for i=1:2:N*dimi
    bbar_matrix(i:i+dimi-1,:) = b_bar;
end
end

