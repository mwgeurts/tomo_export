function StartProfiler(~)

% Start profiler
profile off;
profile on -history;

% Retrieve profiler status
S = profile('status');

% Log status information
if exist('Event', 'file') == 2
    Event(sprintf(['Starting MATLAB profiler\nStatus: %s\n', ...
        'Detail level: %s\nTimer: %s\nHistory tracking: ', ...
        '%s\nHistory size: %i'], S.ProfilerStatus, S.DetailLevel, S.Timer, ...
        S.HistoryTracking, S.HistorySize), 'UNIT');
end

% Clear temporary variables
clear S;