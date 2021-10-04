function phi_y = smooth_sqrt(y)
% from Duan & Lian 2016
    epsilon = 0.01;
    case1 = y <= 0;
    case2 = 0 < y && y <= epsilon;
    case3 = y > epsilon;
    phi_y = (2/3) * sqrt(epsilon) * case1 + ...
        (1/(3*epsilon)) * y^(3/2) + (2/3) * sqrt(epsilon) * case2 + ...
        sqrt(y) * case3;
end

