% todo: show zoom in on qpump corners

epsilon = 0.5;
g = 9.81;  % gravitational constant [m/s^2]
f = 3.56; l = 18.4; D = 0.2; kL = 0.6; apump = 0.1^2*pi;

c1 = (f*l/D + kL)/(2*g*apump^2);

a2 = 68.8;  % surface area of tank 2 [m^2]
a1 = 25;  % surface area of tank 1 [m^2]
zveg = 4.57 / 100;  % minimum water level in tank 2 [m]
zsoil = 0.5; %0.05;  % soil depth [m]
zH = 0.6;  % net positive suction head required in tank 1 [m]
zpump = 0.15;  % pump elevation w.r.t. base of tank 1 [m]

xp2_tilde = zveg*a2;
xp1_tilde = (zH*zpump)*a1;
d = 16;  % elevation of tank 2 relative to tank 1 [m]
Hpump0 = 55.2366;  % pump head at 0 flow rate  [m]

syms x1 x2 u;

a = -0.0446 * 3600^2 ; % -0.0446 hr^2/m^5 to s^2/m^5
c = 55.2366; % [m]
z = -d + x1/a1 + c; % [m]
% a and c are obtained from the least square method

bpump =1/ sqrt((f*l/D + kL)/(2*g*apump^2) - a);
%fpump = bpump * sqrt(z);
%qpumpe = fpump * (1 / (1 + exp((xp1_tilde - x1)/epsilon))) * (1 / (1 + exp((x2 - xp2_tilde)/epsilon)));

fpump = piecewise(x2/a2>zveg, 0, x1/a1<zpump+zH, 0, u*bpump * sqrt(z));

fpumpe = u* piecewise(0>=z, ...
    bpump*(2/3)*epsilon, ...
    0<z<=epsilon, ...
    bpump*((1/3)*(1/epsilon)*z^(3/2)+(2/3)*sqrt(epsilon)), ...
    z > epsilon, ...
    bpump*sqrt(z));
qpumpe = fpumpe * (1 / (1 + exp((xp1_tilde - x1)/epsilon))) * (1 / (1 + exp((x2 - xp2_tilde)/epsilon)));


figure(3);
y1 = subs(fpump, [u, x2], [0.5, 0]);
fplot(y1, [-1000 3000], ':b', 'linewidth',4); hold on;
%y2 = subs(fpumpe, [u, x2], [0.5, 0]);
%fplot(y2, [-1000 3000], 'linewidth', 2); hold on;
y = subs(qpumpe, [u, x2], [0.5, 0]);
fplot(y, [-1000 3000], 'linewidth', 2); hold on;
title('$q_{pump}(x,u)$, $q^{\epsilon}_{pump}(x,u)$ with $u = 0.5$, $x_2=0$', 'fontsize', 18, 'interpreter', 'latex')
xlabel('$x_1$ (m$^3$)', 'fontsize', 20, 'interpreter', 'latex')
ylabel('Flow rate (m$^3$/s)', 'fontsize', 20, 'interpreter', 'latex')
legend('$q_{pump}(x,u)$', '$q^{\epsilon}_{pump}(x,u)$', 'interpreter', 'latex', 'fontsize', 16);
set(gca,'FontSize',14);

figure(2);
y1 = subs(fpump, [u, x1], [0.5, 100]);
fplot(y1, [-0.5 10], ':b', 'linewidth', 4); hold on;
%y2 = subs(fpumpe, [u x1], [0.5, 100]);
%fplot(y2, [-0.5 10], 'linewidth', 2); hold on;
y = subs(qpumpe, [u, x1], [0.5, 100]);
fplot(y, [-0.5 10], 'linewidth', 2); hold on;
title('$q_{pump}(x,u)$, $q^{\epsilon}_{pump}(x,u)$ with $u = 0.5$, $x_1=100$', 'fontsize', 18, 'interpreter', 'latex')
xlabel('$x_2$ (m$^3$)', 'fontsize', 20, 'interpreter', 'latex')
ylabel('Flow rate (m$^3$/s)', 'fontsize', 20, 'interpreter', 'latex')
legend('$q_{pump}(x,u)$', '$q^{\epsilon}_{pump}(x,u)$', 'interpreter', 'latex', 'fontsize', 16);

set(gca,'FontSize',14);
