function u_star = get_best_u(A_hat, B_hat, C_hat, D_hat, L, yt, Wtilde, Q_bar, R_bar)

c = A_hat * yt + C_hat * Wtilde + D_hat * L;

%U_star = -inv(B_hat'*Q_bar*B_hat + R_bar) * B_hat' * Q_bar * c;

% A\B instead of inv(A)*B

U_star = -(B_hat'*Q_bar*B_hat + R_bar) \ (B_hat' * Q_bar * c);

if size(U_star, 2) > 1
    error("wrong U_star dimension");
end

u_star = U_star(1);

%there is no guarantee that the inverse exists
if ~isfinite(u_star) 
    u_star = 0;
    disp('issue with inverse operation in get_best_u so we set u_star to zero');
end

if u_star < 0
    u_star = 0;
end

end

