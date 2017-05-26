function handles = BrowsePatientArchive(handles)
% BrowsePatientArchive is called by TomoExport when the user clicks the
% browse button. It opens a file browser to allow the user to select the
% _patient.xml file, then executes SelectPlan on the first plan to load the 
% relevant archive components and update the UI. This function checks the
% database version of the archive to determine which functions to call when
% finding plans, and will throw an error if an unsupported version is 
% found.
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

% If not executing in unit test
if str2double(handles.config.UNIT_FLAG) == 0

    % Request the user to select the Daily QA DICOM or XML
    Event('UI window opened to select file');
    [handles.name, handles.path] = uigetfile({'*_patient.xml', ...
        'Patient Archive (*_patient.xml)'; '*.xml', ...
        'Legacy Archive (*.xml)'}, 'Select the Archive Patient XML File', ...
        handles.userpath);
    
else
    
    % Log unit test
    Event('Retrieving stored name and path variables', 'UNIT');
    handles.name = handles.config.UNIT_FILE_NAME;
    handles.path = handles.config.UNIT_FILE_PATH;
end
    
% If the user selected a file
if ~isequal(handles.name, 0)
    
    % Update default path
    handles.userpath = handles.path;
    Event(['Default file path updated to ', handles.path]);
    
    % Update archive_file text box
    set(handles.archive_file, 'String', ...
        fullfile(handles.path, handles.name));
       
    % Find plan build and database version
    [handles.build, handles.db] = FindVersion(handles.path, handles.name);
    
    % If the database version is after 6 (when Tomo moved to characters)
    if isletter(handles.db(1))
    
        % Retrieve all approved plan plan UIDs
        plans = FindPlans(handles.path, handles.name);
        handles.planUIDs = plans(:,1);
        
        % Update plan dropdown menu
        set(handles.plan_select, 'String', ...
            strcat(plans(:,1), ' (', plans(:,2), ')'));
        
        % If at least 1 plan was found
        if length(handles.planUIDs) >= 1
            
            % Update selected plan
            set(handles.plan_select, 'Value', 1);
            
            % Enable dropdown menu
            set(handles.plan_select, 'enable', 'on');
            
            % Execute plan_select
            handles = SelectPlan(handles, ...
                get(handles.plan_select, 'Value'));
        
        % Otherwise 
        else
            
            % Warn user no plans were found
            Event('No approved plans were found in the provided archive', ...
                'ERROR');
        end
        
        % Clear temporary variables
        clear plans;
        
    % Otherwise, if the database version is 2 or later
    elseif str2double(handles.db(1)) >= 2
        
        % Retrieve all approved plan plan UIDs
        handles.planUIDs = FindLegacyPlans(handles.path, handles.name);
        
        % Update plan dropdown menu
        set(handles.plan_select, 'String', handles.planUIDs);
        
        % If at least 1 plan was found
        if length(handles.planUIDs) >= 1
            
            % Update selected plan
            set(handles.plan_select, 'Value', 1);
            
            % Enable dropdown menu
            set(handles.plan_select, 'enable', 'on');
            
            % Execute plan_select
            handles = SelectPlan(handles, ...
                get(handles.plan_select, 'Value'));
        
        % Otherwise 
        else
            
            % Warn user no plans were found
            Event('No approved plans were found in the provided archive', ...
                'ERROR');
        end
        
    % Otherwise the file version is not supported   
    else
        
        % Log error
        Event(['Archive database version ', handles.db, ...
            ' is not supported'], 'ERROR');
    end
    
% Otherwise the user did not select a file
else
    Event('No archive file was selected');
end