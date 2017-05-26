function Test06(testCase)
% UNIT TEST 6: Plan Data Correct
%
% DESCRIPTION: This unit test compares the parsed image, plan, structures,
%   and dose information and compares it to an expected value.
%
% RELEVANT REQUIREMENTS: U008, F016
%
% INPUT DATA: Archive patient XML file (testCase.inputData), reference data
%   (testCase.referenceData)
%
% CONDITION A (+): The extracted image structure fields equal the expected 
%   value
%
% CONDITION B (+): The extracted structure fields equal the expected value
%
% CONDITION C (+): The extracted dose structure fields equal the expected 
%   value
%
% CONDITION D (+): The extracted plan structure fields equal the expected
%   value

% Log test
Event('Executing unit test 6', 'UNIT');

% Store test summary
testCase.testSummaries{6} = 'Plan Information Parsed Correctly';

% Store test requirements
testCase.testRequirements{6} = {'U008', 'F016'};
 
% Loop through test archives
for i = 1:size(testCase.inputData, 1)

    % Separate into file parts
    [path, name, ext] = fileparts(fullfile(testCase.inputData{i,2}));
    
    % Set archive path/name
    testCase.config.UNIT_FLAG = '1';
    testCase.config.UNIT_PATH = path;
    testCase.config.UNIT_NAME = [name, ext];
    
    % Write config options
    testCase.WriteConfigFile(testCase.configFile, testCase.config);

    % Open application
    testCase.figure = testCase.executable();

    % Retrieve handles
    handles = guidata(testCase.figure);

    % Retrieve callback to archive browse button
    callback = get(handles.archive_browse, 'Callback');
    
    % Execute browse
    callback(handles.archive_browse, handles);
    
    % Retrieve handles
    handles = guidata(testCase.figure);
    
    % Load the referenceData
    ref = load(testCase.referenceData{i,2});
    
    % Verify db, planUIDs match expected
    testCase.verifyEqual(handles.db, ref.db);
    testCase.verifyEqual(handles.planUIDs, ref.planUIDs);
    
    % Verify that all existing reference image fields match, excluding
    % structures and relative file names
    n = fieldnames(ref.image);
    for j = 1:length(n)
        if ~strcmp(n{j}, 'structures') && ...
                ~contains(n{j}, 'file', 'IgnoreCase', true) && ...
                ~contains(n{j}, 'path', 'IgnoreCase', true)
            testCase.verifyEqual(handles.image.(n{j}), ref.image.(n{j}));
        end
    end
    
    % Verify that all structure fields match
    for j = 1:length(ref.image.structures)
        m = fieldnames(ref.image.structures{j});
        for k = 1:length(m)
            if ~contains(m{k}, 'file', 'IgnoreCase', true) && ...
                    ~contains(m{k}, 'path', 'IgnoreCase', true)
                testCase.verifyEqual(handles.image.structures{j}.(m{k}), ...
                    ref.image.structures{j}.(m{k}));
            end
        end
    end
       
    % Verify that all existing reference plan fields match
    n = fieldnames(ref.plan);
    for j = 1:length(n)
        if ~contains(n{j}, 'file', 'IgnoreCase', true) && ...
                ~contains(n{j}, 'path', 'IgnoreCase', true)
            testCase.verifyEqual(handles.plan.(n{j}), ref.plan.(n{j}));
        end
    end
    
    % Verify that all existing reference dose fields match
    n = fieldnames(ref.dose);
    for j = 1:length(n)
        if ~contains(n{j}, 'file', 'IgnoreCase', true) && ...
                ~contains(n{j}, 'path', 'IgnoreCase', true)
            testCase.verifyEqual(handles.dose.(n{j}), ref.dose.(n{j}));
        end
    end
    
    % Close file handle
    close(testCase.figure);
end