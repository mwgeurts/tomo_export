function WriteMarkdownReport(testCase)


%% Open Report File
% If the report is empty, return without writing anything
if ~isfield(testCase, 'reportFile') || isempty(testCase.reportFile)
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

fprintf(fid, ['The principal features of the TomoTherapy Patient Archive ', ...
    'DICOM Export Tool have been tested between versions for a set of test ', ...
    'suites to determine if regressions have been introduced which may ', ...
    'effect the results. These results are summarized below, grouped by ', ...
    'test suite. Note that pre-releases have not been included in this ', ...
    'unit testing.\n\n']);

fprintf(fid, ['Unit tests developed for performance requirements are ', ...
    'separated from functional or interface tests (even if they execute ', ...
    'the same code) to allow the performance metric, typically time to ', ...
    'execute, to be reported in addition to the conventional Pass/Fail ', ...
    'test outcome. The purpose of this, along with the cyclomatic ', ...
    'complexity and code analyzer summary unit tests (which uniquely do ', ...
    'not trace to a requirement) are to not only test unit test passing ', ...
    'but to also help identify poor coding practices. Performance tests ', ...
    'that pass requirement but are significantly worse than prior versions ', ...
    'of the application are further analyzed for refactoring opportunities ', ...
    'to maintain code simplicity.\n\n']);

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
fprintf(fid, '## Test System Configuration\n\n');
fprintf(fid, ['Computation times are documented based on the ', ...
    'following system configuration and reflect elapsed real time (as ', ...
    'opposed to CPU time). Note, other hardware configurations may also ', ...
    'be run during compatibility testing.\n\n']);

% Start table containing test configuration
fprintf(fid, '| Specification | Configuration |\n');
fprintf(fid, '|----|----|\n');

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

%% Write Input Data Table





%% Write Test Results





%% Write Code Coverage





%% Finish up
% Close file handle
fclose(fid);

% Clear temporary variables
clear fid;

% Log completion
if exist('Event', 'file') == 2
    Event('Unit Testing Completed!', 'UNIT');
end