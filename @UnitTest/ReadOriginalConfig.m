function ReadOriginalConfig(testCase)


% Read in config file
testCase.config = testCase.ReadConfigFile(testCase.configFile);

% Log action
if exist('Event', 'file') == 2
    Event('Storing original configuration file contents', 'UNIT');
end

% Store original configuration options separately
testCase.configOriginal = testCase.config;