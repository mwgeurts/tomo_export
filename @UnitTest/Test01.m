function Test01(testCase)
% UNIT TEST 1: Application Loads Successfully and on Time
%
% DESCRIPTION: This unit test attempts to execute the main application
%   executable.  This test also verifies that errors are present if the 
%   required submodules do not exist and that the DICOM export button is 
%   initially disabled. It also measures the time to open.
%
% RELEVANT REQUIREMENTS: U001,F001,F017,P001
%
% INPUT DATA: No input data required
%
% CONDITION A (+): With the appropriate submodules present, opening the
%   application loads without error
%
% CONDITION B (-): With the tomo_extract submodule missing, opening the 
%   application throws an error
%
% CONDITION C (-): With the dicom_tools submodule missing, opening the 
%   application throws an error
%
% CONDITION D (-): With the tcs_plots submodule missing, opening the 
%   application throws an error
%
% CONDITION E (-): The Export DICOM button is disabled following 
%   application load (the positive condition for this requirement
%   is tested during unit test 5).
%
% CONDITION F (+): The application loads in less than 2 seconds

% Log test
Event('Executing unit test 1', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'Application Load');

% Store test requirements
testCase.StoreResults('requirements', 'U001,F001,F017,P001');

%% CONDITION B
movefile tomo_extract tomo_extract_test
try
    testCase.figure = testCase.executable();
    testCase.verifyFalse(isgraphics(testCase.figure, 'figure'));
catch err
    testCase.verifyInstanceOf(err, 'MException')
end
movefile tomo_extract_test tomo_extract

%% CONDITION C
movefile dicom_tools dicom_tools_test
try
    testCase.figure = testCase.executable();
    testCase.verifyFalse(isgraphics(testCase.figure, 'figure'));
catch err
    testCase.verifyInstanceOf(err, 'MException')
end
movefile dicom_tools_test dicom_tools

%% CONDITION D
movefile tcs_plots tcs_plots_test
try
    testCase.figure = testCase.executable();
    testCase.verifyFalse(isgraphics(testCase.figure, 'figure'));
catch err
    testCase.verifyInstanceOf(err, 'MException')
end
movefile tcs_plots_test tcs_plots

%% CONDITIONS A, F
pause(2);
t = tic;
testCase.figure = testCase.executable();
time = toc(t);
testCase.StoreResults('results', sprintf('%0.1f sec', time));
testCase.verifyInstanceOf(testCase.figure, 'matlab.ui.Figure');
testCase.verifyLessThan(time, 2);

%% CONDITION E
handles = guidata(testCase.figure);
testCase.verifyEqual(lower(get(handles.dicom_button, 'Enable')), 'off');