function data_n = get_lookahead(lookahead, time, data)
%GET_LOOKAHEAD
% Input
%   lookahead: length of lookahead time horizon
%   time: current time
%   data: data to lookahead

    data_n = data(time : time + lookahead - 1);
    
end

