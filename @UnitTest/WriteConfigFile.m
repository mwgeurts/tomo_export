function WriteConfigFile(filename, config)
% WriteConfigFile writes a provided config structure of name/value pairs to
% a configuration text file where each pair is written on a new line
% separated by an equal sign.
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

% Open file handle to config.txt file
fid = fopen(filename, 'w');

% Verify that file handle is valid
if fid < 3
    
    % If not, throw an error
    Event(['The config file ', filename, ' could not be opened'], 'ERROR');
end

% Store config option names
n = fieldnames(config);

% Loop through config file option
for i = 1:length(n)
    
   % Write each option
   fprintf(fid, '%s%s=   %s\n', n{i}, repmat(' ', 30-length(n{i}), 1), ...
       config.(n{i}));
end

% Close file handle
fclose(fid);

% Clear temporary variables
clear i n fid;