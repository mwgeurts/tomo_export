function varargout = UnitTest_old(varargin)
% UnitTest executes the unit tests for this application, and can be called 
% either independently (when testing just the latest version) or via 
% UnitTestHarness (when testing for regressions between versions).  Either 
% two or three input arguments can be passed to UnitTest as described 
% below.
%
% The following variables are required for proper execution: 
%   varargin{1}: string containing the path to the main function
%   varargin{2}: string containing the path to the test data
%   varargin{3} (optional): structure containing reference data to be used
%       for comparison.  If not provided, it is assumed that this version
%       is the reference and therefore all comparison tests will "Pass".
%
% The following variables are returned upon succesful completion when input 
% arguments are provided:
%   varargout{1}: cell array of strings containing preamble text that
%       summarizes the test, where each cell is a line. This text will
%       precede the results table in the report.
%   varargout{2}: n x 3 cell array of strings containing the test ID in
%       the first column, name in the second, and result (Pass/Fail or 
%       numerical values typically) of the test in the third.
%   varargout{3}: cell array of strings containing footnotes referenced by
%       the tests, where each cell is a line.  This text will follow the
%       results table in the report.
%   varargout{4} (optional): structure containing reference data created by 
%       executing this version.  This structure can be passed back into 
%       subsequent executions of UnitTest as varargin{3} to compare results
%       between versions (or to a priori validated reference data).
%
% The following variables are returned when no input arguments are
% provided (required only if called by UnitTestHarness):
%   varargout{1}: string containing the application name (with .m 
%       extension)
%   varargout{2}: string containing the path to the version application 
%       whose results will be used as reference
%   varargout{3}: 1 x n cell array of strings containing paths to the other 
%       applications which will be tested
%   varargout{4}: 2 x m cell array of strings containing the name of each 
%       test suite (first column) and path to the test data (second column)
%   varargout{5}: string containing the path and name of report file (will 
%       be appended by _R201XX.md based on the MATLAB version)
%
% Below is an example of how this function is used:
%
%   % Declare path to application and test suite
%   app = '/path/to/application';
%   test = '/path/to/test/data/';
%
%   % Load reference data from .mat file
%   load('referencedata.mat', '-mat', reference);
%
%   % Execute unit test, printing the test results to stdout
%   UnitTest(app, test, reference);
%
%   % Execute unit test, storing the test results
%   [preamble, table, footnotes] = UnitTest(app, test, reference);
%
%   % Execute unit test again but without reference data, this time storing 
%   % the output from UnitTest as a new reference file
%   [preamble, table, footnotes, newreference] = UnitTest(app, test);
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2015 University of Wisconsin Board of Regents
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

%% Return Application Information
% If UnitTest was executed without input arguments
if nargin == 0
    
    % Declare the application filename
    varargout{1} = 'TomoExport.m';

    % Declare current version directory
    varargout{2} = './';

    % Declare prior version directories
    varargout{3} = {
        '../tomo_export-1.0'
        '../tomo_export-1.0.5'
        '../tomo_export-1.1.0'
    };

    % Declare location of test data. Column 1 is the name of the 
    % test suite, column 2 is the absolute path to the file(s)
    varargout{4} = {
        'DB v2'                 '../test_data/DBv2/Anon_0007.xml'
        'DB v6'                 '../test_data/DBv6/Anon_0002_patient.xml'
        'CoordinatedPlan'       '../test_data/CoordinatedPlan/Anon_0001_patient.xml'
        'EnhancedReportsFinal'  '../test_data/EnhancedReportsFinal/Anon_0003_patient.xml'
        'TPPlus1'               '../test_data/TPPlus1/Anon_0004_patient.xml'
        'TPPlus1 (Direct)'      '../test_data/TPPlus1 Direct/Anon_0005_patient.xml'
        'TPPlus1 (FFP)'         '../test_data/TPPlus1 FFP/Anon_0006_patient.xml'
    };

    % Declare name of report file (will be appended by _R201XX.md based on 
    % the MATLAB version)
    varargout{5} = '../test_reports/unit_test';
    
    % Return to invoking function
    return;
end

