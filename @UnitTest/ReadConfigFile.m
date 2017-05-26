function config = ReadConfigFile(filename)

% Log action
if exist('Event', 'file') == 2
    Event('Reading configuration file contents', 'UNIT');
end

% Open file handle to config.txt file
fid = fopen(filename, 'r');

% Verify that file handle is valid
if fid < 3
    
    % If not, throw an error
    if exist('Event', 'file') == 2
        Event(['The config file ', filename, ' could not be opened'], ...
            'ERROR');
    else
        error(['The config file ', filename, ' could not be opened']);
    end
end

% Scan config file contents
c = textscan(fid, '%s', 'Delimiter', '=');

% Close file handle
fclose(fid);

% Loop through textscan array, separating key/value pairs into array
for i = 1:2:length(c{1})
    config.(strtrim(c{1}{i})) = strtrim(c{1}{i+1});
end

% Clear temporary variables
clear c i fid;