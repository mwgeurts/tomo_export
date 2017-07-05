function Test10(testCase)
% UNIT TEST 10: Other plans load successfully
%
% DESCRIPTION: This is unit test verifies that the plan drop down menu
%   functions correctly and that each plan can be loaded successfully.
%
% RELEVANT REQUIREMENTS: U012,F004,F005,F007
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Upon selecting an entry in the plan drop down menu, the
%   selected plan is loaded without error, and that the DICOM export button
%   is not disabled.
%
% CONDITION B (-): The plan drop down menu is not empty

% Log test
Event('Executing unit test 10', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'Plan Selection Menu Functions Correctly');

% Store test requirements
testCase.StoreResults('requirements', 'U012,F004,F005,F007');

% Start with passing result
result = 'Pass';

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
    
    % Retrieve callback to plan selection menu
    callback = get(handles.plan_select, 'Callback');
    
    % Loop through each plan option
    for j = 1:length(handles.plan_select.String)
        
        % Set value
        handles.plan_select.Value = j;
        guidata(testCase.figure, handles);
        
        % Execute callback
        callback(handles.plan_select, handles); 
        
        % Verify DICOM button is active
        testCase.verifyEqual(lower(get(handles.dicom_button, 'Enable')), 'on');
        if ~isequal(lower(get(handles.dicom_button, 'Enable')), 'on')
            result = 'Fail';
        end
    end

    % Close file handle
    close(testCase.figure);
end

% Store result
testCase.StoreResults('results', result);