function [wr, rn, temp, dew_pt, wind] = get_data(option, config)
% GET_DATA gets the data needed to calculate disturbances: 
%          rainfall and evapotranspiration rate
% Input
%   option: "dry" or "wet"
%   config parameters: a1pipe, a2, sim_length
% Output
%   column vectors
%   wr: rainfall rate [m^3/s]
%   rn: solar irradiance [MJ/m^2day]
%   temp: temperature [degree C]
%   dew_pt: dew point temperature [degree C]
%   wind: wind speed [m/s]
%   pressure: [kPa]

    if option == "dry"
        % wr (rainfall)
        wr = readtable('en_climate_hourly_03-2021.csv', ...
                'Range','P3:P745', ...
                'PreserveVariableNames',true);
        wr = wr{:,:} / 1000 / 3600;
        wr = repelem(wr, 3600, 1);  % repeat entry 3600 times
        %wr1 = wr * config.a1pipe;
        %wr2 = wr * config.a2;
        
        % we (evapotranspiration)
        rn_1 = readtable('Rn_march.csv', 'PreserveVariableNames', true);
        rn_1 = rn_1{:,:};
        rn = (mean(rn_1) * 24*60*60 / 10^6) * ones(config.sim_length * 2, 1);  % taking (J/s)/m^2, and took average of data over one day; one day = 24*60*60 seconds; /10^6 for MJ
        temp = readtable('en_climate_hourly_03-2021.csv', ...
            'Range','J3:J745', ...
            'PreserveVariableNames',true);
        temp = temp{:,:};
        temp = repelem(temp, 3600, 1);
        dew_pt = readtable('en_climate_hourly_03-2021.csv', ...
            'Range','L3:L745', ...
            'PreserveVariableNames',true);
        dew_pt = dew_pt{:,:};
        dew_pt = repelem(dew_pt, 3600, 1);
        wind = readtable('en_climate_hourly_03-2021.csv', ...
            'Range','T3:T745', ...
            'PreserveVariableNames',true);  % [km/h]
        wind = wind{:,:};
        wind = repelem(wind / 3.6, 3600, 1);  % [m/s]
        
    elseif option == "wet"
        % wr (rainfall)
        wr = readtable('en_climate_hourly_07-2021.csv', ...
                'Range','P148:P745', ...
                'PreserveVariableNames',true);
        wr = wr{:,:} / 1000 / 3600;
        wr = repelem(wr, 3600, 1);  % repeat entry 3600 times
        
        % we (evapotranspiration)
        rn_1 = readtable('Rn_july.csv', 'PreserveVariableNames', true);
        rn_1 = rn_1{:,:};
        rn = mean(rn_1) * 24*60*60  / 10^6 * ones(config.sim_length * 2, 1);
        temp = readtable('en_climate_hourly_07-2021.csv', ...
            'Range','J148:J745', ...
            'PreserveVariableNames',true);
        temp = temp{:,:};
        temp = repelem(temp, 3600, 1);
        dew_pt = readtable('en_climate_hourly_07-2021.csv', ...
            'Range','L148:L745', ...
            'PreserveVariableNames',true);
        dew_pt = dew_pt{:,:};
        dew_pt = repelem(dew_pt, 3600, 1);
        wind = readtable('en_climate_hourly_07-2021.csv', ...
            'Range','T148:T745', ...
            'PreserveVariableNames',true);  % [km/h]
        wind = wind{:,:};
        wind = repelem(wind / 3.6, 3600, 1);  % [m/s]
        
    end
    
end

