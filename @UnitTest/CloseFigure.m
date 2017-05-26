function CloseFigure(testCase)

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