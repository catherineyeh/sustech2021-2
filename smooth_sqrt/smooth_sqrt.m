function phi_y = smooth_sqrt(y)
% from Duan & Lian 2016 "Smoothing Approximation to the Square-Root Exact
% Penalty Function," p. 89
    epsilon = 0.5;
    case1 = (y <= 0);
    case2 = (0 < y && y <= epsilon);
    case3 = (y > epsilon);
    
    if case1
        phi_y = (2/3) * sqrt(epsilon);
    elseif case2
        phi_y = (1/(3*epsilon)) * y^(3/2) + (2/3) * sqrt(epsilon);
    elseif case3
        phi_y = sqrt(y);
    else
        error('issue with smooth_sqrt cases');
    end
    
    % an issue could arise if a negative y is raised to 3/2, so I've
    % re-written in terms of separate cases above.
    %
    % phi_y = (2/3) * sqrt(epsilon) * case1 + ...
    %    ((1/(3*epsilon)) * y^(3/2) + (2/3) * sqrt(epsilon)) * case2 + ...
    %    sqrt(y) * case3;
    % in line 22, parentheses are needed for (terms_for_case_2) * case2.
end



