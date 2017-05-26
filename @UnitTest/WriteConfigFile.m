function WriteConfigFile(filename, config)


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