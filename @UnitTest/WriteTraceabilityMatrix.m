function WriteTraceabilityMatrix(testCase)
% WriteTraceabilityMatrix creates a Markdown report containing a table of
% unit tests and the requirements that each tests. Each unit test records a
% list of requirements (comma separated) that is stored via
% StoreResults('requirements'). If the traceMatrix unit test class variable
% is empty, this function will return without creating the report.
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

%% Open Report File
% If the report is empty, return without writing anything
if isempty(testCase.traceMatrix)
    return;
end

% Open file handle to config.txt file
if exist('Event', 'file') == 2
    Event(['Opening report file ', testCase.traceMatrix], 'UNIT');
end
fid = fopen(testCase.traceMatrix, 'w');

% Verify that file handle is valid
if fid < 3
    
    % If not, throw an error
    error(['The report file ', testCase.traceMatrix, ' could not be opened']);
end

%% Write report header
if exist('Event', 'file') == 2
    Event('Writing report header', 'UNIT');
end

% Write summary paragraph
fprintf(fid, ['The following table graphically depicts the traceability ', ...
    'of each [unit test](Unit-Testing) (labelled by test ID, as columns) ', ...
    'and [software requirement](Requirements) (labelled by requirement ', ...
    'ID, as rows).  Within each cell, an X indicates whether the test ', ...
    'conditions (positive and negative, where applicable) evaluate the ', ...
    'given requirement. Note, for interface and non-functional ', ...
    'requirements only positive conditions are tested.\n\n']);

%% Write traceability matrix
% Read in requirements
tests = testCase.StoreResults('requirements');

% Initialize list of requirements
reqs = cell(0);

% Write header
fprintf(fid, '|      |');
for i = 1:length(tests)-1
    fprintf(fid, ' %02i |', i);
    reqs = horzcat(reqs, strsplit(tests{i},',')); %#ok<AGROW>
end
fprintf(fid, '\n|------|');
for i = 1:length(tests)-1
    fprintf(fid, '----|');
end

% Sort out unique requirements list
[reqs] = unique(reqs, 'sorted');

% Write each requirement
for j = 1:length(reqs)
    fprintf(fid, '\n| %s |', reqs{j});
    for i = 1:length(tests)-1
        if any(strcmp(strsplit(tests{i},','), reqs{j}))
            fprintf(fid, ' X  |');
        else
            fprintf(fid, '    |');
        end
    end
end

%% Finish up
% Close file handle
fclose(fid);

% Clear temporary variables
clear fid;
