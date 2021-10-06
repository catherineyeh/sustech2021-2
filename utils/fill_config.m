function config = fill_config()

    %% simulation parameters
    config.dt = 1;  % seconds
    config.sim_length = 10 * 60 * 60 / config.dt; % 10 hours (M)
    config.lookahead = 10;  % look ahead horizon, 10 seconds (N)   
    config.epsilon = 0.01;
    %% plotting parameters
    config.colors = ['-b', ':m', 'k--o', '--r', ':g'];
    %% tuning parameters
    config.u = 0;
    config.lambda = 0.5;
    %% universal parameters
    config.g = 9.81;  % graviational constant m/s^2
    %% system parameters
    config.a1 = 72;  % surface area of tank 1 m^2
    config.a2 = 68.8;  % surface area of tank 2 m^2
    config.a_in = (0.305)^2 * pi;  % area of flow through the pump
    config.a_hat = -5.78 * 10^5;  % coefficient of (3b)
    config.c_hat = 55.2;  % coefficient in (3b)
    config.cd = 0.61;  % discharge coefficient (no units)
    config.d = 16;  % elevation of rooftop vegetation relative to cistern
    config.K = 7.83 / (10^8);  % saturated hydraulic conductivity
    config.ro = 0.125;  % radius of the outlet of cistern (m)
    config.cout = config.cd * pi * config.ro^2 * sqrt(2 * config.g);  % coefficient in (2)
    config.zcap = 0.5 * config.a2;  % soil capacity (m^3)
    config.zH = 0.6;  % minimum head above pump (m)
    config.zo = 3;  % elevation of the cistern outlet (m)
    config.zpump = 0.15;  % pump elevation w.r.t base of cistern (m)
    config.zsoil = 0.5;  % soil depth of the green roof
    config.zveg = 4.57 / 10^2;  % desired water depth (m)

end

