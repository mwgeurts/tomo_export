function handles = InitializeUI(handles)
% InitializeUI is called by TomoExport when the interface is opened to set
% all UI fields.
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

% Set version UI text
set(handles.version_text, 'String', ...
    sprintf('Version %s', handles.version));

% Disable plan selection dropdown (Patient data must be loaded first)
set(handles.plan_select, 'String', 'Select Patient Plan');
set(handles.plan_select, 'Enable', 'off');

% Disable image viewer
set(allchild(handles.dose_axes), 'visible', 'off'); 
set(handles.dose_axes, 'visible', 'off');
colorbar(handles.dose_axes, 'off');

% Disable dose slider/TCS/alpha
set(handles.dose_slider, 'visible', 'off');
set(handles.tcs_button, 'visible', 'off');
set(handles.alpha, 'visible', 'off');

% Disable info table and export button (Patient data must be loaded first)
set(handles.dicom_button, 'Enable', 'off');
set(handles.plan_info, 'Enable', 'off');
set(handles.plan_info, 'Data', cell(13, 2));

% Set the default transparency
set(handles.alpha, 'String', sprintf('%0.0f%%', ...
    str2double(handles.config.DEFAULT_TRANSPARENCY) * 100));
Event(['Default dose view transparency set to ', ...
    get(handles.alpha, 'String')]);

% Set the initial TCS view
handles.tcsview = handles.config.DEFAULT_TCS_VIEW;
Event(['Default TCS orientation set to ', handles.tcsview]);

% Log  plan description prefix. This will be included in the DICOM Series
% Description flag along with the plan name.
Event(['DICOM series description set to ', ...
    handles.config.PLAN_DESCRIPTION]);

% Default folder path when selecting input files
if strcmpi(handles.config.DEFAULT_PATH, 'userpath')
    handles.userpath = userpath;
else
    handles.userpath = handles.config.DEFAULT_PATH;
end
Event(['Default file path set to ', handles.userpath]);