%% Initialize Unit Testing
% Initialize static test result text variables
pass = 'Pass';
fail = 'Fail';
unk = 'N/A'; %#ok<NASGU>

% Declare export folder
exportpath = '../test_reports/';

% Initialize preamble text
preamble = {
    '| Input Data | Value |'
    '|------------|-------|'
};

% Initialize results cell array
results = cell(0,3);

% Initialize footnotes cell array
footnotes = cell(0,1);

% Initialize reference structure
if nargin == 3
    reference = varargin{3};
else
    reference = struct;
end

%% TEST 1/2: Application Loads Successfully, Time
%
% DESCRIPTION: This unit test attempts to execute the main application
%   executable and times how long it takes.  This test also verifies that
%   errors are present if the required submodules do not exist and that the
%   print report button is initially disabled.
%
% RELEVANT REQUIREMENTS: U001, F001, P001, F017
%
% INPUT DATA: No input data required
%
% CONDITION A (+): With the appropriate submodules present, opening the
%   application andloads without error in the required time
%
% CONDITION B (-): With the tomo_extract submodule missing, opening the 
%   application throws an error
%
% CONDITION C (-): With the dicom_tools submodule missing, opening the 
%   application throws an error
%
% CONDITION D (-): The Export DICOM button is disabled following 
%   application load (the positive condition for this requirement
%   is tested during unit test 5).

% Change to directory of version being tested
cd(varargin{1});

% Start with fail
pf = fail;

% Attempt to open application without submodule
try
    TomoExport('unitFindPlans');

% If it fails to open, the test passed
catch
    pf = pass;
end

% Close all figures
close all force;

% Attempt to open application without submodule
try
    TomoExport('unitWriteDICOMDose');

% If it fails to open, the test passed
catch
    pf = pass;
end

% Close all figures
close all force;

% Open application again with submodule, this time storing figure handle
try
    t = tic;
    h = TomoExport;
    time = sprintf('%0.1f sec', toc(t));

% If it fails to open, the test failed  
catch
    pf = fail;
end

% Retrieve guidata
data = guidata(h);

% Set unit test flag to 1 (to avoid uigetfile/questdlg/user input)
data.unitflag = 1; 

% Compute numeric version (equal to major * 10000 + minor * 100 + bug)
c = regexp(data.version, '^([0-9]+)\.([0-9]+)\.*([0-9]*)', 'tokens');
version = str2double(c{1}{1})*10000 + str2double(c{1}{2})*100 + ...
    max(str2double(c{1}{3}),0);

% Add version to results
results{size(results,1)+1,1} = 'ID';
results{size(results,1),2} = 'Test Case';
results{size(results,1),3} = sprintf('Version&nbsp;%s', data.version);

% If version < 1.0.5, revert to pass (submodule unit test was not
% available)
if version < 010005
    pf = pass;
end

% Update guidata
guidata(h, data);


% Verify that the print button is disabled
if ~strcmp(get(data.dicom_button, 'enable'), 'off')
    pf = fail;
end

% Add application load result
results{size(results,1)+1,1} = '1';
results{size(results,1),2} = 'Application Loads Successfully';
results{size(results,1),3} = pf;

% Add application load time
results{size(results,1)+1,1} = '2';
results{size(results,1),2} = 'Application Load Time';
results{size(results,1),3} = time;

%% TEST 3/4: Code Analyzer Messages, Cumulative Cyclomatic Complexity
%
% DESCRIPTION: This unit test uses the checkcode() MATLAB function to check
%   each function used by the application and return any Code Analyzer
%   messages that result.  The cumulative cyclomatic complexity is also
%   computed for each function and summed to determine the total
%   application complexity.  Although this test does not reference any
%   particular requirements, it is used during development to help identify
%   high risk code.
%
% RELEVANT REQUIREMENTS: none 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report any code analyzer messages for all functions
%   called by FieldUniformity
%
% CONDITION B (+): Report the cumulative cyclomatic complexity for all
%   functions called by TomoExport

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts('TomoExport.m');

% Initialize complexity and messages counters
comp = 0;
mess = 0;

