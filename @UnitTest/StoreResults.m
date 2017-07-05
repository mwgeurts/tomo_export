function varargout = StoreResults(varargin)
% StoreResults is used to temporarily store and retrieve unit test results.
% The results are stored to temporary files, and can be retrieved by
% calling this function with an output argument. The first input argument
% indicates the type of result, and can be 'summary', 'requirements', or
% 'results'. The second input argument should contain the string to be
% stored. The output argument contains a cell array of strings.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
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

% Declare persistent variables
persistent summaryFile requirementsFile resultsFile;

% If persistent variables are not yet set, or reset flag is provided
if ~exist('summaryFile', 'var') || isempty(summaryFile) || ...
        (nargin == 1 && strcmp(varargin{1}, 'clear')) 
    
    % Create temporary file names
    summaryFile = tempname;
    requirementsFile = tempname;
    resultsFile = tempname;
    
    % Create empty temporary files
    fid = fopen(summaryFile, 'w');
    fclose(fid);
    fid = fopen(requirementsFile, 'w');
    fclose(fid);
    fid = fopen(resultsFile, 'w');
    fclose(fid);
    
    % Clear temporary files
    clear fid;
end

% Write message to file, depending on type
if nargin == 2 
   
    % Execute switch statement on first variable
    switch varargin{1}
        
        % Write to summary file
        case 'summary'
        
            % Append second variable
            fid = fopen(summaryFile, 'a');
            fprintf(fid, '%s\n', varargin{2});
            fclose(fid);
            
        % Write to requirements file
        case 'requirements'
            
            % Append second variable
            fid = fopen(requirementsFile, 'a');
            fprintf(fid, '%s\n', varargin{2});
            fclose(fid);
            
        % Write to results file  
        case 'results'
            
            % Append second variable
            fid = fopen(resultsFile, 'a');
            fprintf(fid, '%s\n', varargin{2});
            fclose(fid);
    end
    
    % Clear temporary files
    clear fid;
end

% If a return variable is specified
if nargout == 1 && nargin >= 1
    
    % Execute switch statement on first variable
    switch varargin{1}
        
        % Read in summary file
        case 'summary'
            varargout{1} = strsplit(fileread(summaryFile), '\n');
            
        % Write to requirements file
        case 'requirements'
            varargout{1} = strsplit(fileread(requirementsFile), '\n');
            
        % Write to results file  
        case 'results'
            varargout{1} = strsplit(fileread(resultsFile), '\n');
    end
end