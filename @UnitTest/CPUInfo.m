function info = CPUInfo()
%CPUINFO  read CPU configuration
%
%   info = CPUINFO() returns a structure containing various bits of
%   information about the CPU and operating system as provided by /proc/cpu
%   (Unix), sysctl (Mac) or WMIC (Windows). This information includes:
%     * CPU name
%     * CPU clock speed
%     * Number of physical CPU cores
%     * Operating system name & version
%
%   See also: COMPUTER, ISUNIX, ISMAC

%   Author: Ben Tordoff
%   Copyright 2011 The MathWorks, Inc.

if isunix
    if ismac
        info = cpuInfoMac();
    else
        info = cpuInfoUnix();
    end
else
    info = cpuInfoWindows();
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = cpuInfoWindows()
sysInfo = callWMIC( 'cpu' );
osInfo = callWMIC( 'os' );

info = struct( ...
    'Name', sysInfo.Name, ...
    'Clock', [sysInfo.MaxClockSpeed,' MHz'], ...
    'NumProcessors', str2double( sysInfo.NumberOfCores ), ...
    'OSType', 'Windows', ...
    'OSVersion', osInfo.Caption );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = callWMIC( alias )
% Call the MS-DOS WMIC (Windows Management) command
olddir = pwd();
cd( tempdir );
sysinfo = evalc( sprintf( '!wmic %s get /value', alias ) );
cd( olddir );
fields = textscan( sysinfo, '%s', 'Delimiter', '\n' ); 
fields = fields{1};
fields( cellfun( 'isempty', fields ) ) = [];
% Each line has "field=value", so split them
values = cell( size( fields ) );
for ff=1:numel( fields )
    idx = find( fields{ff}=='=', 1, 'first' );
    if ~isempty( idx ) && idx>1
        values{ff} = strtrim( fields{ff}(idx+1:end) );
        fields{ff} = strtrim( fields{ff}(1:idx-1) );
    end
end

% Remove any duplicates (only occurs for dual-socket PC's and we will
% assume that all sockets have the same processors in them).
numResults = sum( strcmpi( fields, fields{1} ) );
if numResults>1
    % If we are counting cores, sum them.
    numCoresEntries = find( strcmpi( fields, 'NumberOfCores' ) );
    if ~isempty( numCoresEntries )
        cores = cellfun( @str2double, values(numCoresEntries) );
        values(numCoresEntries) = {num2str( sum( cores ) )};
    end
    % Now remove the duplicate results
    [fields,idx] = unique(fields,'first');
    values = values(idx);
end

% Convert to a structure
info = cell2struct( values, fields );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = cpuInfoMac()
machdep = callSysCtl( 'machdep.cpu' );
hw = callSysCtl( 'hw' );
info = struct( ...
    'Name', machdep.brand_string, ...
    'Clock', [num2str(str2double(hw.cpufrequency_max)/1e6),' MHz'], ...
    'NumProcessors', str2double( machdep.core_count ), ...
    'OSType', 'Mac OS X', ...
    'OSVersion', getOSXVersion() );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = callSysCtl( namespace )
infostr = evalc( sprintf( '!sysctl -a %s', namespace ) );
% Remove the prefix
infostr = strrep( infostr, [namespace,'.'], '' );
% Now break into a structure
infostr = textscan( infostr, '%s', 'delimiter', '\n' );
infostr = infostr{1};
info = struct();
for ii=1:numel( infostr )
    colonIdx = find( infostr{ii}==':', 1, 'first' );
    if isempty( colonIdx ) || colonIdx==1 || colonIdx==length(infostr{ii})
        continue
    end
    prefix = infostr{ii}(1:colonIdx-1);
    value = strtrim(infostr{ii}(colonIdx+1:end));
    while ismember( '.', prefix )
        dotIndex = find( prefix=='.', 1, 'last' );
        suffix = prefix(dotIndex+1:end);
        prefix = prefix(1:dotIndex-1);
        value = struct( suffix, value );
    end
    info.(prefix) = value;
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vernum = getOSXVersion()
% Extract the OS version number from the system software version output.
ver = evalc('system(''sw_vers'')');
vernum = ...
    regexp(ver, 'ProductVersion:\s([1234567890.]*)', 'tokens', 'once');
vernum = strtrim(vernum{1});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = cpuInfoUnix()
txt = readCPUInfo();
cpuinfo = parseCPUInfoText( txt );

txt = readOSInfo();
osinfo = parseOSInfoText( txt );

% Merge the structures
info = cell2struct( [struct2cell( cpuinfo );struct2cell( osinfo )], ...
    [fieldnames( cpuinfo );fieldnames( osinfo )] );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = parseCPUInfoText( txt )
% Now parse the fields
lookup = {
    'model name', 'Name'
    'cpu Mhz', 'Clock'
    'cpu cores', 'NumProcessors'
    };