% Loop through each dependency
for i = 1:length(fList)
    
    % Execute checkcode
    inform = checkcode(fList{i}, '-cyc');
    
    % Loop through results
    for j = 1:length(inform)
       
        % Check for McCabe complexity output
        c = regexp(inform(j).message, ...
            '^The McCabe complexity .+ is ([0-9]+)\.$', 'tokens');
        
        % If regular expression was found
        if ~isempty(c)
            
            % Add complexity
            comp = comp + str2double(c{1});
            
        else
            
            % If not an invalid code message
            if ~strncmp(inform(j).message, 'Filename', 8)
                
                % Log message
                Event(sprintf('%s in %s', inform(j).message, fList{i}), ...
                    'CHCK');

                % Add as code analyzer message
                mess = mess + 1;
            end
        end
        
    end
end

% Add code analyzer messages counter to results
results{size(results,1)+1,1} = '3';
results{size(results,1),2} = 'Code Analyzer Messages';
results{size(results,1),3} = sprintf('%i', mess);

% Add complexity results
results{size(results,1)+1,1} = '4';
results{size(results,1),2} = 'Cumulative Cyclomatic Complexity';
results{size(results,1),3} = sprintf('%i', comp);

%% TEST 5/6: Archive Browse Loads Data Successfully/Load Time
%
% DESCRIPTION: This unit test verifies a callback exists for the archive 
%   browse button and executes it under unit test conditions (such that a 
%   file selection dialog box is skipped), simulating the process of a user
%   selecting input data.  The time necessary to load the file is also
%   checked.
%
% RELEVANT REQUIREMENTS: U002, U003, U004, U005, U006, F002, F003, F006, 
%   F016, F017, C012, C013, C014, C015, C016, P002
%
% INPUT DATA: Archive patient XML file (varargin{2})
%
% CONDITION A (+): The callback for the browse button can be executed
%   without error when a valid filename is provided
%
% CONDITION B (-): The callback will throw an error if an invalid filename
%   is provided
%
% CONDITION C (+): The callback will return without error when no filename
%   is provided
%
% CONDITION D (+): Upon file loading successfully, the DICOM Export button
%   is enabled

% Add gamma criteria to preamble
preamble{length(preamble)+1} = ['| Patient Archive | ', varargin{2}, ' |'];

% Retrieve guidata
data = guidata(h);
    
% Retrieve callback to archive browse button
callback = get(data.archive_browse, 'Callback');

% Set empty unit path/name
data.unitpath = 0;
data.unitname = 0;

% Store guidata
guidata(h, data);

% Execute callback in try/catch statement
try
    pf = pass;
    callback(data.archive_browse, data);

% If it errors, record fail
catch
    pf = fail;
end

% Set invalid unit path/name
data.unitpath = '/';
data.unitname = 'asd';

% Store guidata
guidata(h, data);

% Execute callback in try/catch statement (this should fail)
try
    callback(data.archive_browse, data);
    pf = fail;
    
% If it errors
catch
	% The test passed
end

% Set unit path/name
[path, name, ext] = fileparts(varargin{2});
data.unitpath = path;
data.unitname = [name, ext];

% Store guidata
guidata(h, data);

% Execute callback in try/catch statement
try
    t = tic;
    callback(data.archive_browse, data);

% If it errors, record fail
catch
    pf = fail;
end

% Record completion time
time = sprintf('%0.1f sec', toc(t));

% Retrieve guidata
data = guidata(h);

% Verify that the file name matches the input data
if strcmp(pf, pass) && strcmp(data.archive_file.String, ...
        fullfile(varargin{2}))
    pf = pass;
else
    pf = fail;
end

% Add result
results{size(results,1)+1,1} = '5';
results{size(results,1),2} = 'Browse Loads Data Successfully';
results{size(results,1),3} = pf;

% Add result
results{size(results,1)+1,1} = '6';
results{size(results,1),2} = 'Browse Callback Load Time';
results{size(results,1),3} = time;

%% TEST 7: CT/Structure/Dose Display Functionality
%
% DESCRIPTION: This is unit test is performed manually and requires the
%   user to compare the displayed CT, structures, and dose display to
%   verify the plan is successfully parsed. The user must also verify that
%   the transparency, axis, and slice selection UI features work
%   accordingly.
%
% RELEVANT REQUIREMENTS: U007, F008, F009, F010, F011, F012, F013, F014,
%   F015
%
% INPUT DATA: No input data required

