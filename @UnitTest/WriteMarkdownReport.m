function WriteMarkdownReport(testCase)
% WriteMarkdownReport creates a Markdown report of the unit test results.
% The report includes tables of test workstation specifications (operating 
% system, processor, memory, etc.), test input files, reference data, test
% results (stored via StoreResults('results')), and a code coverage report.
% To bypass creating a report, leave the unit test class variable 
% reportFile empty.
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
if isempty(testCase.reportFile)
    return;
end

% Open file handle to config.txt file
if exist('Event', 'file') == 2
    Event(['Opening report file ', testCase.reportFile], 'UNIT');
end
fid = fopen(testCase.reportFile, 'w');

% Verify that file handle is valid
if fid < 3
    
    % If not, throw an error
    error(['The report file ', testCase.reportFile, ' could not be opened']);
end

%% Write report header
if exist('Event', 'file') == 2
    Event('Writing report header', 'UNIT');
end

fprintf(fid, ['The principal features of %s have been tested between ', ...
    'versions for a set of test suites to determine if regressions have ', ...
    'been introduced which may effect the results. These results are ', ...
    'summarized below, grouped by test suite. Note that pre-releases have ', ...
    'not been included in this unit testing.\n\n'], ...
    func2str(testCase.executable));

fprintf(fid, ['Unit tests developed for performance requirements are ', ...
    'separated from functional or interface tests (even if they execute ', ...
    'the same code) to allow the performance metric, typically time to ', ...
    'execute, to be reported in addition to the conventional Pass/Fail ', ...
    'test outcome. The purpose of this, along with the cyclomatic ', ...
    'complexity and code analyzer summary unit tests are to not only test ', ...
    'unit test passing but to also help identify poor coding practices. ', ...
    'Performance tests that pass requirement but are significantly worse ', ...
    'than prior versions of the application are further analyzed for ', ...
    'refactoring opportunities to maintain code simplicity.\n\n']);

% Write table of contents header
if exist('Event', 'file') == 2
    Event('Writing table of contents', 'UNIT');
end
fprintf(fid, '## Contents\n\n');

% Write table of contents
fprintf(fid, '* [System Configuration](#system-configuration)\n');
fprintf(fid, '* [Input Data](#input-data)\n');
fprintf(fid, '* [Test Results](#test-results)\n');
fprintf(fid, '* [Code Coverage](#code-coverage)\n');

%% Write Test System Configuration
if exist('Event', 'file') == 2
    Event('Writing test system configuration', 'UNIT');
end
fprintf(fid, '\n## Test System Configuration\n\n');
fprintf(fid, ['Computation times are documented based on the ', ...
    'following system configuration and reflect elapsed real time (as ', ...
    'opposed to CPU time). Note, other hardware configurations may also ', ...
    'be run during compatibility testing.\n\n']);

% Start table containing test configuration
fprintf(fid, '| Specification | Configuration |\n');
fprintf(fid, '|---------------|---------------|\n');

% Retrieve CPU info
if exist('Event', 'file') == 2
    Event('Retrieving test system CPU status', 'UNIT');
end
info = testCase.CPUInfo();

% Write processor information
fprintf(fid, '| Operating System | %s %s |\n', info.OSType, info.OSVersion);
fprintf(fid, '| Processor | %s |\n', info.Name);
fprintf(fid, '| Frequency | %s |\n', info.Clock);
fprintf(fid, '| Number of Cores | %i |\n', info.NumProcessors);

% Retrieve memory info
if exist('Event', 'file') == 2
    Event('Retrieving test system memory status', 'UNIT');
end
info = testCase.MemInfo();

% Write memory information
fprintf(fid, '| Memory | %0.2f GB (%0.2f GB available) |\n', ...
    info.Total/1024^3, info.Unused/1024^3);

% Test for GPU
if exist('Event', 'file') == 2
    Event('Retrieving compatible GPU status', 'UNIT');
end
try 
    
    % Store GPU information to temporary variable
    g = gpuDevice(1);
    
    % Print GPU information
    fprintf(fid, '| Graphics Card | %s |\n', g.Name);
    fprintf(fid, '| Graphics Memory | %0.0f MB (%0.0f MB available) |\n', ...
        g.TotalMemory / 1024^2, g.FreeMemory / 1024^2);
    fprintf(fid, '| CUDA Version | %s |\n', g.ComputeCapability);
    
    % Clear temporary variable
    clear g;

% Otherwise, a compatible GPU device does not exist
catch 
    fprintf(fid, '| Graphics Card | No compatible GPU device found |\n');
    fprintf(fid, '| Graphics Total Memory | |\n');
    fprintf(fid, '| Graphics Memory Available | |\n');
    fprintf(fid, '| CUDA Version | |\n');
end

% Write MATLAB version
v = regexp(version, '\((.+)\)', 'tokens');
fprintf(fid, '| MATLAB Version | %s |\n', v{1}{1});
fprintf(fid, '\n');

% Clear temporary variables
clear v info;

%% Write Input Data Table(s)
if exist('Event', 'file') == 2
    Event('Writing input data configuration', 'UNIT');
end

% If input data was used
if ~isempty(testCase.inputData) || ~isempty(testCase.referenceData)

    % Include an input data section
    fprintf(fid, '\n## Input Data\n\n');
    fprintf(fid, ['The following test cases were used during unit testing. ', ...
        'Where applicable, each unit test was run sequentially with each case. ', ...
        'Reference data corresponding to each test case was used to confirm ', ...
        'that the tool output matches the expected output.\n\n']);
