function Test08(testCase)
% UNIT TEST 8: DICOM Files Import into MIM
%
% DESCRIPTION: This is unit test is performed manually and requires the
%   user to load the DICOM files into MIM and verify that no errors are
%   produced, and that the dose and structures are linked to the plan (no
%   missing reference messages appear when loading).
%
% RELEVANT REQUIREMENTS: F023,F024,F025,F026,F027
%
% INPUT DATA: DICOM file exported from Test07

% Log test
Event('Executing unit test 8', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'DICOM Files Import into MIM');

% Store test requirements
testCase.StoreResults('requirements', 'F023,F024,F025,F026,F027');

% Prompt user to verify that the TCS display works
prompt = questdlg(['For this test, the user needs to import the exported', ...
    'DICOM files into MIM. Do all files load successfully, without error', ...
    'and are displayed correctly?'], 'Unit Test', 'Yes', 'No', 'Yes');
testCase.verifyEqual(prompt, 'Yes');
if isequal(prompt, 'Yes')
    testCase.StoreResults('results', 'Pass');
else
    testCase.StoreResults('results', 'Fail');
end