% Add empty result for manual user input
results{size(results,1)+1,1} = '7';
results{size(results,1),2} = 'CT/Structure/Dose Viewer Functional';
results{size(results,1),3} = '';

%% TEST 8: Plan Data Correct
%
% DESCRIPTION: This unit test compares the parsed image, plan, structures,
%   and dose information and compares it to an expected value.
%
% RELEVANT REQUIREMENTS: U008, F016
%
% INPUT DATA: Expected image data (reference.image), structures
%   (reference.structures), dose (reference.dose), and plan 
%   (reference.plan) information
%
% CONDITION A (+): The extracted image data, start, and width arrays equal
%   the expected value
%
% CONDITION B (+): The extracted first structure name, color, and points
%   equal the expected value
%
% CONDITION C (+): The extracted dose data, start, and width arrays equal
%   the expected value
%
% CONDITION D (+): The extracted patient name, ID, birth date, sex, plan
%   label, and patient position equals the expected value

% Retrieve guidata
data = guidata(h);

% If reference data exists
if nargin == 3

    % Execute check in try/catch statement
    try
    
    % If image, structures, dose, and plan data equals the reference
    if isequal(data.image.width, reference.image.width) && ...
            isequal(data.image.start, reference.image.start) && ...
            isequal(data.image.data, reference.image.data) && ...
            isequal(data.dose.width, reference.dose.width) && ...
            isequal(data.dose.start, reference.dose.start) && ...
            isequal(data.dose.data, reference.dose.data) && ...
            isequal(data.image.structures{1}.name, ...
                reference.image.structures{1}.name) && ...
            isequal(data.image.structures{1}.points, ...
                reference.image.structures{1}.points) && ...
            isequal(data.image.structures{1}.color, ...
                reference.image.structures{1}.color) && ...
            isequal(data.plan.patientName, reference.plan.patientName) && ...
            isequal(data.plan.patientID, reference.plan.patientID) && ...
            isequal(data.plan.patientBirthDate, ...
                reference.plan.patientBirthDate) && ...
            isequal(data.plan.patientSex, reference.plan.patientSex) && ...
            isequal(data.plan.planLabel, reference.plan.planLabel) && ...
            isequal(data.image.position, reference.image.position)
        pf = pass;

    % Otherwise, the test fails
    else
        pf = fail;
    end
    
    % If it errors, record fail
    catch
        pf = fail;
    end

% Otherwise, no reference data exists
else

    % Set current value as reference
    reference.image = data.image;
    reference.dose = data.dose;
    reference.plan = data.plan;

    % Assume pass
    pf = pass;
end

% Add empty result for manual user input
results{size(results,1)+1,1} = '8';
results{size(results,1),2} = 'Plan Information Parsed Correctly';
results{size(results,1),3} = pf;

%% TEST 9/10: DICOM Export Writes Successfully/Write Time
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
% INPUT DATA: path to export DICOM images to (exportpath)
%
% CONDITION A (+): The callback for the DICOM Export button can be executed
%   without error when a valid folder is provided
%
% CONDITION B (-): The callback will return without error when no folder
%   is provided

% Retrieve guidata
data = guidata(h);
    
% Retrieve callback to archive browse button
callback = get(data.dicom_button, 'Callback');

% Set empty unit path/name
data.unitexportpath = 0;

% Store guidata
guidata(h, data);

% Execute callback in try/catch statement
try
    pf = pass;
    callback(data.dicom_button, data);

% If it errors, record fail
catch
    pf = fail;
end

% Set unit path
data.unitexportpath = exportpath;

% Store guidata
guidata(h, data);

% Execute callback in try/catch statement
try
    t = tic;
    callback(data.dicom_button, data);

% If it errors, record fail
catch
    pf = fail;
end

% Record completion time
time = sprintf('%0.1f sec', toc(t));

% Add result
results{size(results,1)+1,1} = '9';
results{size(results,1),2} = 'DICOM Export Writes Files Successfully';
results{size(results,1),3} = pf;

