function config = fill_config()

    %% simulation parameters
    config.dt = 1;  % seconds
    config.sim_length = 12 * 60 * 60 / config.dt; % 12 hours (M) = 12 hr * 60 min/hr * 60 sec/min = 12*60*60 sec
    config.lookahead = 10;  % look ahead horizon, 10 seconds (N)   
    %config.lookahead = 30; % 30 seconds, ideally we want every 30 min but this takes too long
    config.epsilon = 0.5;
    %% plotting parameters
    config.colors = ['b', 'm', 'k', 'r', 'g'];
    config.styles = ['-', ':', '--', '-.', ':'];
    %% tuning parameters
    %config.u = 0.5;
    config.onoffu = [2, 1.5, 1, 0.5, 0.2];
    config.u1 = '$v = 2$';
    config.u2 = '$v = 1.5$';
    config.u3 = '$v = 1$';
    config.u4 = '$v = 0.5$';
    config.u5 = '$v = 0.2$';
    %config.lambda = 0.001;
    %config.lambdas = [0.001, 0.01, 0.1, 1, 10];
    
    config.lambdas = [0.00001, 0.0001, 0.001, 0.01, 0.1];
    config.lambda1 = '$\lambda=0.00001$';
    config.lambda2 = '$\lambda=0.0001$';
    config.lambda3 = '$\lambda=0.001$';
    config.lambda4 = '$\lambda=0.01$';
    config.lambda5 = '$\lambda=0.1$';
    %% universal parameters
    config.g = 9.81;  % graviational constant m/s^2
    %% system parameters
    height_of_tank = 4; %m, assumed since drawing is not clear
    config.a1 = 100/height_of_tank;  % surface area of tank 1 m^2
    config.a2 = 68.8;  % surface area of tank 2 m^2
    % 914.4 * 2279.7 mm^2 per test bed * 33 test beds
    config.a_in = (0.305)^2 * pi;  % area of flow through the pump
    config.a_hat = -5.78 * 10^5;  % coefficient of (3b)
    config.c_hat = 55.2;  % coefficient in (3b)
    config.cd = 0.61;  % discharge coefficient (no units)
    config.d = 16;  % elevation of rooftop vegetation relative to cistern (m)
    config.K = 7.83 / (10^8);  % saturated hydraulic conductivity
    config.ro = 0.125;  % radius of the outlet of cistern (m)
    config.cout = config.cd * pi * config.ro^2 * sqrt(2 * config.g);  % coefficient in (2)
    config.zcap = 0.5 * config.a2;  % soil capacity (m^3)
    config.zH = 0.6;  % minimum head above pump (m)
    % config.zo = 104.19;  % elevation of the cistern outlet (m)
    % this looks about 2.4 m *3/5 in the drawing
    % the number 104.19, I believe refers to a distance in mm about the
    % center of the outlet.
    config.zo = 3; % elevation of the cistern outlet (m), assumed since drawing is not clear
    config.zpump = 0.15;  % pump elevation w.r.t base of cistern (m)
    config.zsoil = 0.5;  % soil depth of the green roof (m)
    config.zveg = 4.57 / 10^2;  % desired water depth (m)

end