end

% If input data was used
if ~isempty(testCase.inputData)

    % Start table containing test configuration
    fprintf(fid, '| Test Case | Location |\n');
    fprintf(fid, '|------------|----------|\n');

    % Print test case row
    for i = 1:size(testCase.inputData, 1)
        fprintf(fid, '| %s | %s |\n', testCase.inputData{i,1}, ...
            testCase.inputData{i,2});
    end
end

% If reference data was used
if ~isempty(testCase.referenceData)

    % Start table containing test configuration
    fprintf(fid, '\n\n| Reference Data | Location |\n');
    fprintf(fid, '|----------------|----------|\n');

    % Print test case row
    for i = 1:size(testCase.referenceData, 1)
        fprintf(fid, '| %s | %s |\n', testCase.referenceData{i,1}, ...
            testCase.referenceData{i,2});
    end
end

%% Write Test Results
if exist('Event', 'file') == 2
    Event('Writing test results', 'UNIT');
end
fprintf(fid, '\n## Test Results\n\n\n');

% Start results table
fprintf(fid, '| Test | Summary | Result |\n');
fprintf(fid, '|------|---------|--------|\n');

% Retrieve summaries and results
summaries = testCase.StoreResults('summary');
results = testCase.StoreResults('results');

% Loop through summaries
for i = 1:(min(length(summaries),length(results))-1)
    
    % Write summary and results
    fprintf(fid, '| %i | %s | %s |\n', i, summaries{i}, results{i});
end

%% Write Code Coverage
% Initialize file list with currentApp
fList = cell(0);

% Run requiredFilesAndProducts to get function names
f = matlab.codetools.requiredFilesAndProducts(...
    [func2str(testCase.executable), '.m']);

% Log number of functions found in current application
if exist('Event', 'file') == 2
    Event(sprintf('%i required functions identified in %s', length(f), ...
        func2str(testCase.executable)), 'UNIT');
end

% Loop through files, saving file names
for i = 1:length(f)
    
    % Retrieve file name
    [path, name, ~] = fileparts(f{i});

    % Store file name and relative path
    fList{length(fList)+1} = [strrep(path, pwd, ''), name];
end

% Remove duplicates
fList = unique(fList);
if exist('Event', 'file') == 2
    Event(sprintf('%i unique functions identified', ...
        length(fList)), 'UNIT');
end

% Sort array
fList = sort(fList);

% Initialize code coverage table
if exist('Event', 'file') == 2
    Event('Computing code coverage', 'UNIT');
end

% Initialize percentages
executed = zeros(length(fList), 1);
total = zeros(length(fList), 1);

% Loop through FunctionTable
for i = 1:size(testCase.stats.FunctionTable, 1)
    
    % Extract the filename
    [path, name, ~] = fileparts(testCase.stats.FunctionTable(i).FileName);

    % Save the relative path
    relname = [strrep(path, [pwd, '/'], ''), '/', name];
    
    % Loop through the file list
    for j = 1:length(fList)

        % If the current file already exists in the list (this will 
        % happen for subfunctions) or the file list is empty (the file
        % was not found)
        if strcmp(fList{j}, relname) || isempty(fList{j})

            % Update files cell array
            fList{j} = relname;

            % Add the number of executed lines
            executed(j) = executed(j) + ...
                size(testCase.stats.FunctionTable(i).ExecutedLines, 1);

            % If the total number of lines has not been computed yet
            if total(j) == 0
                total(j) = ...
                    testCase.SLOC(testCase.stats.FunctionTable(i).FileName);
                if exist('Event', 'file') == 2
                    Event(sprintf('%i lines counted in %s', total(j), ...
                        testCase.stats.FunctionTable(i).FileName), 'UNIT');
                end
            end

            % Break from the loop
            break;
        end
    end
end

% Print code coverage header
if exist('Event', 'file') == 2
    Event('Writing code coverage results', 'UNIT');
end
fprintf(fid, '\n## Code Coverage\n\n');
fprintf(fid, ['The following table lists the percentage of code evaluated ', ...
    'during unit testing for each executable. Note that submodule functions ', ...
    'may not have high coverage rates by design, as they often contain ', ...
    'additional features that are unused by this particular ', ...
    'application.\n\n']);

% Print table header row
fprintf(fid, '| Function | Coverage |\n');

% Print a separator row
fprintf(fid, '|----------|----------|');

% Loop through each file
for i = 1:length(fList)
    
    % If a file name exists and filename is not userpath
    if ~isempty(fList{i}) && ~strcmp(fList{i}, 'userpath')
       
        % Write the file name
        fprintf(fid, '\n| %s |', fList{i});
        
        % If the total number of lines were computed
        if total(i) > 0

            % Printf the coverage
            fprintf(fid, ' %0.1f%% |', min(1, executed(i)/total(i)) * 100);
        else

            % Otherwise, print an empty cell
            fprintf(fid, '   |');
        end
    end
end

%% Finish up
% Close file handle
fclose(fid);

% Clear temporary variables
clear fid;

% Log completion
if exist('Event', 'file') == 2
    Event('Unit Testing Completed!', 'UNIT');
end