function pump = fill_pump_params(config)
    
    pump.apump = 0.01*pi;    
    pump.D = 0.2;
    pump.f = 3.56;
    pump.kL = 0.6;
    pump.l = 18.4;
    pump.c1 = (pump.f * pump.l/pump.D + pump.kL)/(2 * pump.g * pump.apump^2);
    pump.b = 1 / sqrt((pump.f*pump.l/pump.D + pump.kL) / (2 * config.g * pump.apump^2) - config.a_hat);
    
end

