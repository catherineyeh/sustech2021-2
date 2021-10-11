function onoff_u = get_onoff_u(config, x1bar, x2bar, u_index)
x2t = config.a2 * config.zveg;
x1t = (config.zpump + config.zH) * config.a1;

if x2bar <= x2t && x1bar > x1t
    onoff_u = config.u
else
    onoff_u = 0
end
end