% Add result
results{size(results,1)+1,1} = '10';
results{size(results,1),2} = 'DICOM Export Write Time';
results{size(results,1),3} = time;

%% TEST 11: DICOM Files Import into MIM
% DESCRIPTION: This is unit test is performed manually and requires the
%   user to load the DICOM files into MIM and verify that no errors are
%   produced, and that the dose and structures are linked to the plan (no
%   missing reference messages appear when loading).
%
% RELEVANT REQUIREMENTS: F023, F024, F025, F026, F027
%
% INPUT DATA: No input data required

% Add empty result for manual user input
results{size(results,1)+1,1} = '11';
results{size(results,1),2} = 'DICOM Files Import into MIM';
results{size(results,1),3} = '';

%% TEST 12: DICOM Images Identical to TPS
% DESCRIPTION: This is unit test is performed manually and requires the
%   user to register the files to the same DICOM files exported from the
%   TomoTherapy planning station.  The registered images, structures,
%   isodose, and DVHs should be identical.
%
% RELEVANT REQUIREMENTS: F028, F029
%
% INPUT DATA: No input data required

% Add empty result for manual user input
results{size(results,1)+1,1} = '12';
results{size(results,1),2} = 'DICOM Files Identical to TPS';
results{size(results,1),3} = '';

%% TEST 13: Other plans load successfully
%
% DESCRIPTION: This is unit test verifies that the plan drop down menu
%   functions correctly and that each plan can be loaded successfully.
%
% RELEVANT REQUIREMENTS: U012, F004, F005, F007
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Upon selecting an entry in the plan drop down menu, the
%   selected plan is loaded without error
%
% CONDITION B (-): The plan drop down menu is not empty

% Retrieve guidata
data = guidata(h);
    
% Retrieve callback to plan selection dropdown
callback = get(data.plan_select, 'Callback');

% Execute callbacks in try/catch statement
try
    
    % Start with pass
    pf = pass;
    
    % Loop through each plan option
    for i = 1:length(data.plan_select.String)
        
        % Set value
        data.plan_select.Value = i;
        guidata(h, data);
        
        % Execute callback
        callback(data.plan_select, data);        
    end
    
% If callback fails, record failure    
catch
    pf = fail; 
end

% If no plans exist, the test fails
if isempty(data.plan_select.String)
    pf = fail;
end

% Add empty result for manual user input
results{size(results,1)+1,1} = '13';
results{size(results,1),2} = 'Plan Selection Menu Functions Correctly';
results{size(results,1),3} = pf;

%% TEST 14: Documentation Exists
%
% DESCRIPTION: This unit test checks that a README file is present.  The
% contents of the README are manually verified by the user.
%
% RELEVANT REQUIREMENTS: D001, D002 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): A file named README.md exists in the file directory.

% Look for README.md
fid = fopen('README.md', 'r');

% If file handle was valid, record pass
if fid >= 3
    pf = pass;
else
    pf = fail;
end

% Close file handle
fclose(fid);

% Add result
results{size(results,1)+1,1} = '14';
results{size(results,1),2} = 'Documentation Exists';
results{size(results,1),3} = pf;

%% Finish up
% Close all figures
close all force;

% If no return variables are present, print the results
if nargout == 0
    
    % Print preamble
    for j = 1:length(preamble)
        fprintf('%s\n', preamble{j});
    end
    fprintf('\n');
    
    % Loop through each table row
    for j = 1:size(results,1)
        
        % Print table row
        fprintf('| %s |\n', strjoin(results(j,:), ' | '));
       
        % If this is the first column
        if j == 1
            
            % Also print a separator row
            fprintf('|%s\n', repmat('----|', 1, size(results,2)));
        end

    end
    fprintf('\n');
    
    % Print footnotes
    for j = 1:length(footnotes) 
        fprintf('%s<br>\n', footnotes{j});
    end
    
% Otherwise, return the results as variables    
else

    % Store return variables
    if nargout >= 1; varargout{1} = preamble; end
    if nargout >= 2; varargout{2} = results; end
    if nargout >= 3; varargout{3} = footnotes; end
    if nargout >= 4; varargout{4} = reference; end
end