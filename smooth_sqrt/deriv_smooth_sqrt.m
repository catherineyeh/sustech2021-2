%from Duan & Lian 2016 "Smoothing Approximation to the Square-Root Exact
%Penalty Function," p. 89

function dphi_dy = deriv_smooth_sqrt(y)

    epsilon = 0.5;
    case1 = (y <= 0);
    case2 = (0 < y && y <= epsilon);
    case3 = (y > epsilon);
    
    if case1
        dphi_dy = 0;
    elseif case2
        dphi_dy = (1/(2*epsilon)) * sqrt(y);
    elseif case3
        dphi_dy = (1/2) * (1/sqrt(y));
    else
        error('issue with deriv_smooth_sqrt cases');
    end
        
        
    % if division by zero could cause an issue, so I think it's better to write out cases individually as above.    
    %dphi_dy = 0 * case1 + ...
     %   (1/(2*epsilon)) * sqrt(y) * case2 + ...
      %  (1/2) * (1/sqrt(y)) * case3;
end

