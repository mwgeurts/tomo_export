function Test07(testCase)
% UNIT TEST 7: DICOM Export Writes Successfully/Write Time
%
% DESCRIPTION: This unit test verifies a callback exists for the DICOM
%   export browse button and executes it under unit test conditions (such 
%   that a folder selection dialog box is skipped), simulating the process 
%   of a user selecting an export folder.  The time necessary to write the 
%   files is also checked.
%
% RELEVANT REQUIREMENTS: U009, U010, U011, F018, F019, F020, F021, F022,
%   P003
%
% INPUT DATA: path to export DICOM images to (testCase.exportPath)
%
% CONDITION A (+): The callback for the DICOM Export button can be executed
%   without error when a valid folder is provided
%
% CONDITION B (-): The callback will return without error when no folder
%   is provided

% Log test
Event('Executing unit test 7', 'UNIT');

% Store test summary
testCase.testSummaries{7} = 'DICOM Export Write Time';

% Store test requirements
testCase.testRequirements{7} = {'U009', 'U010', 'U011', 'F018', 'F019', ...
    'F020', 'F021', 'F022', 'P003'};
 
% Loop through test archives
for i = 1:size(testCase.inputData, 1)

    % Separate into file parts
    [path, name, ext] = fileparts(fullfile(testCase.inputData{i,2}));
    
    % Set archive path/name
    testCase.config.UNIT_FLAG = '1';
    testCase.config.UNIT_PATH = path;
    testCase.config.UNIT_NAME = [name, ext];
    testCase.config.UNIT_EXPORT_PATH = testCase.exportPath;
    
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
    
    % Retrieve callback to DICOM export button
    callback = get(handles.dicom_button, 'Callback');
    
    % Execute export
    pause(2)
    t = tic;
    callback(handles.dicom_button, handles);
    time = toc(t);
    testCase.testSummaries{7}{i} = sprintf('%0.1f sec', time);
    testCase.verifyLessThan(time, 200);

    % Close file handle
    close(testCase.figure);
end