function CloseFigure(testCase)
% CloseFigure is called during unit test method teardown and closes the
% application figure as well as any message boxes.
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

% Log action
if exist('Event', 'file') == 2
    Event('Closing figure handle', 'UNIT');
end

% If a figure object is still visible, close it
if ~isempty(testCase.figure) && isgraphics(testCase.figure, 'figure')
    close(testCase.figure)
end

% Close all displayed message boxes
delete(findobj(allchild(0), '-regexp', 'Tag', '^Msgbox_'))