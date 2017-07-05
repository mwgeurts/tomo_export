function StartProfiler(~)
% StartProfiler is called during unit test class setup to starts the MATLAB
% profiler. If an Event function exists, the profiler settings will be
% logged.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Start profiler
profile off;
profile on -history;

% Log status information
if exist('Event', 'file') == 2
    
    % Retrieve profiler status
    S = profile('status');
    
    Event(sprintf(['Starting MATLAB profiler\nStatus: %s\n', ...
        'Detail level: %s\nTimer: %s\nHistory tracking: ', ...
        '%s\nHistory size: %i'], S.ProfilerStatus, S.DetailLevel, S.Timer, ...
        S.HistoryTracking, S.HistorySize), 'UNIT');
    
    % Clear temporary variables
    clear S;
end

