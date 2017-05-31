function Test11(testCase)
% UNIT TEST 11: Documentation Exists
%
% DESCRIPTION: This unit test checks that a README file is present.  The
% contents of the README are manually verified by the user.
%
% RELEVANT REQUIREMENTS: D001, D002 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): A file named README.md exists in the file directory.

% Log test
Event('Executing unit test 11', 'UNIT');

% Store test summary
testCase.testSummaries{11} = 'Documentation Exists';

% Store test requirements
testCase.testRequirements{11} = {'D001', 'D002'};

% Look for README.md
fid = fopen('README.md', 'r');

% If file handle was valid, record pass
testCase.verifyGreaterThan(fid, 2);

% Close file handle
fclose(fid);
