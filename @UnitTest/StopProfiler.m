function StopProfiler(testCase)
% StopProfiler is a unit test class teardown function that stops the MATLAB
% profiler and stores the results to the class variable stats.
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

% Stop profiler
testCase.stats = profile('info');

% Log function length
if exist('Event', 'file') == 2
    Event(sprintf(['Stopping and retrieving MATLAB profiler status ', ...
        '(%i functions profiled)'], size(testCase.stats.FunctionTable, 1)), ...
        'UNIT');
end