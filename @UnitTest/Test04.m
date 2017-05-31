function Test04(testCase)
% UNIT TEST 4: Archive Browse Loads Data Successfully, on Time
%
% DESCRIPTION: This unit test verifies a callback exists for the archive 
%   browse button and executes it under unit test conditions (such that a 
%   file selection dialog box is skipped), simulating the process of a user
%   selecting input data. The time necessary to load the file is also
%   checked.
%
% RELEVANT REQUIREMENTS: U002, U003, U004, U005, U006, F002, F003, F006, 
%   F016, F017, C005, C006, C007, C008, C009, P002
%
% INPUT DATA: Archive patient XML file (testCase.inputData)
%
% CONDITION A (+): The callback for the browse button can be executed
%   without error when a valid filename is provided
%
% CONDITION B (-): The callback will throw an error if an invalid filename
%   is provided

% CONDITION C (+): Upon file loading successfully, the DICOM Export button
%   is enabled
%
% CONDITION D (+): The time required to load is less than 60 seconds

% Log test
Event('Executing unit test 4', 'UNIT');

% Store test summary
testCase.testSummaries{4} = 'Archive Browse Time';

% Store test requirements
testCase.testRequirements{4} = {'U002', 'U003', 'U004', 'U005', 'U006', ...
    'F002', 'F003', 'F006', 'F016', 'F017', 'C005', 'C006', 'C007', 'C008', ...
    'C009', 'P002'};

%% CONDITION B
% Add unit flag and dummy archive path/name
testCase.config.UNIT_FLAG = '1';
testCase.config.UNIT_PATH = './asd';
testCase.config.UNIT_NAME = 'nofile.xml';

% Write config options
testCase.WriteConfigFile(testCase.configFile, testCase.config);

% Open application
testCase.figure = testCase.executable();

% Retrieve handles
handles = guidata(testCase.figure);

% Retrieve callback to archive browse button
callback = get(handles.archive_browse, 'Callback');

% Try to execute with bad file
try
    % Try to execute browse
    callback(handles.archive_browse, data);
    
    % Fail if the above command passes
    testCase.verifyFalse(true);
catch err
    testCase.verifyInstanceOf(err, 'MException')
end

% Close file handle
close(testCase.figure);
 
%% CONDITIONS A, C, D
% Loop through test archives
for i = 1:size(testCase.inputData, 1)

    % Separate into file parts
    [path, name, ext] = fileparts(fullfile(testCase.inputData{i,2}));
    
    % Set archive path/name
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
    pause(2)
    t = tic;
    callback(handles.archive_browse, handles);
    time = toc(t);
    testCase.testResults{4}{i} = sprintf('%0.1f sec', time);
    testCase.verifyLessThan(time, 60);
    
    % Retrieve handles
    handles = guidata(testCase.figure);
    
    % Verify DICOM export is enabled
    testCase.verifyEqual(lower(get(handles.dicom_button, 'Enable')), 'on');
    
    % Close file handle
    close(testCase.figure);
end