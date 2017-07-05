function Test02(testCase)
% UNIT TEST 2: Code Analyzer Messages
%
% DESCRIPTION: This unit test uses the checkcode() MATLAB function to check
%   each function used by the application and return any Code Analyzer
%   messages that result.
%
% RELEVANT REQUIREMENTS: P004
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report any code analyzer messages for all functions
%   called by TomoExport, verify no messages are found

% Log test
Event('Executing unit test 2', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'Code Analyzer Messages');

% Store test requirements
testCase.StoreResults('requirements', 'P004');

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts(...
    [func2str(testCase.executable), '.m']);

% Initialize messages counter
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
        if isempty(c)
            
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

% Log result
Event(sprintf('Number of code analyzer messages found: %i', mess), 'UNIT');

% Store the result
testCase.StoreResults('results', sprintf('%i', mess));

% Verify message counter is zero
testCase.verifyEqual(mess, 0);