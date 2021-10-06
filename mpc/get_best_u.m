function u_star = get_best_u(A_hat, B_hat, C_hat, D_hat, L, yt, Wtilde, Q_bar, R_bar)

c = A_hat * yt + C_hat * Wtilde + D_hat * L;
U_star = -inv(B_hat'*Q_bar*B_hat + R_bar) * B_hat' * Q_bar * c;
if size(U_star, 2) > 1
    error("wrong U_star dimension");
end
u_star = U_star(1)

end

