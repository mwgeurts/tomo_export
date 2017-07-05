function Test05(testCase)
%% TEST 5: CT/Structure/Dose Display Functionality
%
% DESCRIPTION: This is unit test is performed manually and requires the
%   user to compare the displayed CT, structures, and dose display to
%   verify the plan is successfully parsed. The user must also verify that
%   the transparency, axis, and slice selection UI features work
%   accordingly.
%
% RELEVANT REQUIREMENTS: U007,F008,F009,F010,F011,F012,F013,F014,F015
%
% INPUT DATA: Archive patient XML file (testCase.inputData)

% Log test
Event('Executing unit test 5', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'CT/Structure/Dose Viewer Functional');

% Store test requirements
testCase.StoreResults('requirements', ['U007,F008,F009,F010,F011,F012,', ...
    'F013,F014,F015']);

% Separate into file parts
[path, name, ext] = fileparts(fullfile(testCase.inputData{end,2}));

% Add unit flag and archive path/name
testCase.config.UNIT_FLAG = '1';

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
callback(handles.archive_browse, handles);

% Start with pass result
result = 'Pass';

% Prompt user to verify that the TCS display works
prompt = questdlg(['Does the TCS display the expected CT image, structures, ', ...
    'and dose?'], 'Unit Test', 'Yes', 'No', 'Yes');
testCase.verifyEqual(prompt, 'Yes');
if ~strcmp(prompt, 'Yes')
    result = 'Fail';
end

% Prompt user to verify that the alpha works
prompt = questdlg('Does the transparency input function correctly?', ...
    'Unit Test', 'Yes', 'No', 'Yes');
testCase.verifyEqual(prompt, 'Yes');
if ~strcmp(prompt, 'Yes')
    result = 'Fail';
end

% Prompt user to verify that the TCS button works
prompt = questdlg('Does the TCS button function correctly?', ...
    'Unit Test', 'Yes', 'No', 'Yes');
testCase.verifyEqual(prompt, 'Yes');
if ~strcmp(prompt, 'Yes')
    result = 'Fail';
end

% Prompt user to verify that the slider works
prompt = questdlg('Does the slice selection slider function correctly?', ...
    'Unit Test', 'Yes', 'No', 'Yes');
testCase.verifyEqual(prompt, 'Yes');
if ~strcmp(prompt, 'Yes')
    result = 'Fail';
end

% Store results
testCase.StoreResults('results', result);