info = struct( ...
    'Name', {''}, ...
    'Clock', {''});
for ii=1:numel( txt )
    if isempty( txt{ii} )
        continue;
    end
    % Look for the colon that separates the property name from the value
    colon = find( txt{ii}==':', 1, 'first' );
    if isempty( colon ) || colon==1 || colon==length( txt{ii} )
        continue;
    end
    fieldName = strtrim( txt{ii}(1:colon-1) );
    fieldValue = strtrim( txt{ii}(colon+1:end) );
    if isempty( fieldName ) || isempty( fieldValue )
        continue;
    end
    
    % Is it one of the fields we're interested in?
    idx = find( strcmpi( lookup(:,1), fieldName ) );
    if ~isempty( idx )
        newName = lookup{idx,2};
        info.(newName) = fieldValue;
    end
end

% Convert clock speed
info.Clock = [info.Clock, ' MHz'];

% Convert num cores
info.NumProcessors = str2double( info.NumProcessors );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info = parseOSInfoText( txt )
info = struct( ...
    'OSType', 'Linux', ...
    'OSVersion', '' );
% find the string "linux version" then look for the bit in brackets
[~,b] = regexp( txt, '[^\(]*\(([^\)]*)\).*', 'match', 'tokens', 'once' );
info.OSVersion = b{1}{1};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = readCPUInfo()

fid = fopen( '/proc/cpuinfo', 'rt' );
if fid<0
    error( 'cpuinfo:BadPROCCPUInfo', ...
        'Could not open /proc/cpuinfo for reading' );
end
out = onCleanup( @() fclose( fid ) );

txt = textscan( fid, '%s', 'Delimiter', '\n' );
txt = txt{1};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = readOSInfo()

fid = fopen( '/proc/version', 'rt' );
if fid<0
    error( 'cpuinfo:BadProcVersion', ...
        'Could not open /proc/version for reading' );
end
out = onCleanup( @() fclose( fid ) );

txt = textscan( fid, '%s', 'Delimiter', '\n' );
txt = txt{1};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sl = sloc(file)
%SLOC Counts number source lines of code.
%   SL = SLOC(FILE) returns the line count for FILE.  If there are multiple
%   functions in one file, subfunctions are not counted separately, but
%   rather together.
%
%   The following lines are not counted as a line of code:
%   (1) The "function" line
%   (2) A line that is continued from the previous line --> ...
%   (3) A comment line, a line that starts with --> % or a line that is
%       part of a block comment (   %{...%}   )
%   (4) A blank line
%   (5) An array or cell array line
%
%   Note: If more than one statement is on the line, it counts that as one
%   line of code.  For instance the following is considered to be one line 
%   of code:
%
%        minx = 32; maxx = 100;
%
%   Copyright 2004-2005 MathWorks, Inc.
%   Raymond S. Norris (rayn@mathworks.com)
%   $Revision: 1.4 $ $Date: 2006/03/08 19:50:30 $
%   Modified by Mark Geurts

% Check to see if the ".m" is missing from the M-file name
file = deblank(file);
if length(file)<3 || ~strcmp(file(end-1:end),'.m')
   file = [file '.m'];
end

% Open read handle to file
fid = fopen(file, 'r');

% If file handle is unavailable, return 0
if fid < 3
   sl = 0;
   return;
end

% Initialize variables
sl = 0;
previous_line = '-99999';
inblockcomment = false;

% Loop through file contents
while ~feof(fid)

    % Get the next line, stripping white characters
    m_line = strtrim(fgetl(fid));

    % The Profiler doesn't include the "function" line of a function, so
    % skip it.  Because nested functions may be indented, trim the front of
    % the line of code.  Since we are string trimming the line, we may as 
    % well check here if the resulting string it empty.  If any of the above
    % is true, just continue onto the next line.
    
    if strncmp(m_line,'function ', 9) || isempty(m_line)
        continue
    end

    % Check for block comments ( %{...%} )
    if length(m_line)>1 && strcmp(m_line(1:2),'%{')
        inblockcomment = true;
    elseif length(previous_line)>1 && strcmp(previous_line(1:2),'%}')
        inblockcomment = false;
    end

    % Check if comment line or if line continued from previous line
    if ~strcmp(m_line(1),'%') &&  ~strcmp(m_line(1),'''') && ...
             ~strcmp(m_line(1),']') && ~strcmp(m_line(1),'}') && ...
            ~(length(previous_line)>2 && ...
            strcmp(previous_line(end-2:end),'...') && ...
            ~strcmp(previous_line(1),'%')) && ...
            isempty(regexp(m_line(1), '[0-9]', 'once')) && ~inblockcomment
        sl = sl+1;
    end

    % Keep track of current line to see if the next line is a continuation
    % of the current
    previous_line = m_line;
end

% Close file handle
fclose(fid);

end