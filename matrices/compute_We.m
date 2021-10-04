function We = compute_We(config, rn_n, temp_n, dew_pt_n, wind_n)
%COMPUTE_WE 

    % parameters
    G = 0.1 * rn_n;  % soil heat flux density [MJ/(m^2*day)] https://digitalcommons.unl.edu/cgi/viewcontent.cgi?article=2407&context=usdaarsfacpub#:~:text=The%20amount%20of%20thermal%20energy,day%20or%20between%20sea%2D%20sons.
    Cp = 1.013^(-3);  % specific heat at constant pressure [MJ/(kg)(celsius)]
    P = 101.16;  % atmospheric pressure at 12 m above sea level
    e = 0.622;  % ratio of molecular weight of water vapour
    lambda = 2.45;   % latent heat of vaporization
    Tmean = mean(temp_n);
    Tmax = max(temp_n); Tmin = min(temp_n);
    gamma = (Cp * P) / (e * lambda);
    Delta = (4098 * (0.6108 * exp((17.27 * Tmean) / (Tmean + 237.3)))) / (Tmean + 237.3)^2;
    e_Tmin = 0.6108 * exp((17.27 * Tmin) / (Tmin + 237.3));
    e_Tmax = 0.6108 * exp((17.27 * Tmax) / (Tmax + 237.3));
    es = (e_Tmin + e_Tmax)/2;  % mean vapour pressure
    es_n = zeros(config.lookahead, 1) + es;
    ea_n = 0.6108 * exp((17.27 * dew_pt_n) ./ (dew_pt_n + 237.3));   % actual vapour pressure

    E = (0.48*Delta*(rn_n-G) + (gamma*900*wind_n .* (es_n-ea_n))/(Tmean+273))./(Delta + gamma*(1+0.34*wind_n));
    
    Cevap = 0.001/86400;   % convert from [mm/day] to [m/s]
    a2 = config.a2;
    We = Cevap * a2 * E;  % [m^3/s]
end

