function dphi_dy = deriv_smooth_sqrt(y)
    epsilon = 0.01;
    case1 = y <= 0;
    case2 = 0 < y && y <= epsilon;
    case3 = y > epsilon;
    
    dphi_dy = 0 * case1 + ...
        (1/(2*epsilon)) * sqrt(y) * case2 + ...
        (1/2) * (1/sqrt(y)) * case3;
end

