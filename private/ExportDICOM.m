function handles = ExportDICOM(handles)
% ExportDICOM is called by TomoExport when the DICOM Export button is
% pressed, and prompts the user to select a folder to save the files to.
% Once selected, this function will call several functions in the 
% dicom_tools submodule to write the CT, Plan, Structures, and Dose images
% to the folder.
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
if  ~isfield(handles.config, 'UNIT_FLAG') || ...
        str2double(handles.config.UNIT_FLAG) == 0

    % Prompt user to select save location
    Event('UI window opened to select save folder location');
    path = uigetdir(handles.userpath, ...
        'Select Directory to Save DICOM Data');
else
    
    % Log unit test
    Event('Retrieving stored name and path variables', 'UNIT');
    path = handles.config.UNIT_EXPORT_PATH;
end

% If the user chose a directory
if ~isequal(path, 0) && isdir(path)
    
    % Start waitbar
    progress = waitbar(0, 'Initializing DICOM Export');
    
    % Update default path and log folder
    handles.userpath = path;
    Event(['DICOM files will be saved to ', path]);
    
    % Generate patient folder name from patient name
    patientDir = regexprep(handles.plan.patientName, '[ \W]', '_');
    
    % Generate plan folder name from plan label
    planDir = regexprep(handles.plan.planLabel, '[ \W]', '_');
    
    % Make patient/plan folders unless they already exist
    if ~isdir(fullfile(path, patientDir, planDir))
        mkdir(fullfile(path, patientDir, planDir));
    end 
    
    % Store series and study descriptions
    handles.plan.seriesDescription = handles.config.PLAN_DESCRIPTION;
    Event(['DICOM series description set to ', ...
        handles.plan.seriesDescription]);
    handles.plan.studyDescription = handles.plan.planLabel;
    Event(['DICOM series description set to ', ...
        handles.plan.studyDescription]);
    
    % Store patient position from image
    handles.plan.position = handles.image.position;
    
     % Generate unique series/study UIDs
    Event('Generating unique series/study UIDs');
    
    % Generate study and series UIDs
    handles.plan.studyUID = dicomuid;
    handles.plan.seriesUID = dicomuid;

    % Generate unique FOR instance UID
    Event('Generating unique FOR UID');
    handles.plan.frameRefUID = dicomuid;
    
    %% Export CT
    % If the user provided a file location
    if isfield(handles, 'image')

        % Update progress bar
        waitbar(0.1, progress, 'Exporting DICOM CT');
        
        % Make CT folder unless it already exists
        if ~isdir(fullfile(path, patientDir, planDir, 'CT'))
            mkdir(fullfile(path, patientDir, planDir, 'CT'));
        end 
        
        % Write images to file, storing image UIDs
        handles.plan.instanceUIDs = WriteDICOMImage(handles.image, ...
            fullfile(path, patientDir, planDir, 'CT', 'CT'), handles.plan);
        
    % Otherwise no file was selected
    else
        Event('DICOM CT not saved as CT data not is present', 'WARN');
    end

    %% Export RTSS
    % If the user provided a file location
    if isfield(handles, 'image') && isfield(handles.image, 'structures')

        % Update progress bar
        waitbar(0.4, progress, 'Exporting DICOM RT Structure Set');

        % Make structure set folder unless it already exists
        if ~isdir(fullfile(path, patientDir, planDir, 'RTStruct'))
            mkdir(fullfile(path, patientDir, planDir, 'RTStruct'));
        end 
        
        % Write structure set to file, storing UID
        handles.plan.structureSetUID = WriteDICOMStructures(...
            handles.image.structures, fullfile(path, patientDir, planDir, ...
            'RTStruct', 'RTStruct.dcm'), handles.plan);
        
    % Otherwise no file was selected
    else
        Event('DICOM RTSS not saved as RTSS data is not present', 'WARN');
    end
    
    %% Export Plan
    % If the user provided a file location
    if isfield(handles, 'plan')

        % Update progress bar
        waitbar(0.9, progress, 'Exporting DICOM RT Plan');
        
        % Make plan folder unless it already exists
        if ~isdir(fullfile(path, patientDir, planDir, 'RTPlan'))
            mkdir(fullfile(path, patientDir, planDir, 'RTPlan'));
        end 
        
        % Write plan to file, storing UID
        handles.plan.planUID = WriteDICOMTomoPlan(handles.plan, ...
            fullfile(path, patientDir, planDir, 'RTPlan', 'RTPlan.dcm'));
        
    % Otherwise no file was selected
    else
        Event('DICOM RT Plan not saved as plan data is not present', ...
            'WARN');
    end

    %% Export Dose
    % If the user provided a file location
    if isfield(handles, 'dose')

        % Update progress bar
        waitbar(0.7, progress, 'Exporting DICOM Dose');
        
        % Make dose folder unless it already exists
        if ~isdir(fullfile(path, patientDir, planDir, 'Dose'))
            mkdir(fullfile(path, patientDir, planDir, 'Dose'));
        end 
        
        % Write dose to file, storing UID
        handles.plan.doseUID = WriteDICOMDose(handles.dose, fullfile(path, ...
            patientDir, planDir, 'Dose', 'RTDose.dcm'), handles.plan);
        
    % Otherwise no file was selected
    else
        Event('DICOM Dose not saved as dose data is not present', 'WARN');
    end
 
    % Update waitbar
    waitbar(1.0, progress, 'DICOM export completed');

    % Close waitbar
    close(progress);
    
    % Display message box
    msgbox('DICOM export completed');
else
    Event('No directory was selected for export');
end

% Clear temporary variables
clear progress path;