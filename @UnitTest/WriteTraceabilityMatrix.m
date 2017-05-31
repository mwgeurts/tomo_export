function WriteTraceabilityMatrix(testCase)


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

fprintf(fid, ['The following table graphically depicts the traceability ', ...
    'of each [unit test](Unit-Testing) (labelled by test ID, as columns) ', ...
    'and [software requirement](Requirements) (labelled by requirement ', ...
    'ID, as rows).  Within each cell, an X indicates whether the test ', ...
    'conditions (positive and negative, where applicable) evaluate the ', ...
    'given requirement. Note, for interface and non-functional ', ...
    'requirements only positive conditions are tested.\n\n']);

%% Write traceability matrix

% Initialize list of requirements
reqs = cell(0);

% Write header
fprintf(fid, '|      |');
for i = 1:size(testCase.testRequirements)
    fprintf(fid, ' %02i |', i);
    reqs = horzcat(reqs, testCase.testRequirements{i}); %#ok<AGROW>
end
fprintf(fid, '\n|------|');
for i = 1:length(testCase.testRequirements)
    fprintf(fid, '---|');
end

% Sort out unique requirements list
[reqs] = unique(reqs, 'sorted');

% Write each requirement
for j = 1:length(reqs)
    fprintf(fid, '\n| %s |', reqs{j});
    for i = 1:length(testCase.testRequirements)
        if ~any(strcmp(testCase.testRequirements{i}, reqs{j}))
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
