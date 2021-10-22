function pump = fill_pump_params(config)
    
    pump.apump = 0.01*pi;    
    pump.D = 0.2;
    pump.f = 3.56;
    pump.kL = 0.6;
    pump.l = 18.4;
    
    pump.c1 = (pump.f * pump.l/pump.D + pump.kL)/(2 * config.g * pump.apump^2);
    
    inside_sqrt = pump.c1 - config.a_hat;
    
    pump.b = 1 / sqrt(inside_sqrt);
    
    pumpb2 = 1 / sqrt((pump.f*pump.l/pump.D + pump.kL) / (2 * config.g * pump.apump^2) - config.a_hat);
    
    if ~isequal(pump.b, pumpb2)
        error('potential issue with pump b term');
    end
    
end

