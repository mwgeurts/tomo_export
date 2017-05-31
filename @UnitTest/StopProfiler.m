function StopProfiler(testCase)

% Stop profiler
testCase.stats = profile('info');

% Log function length
if exist('Event', 'file') == 2
    Event(sprintf(['Stopping and retrieving MATLAB profiler status\n', ...
        'Functions profiled: %i'], size(testCase.stats.FunctionTable, 1)), ...
        'UNIT');
end