function Test03(testCase)
% UNIT TEST 3: Cumulative Cyclomatic Complexity
%
% DESCRIPTION: This unit test uses the cumulative cyclomatic complexity
%   for each function to determine the total application complexity
%
% RELEVANT REQUIREMENTS: P005
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report the cumulative cyclomatic complexity for all
%   functions called by TomoExport, verify it less than 1000

% Log test
Event('Executing unit test 3', 'UNIT');

% Store test summary
testCase.StoreResults('summary', 'Cumulative Cyclomatic Complexity');

% Store test requirements
testCase.StoreResults('requirements', 'P005');

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts(...
    [func2str(testCase.executable), '.m']);

% Initialize complexity counter
comp = 0;

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
        end 
    end
end

% Log result
Event(sprintf(['The resulting cumulative McCabe complexity for ', ...
    'this tool: %i'], comp), 'UNIT');

% Store the result
testCase.StoreResults('results', sprintf('%i', comp));

% Verify complexity is less than limit
testCase.verifyLessThan(comp, 1000);