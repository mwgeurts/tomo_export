function sl = SLOC(file)
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