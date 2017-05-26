function RestoreOriginalConfig(testCase)

% Log completion
if exist('Event', 'file') == 2
    Event('Restoring original configuration file contents', 'UNIT');
end

testCase.config = testCase.configOriginal;

testCase.WriteConfigFile(testCase.configFile, testCase.config);

