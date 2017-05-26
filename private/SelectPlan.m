function handles = SelectPlan(handles, value)
% SelectPlan is called by TomoExport and BrowsePatientArchive and loads the
% relevant plan parameters using the tomo_extract submodule functions. This 
% function checks the database version of the archive to determine which 
% functions to call when loading plan data, and will throw an error if an 
% unsupported version is found.
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

% Start waitbar
progress = waitbar(0, 'Loading CT Image');

% If the database version is after 6 (when Tomo moved to characters)
if isletter(handles.db(1))

    % Retrieve CT 
    handles.image = LoadImage(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadPlan(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadStructures(handles.path, handles.name, ...
        handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{value});

% Otherwise, if the database version is 2 or later
elseif str2double(handles.db(1)) >= 2

    % Retrieve CT 
    handles.image = LoadLegacyImage(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadLegacyPlan(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadLegacyStructures(handles.path, ...
        handles.name, handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{value});
    
end

% Update progress bar
waitbar(0.8, progress, 'Updating Display');

% Fill in missing data
if ~isfield(handles.plan, 'patientBirthDate')
    handles.plan.patientBirthDate = '';
end
if ~isfield(handles.plan, 'patientSex')
    handles.plan.patientSex = '';
end
if ~isfield(handles.plan, 'machine')
    handles.plan.machine = '';
end
if ~isfield(handles.plan, 'approver')
    handles.plan.approver = '';
end
if isfield(handles.plan, 'frontField') && isfield(handles.plan, 'backField')
    width = sprintf('%0.3f cm', ...
        sum(abs([handles.plan.frontField, handles.plan.backField])));
else
    width = '';
end
if isfield(handles.plan, 'rxDose') && isfield(handles.plan, 'rxVolume') && ...
        isfield(handles.plan, 'fractions')
    prescription = sprintf('%0.1f%% to %0.1f Gy in %i fractions', ...
        handles.plan.rxVolume, handles.plan.rxDose, ...
        handles.plan.fractions);
else
    prescription = '';
end

% Update plan information table
data = {    
    'Patient Name'      handles.plan.patientName
    'Patient ID'        handles.plan.patientID
    'Birth Date'        datestr(datenum(handles.plan.patientBirthDate, ...
                            'yyyymmdd'))
    'Gender'            handles.plan.patientSex
    'Machine'           handles.plan.machine
    'Plan Name'         handles.plan.planLabel
    'Plan Type'         handles.plan.planType
    'Plan Date/Time'    datestr(handles.plan.timestamp)
    'Approver'          handles.plan.approver
    'Patient Position'  handles.image.position
    'Prescription'      prescription
    'Field Size'        width           
    'Software Build'    handles.build
};
set(handles.plan_info, 'Data', data);
set(handles.plan_info, 'Enable', 'on');

% Delete any existing TCS viewer
if isfield(handles, 'tcsplot')
    delete(handles.tcsplot);
end
   
% Initialize Dose Viewer
handles.tcsplot = ImageViewer('axis', handles.dose_axes, ...
    'tcsview', handles.tcsview, 'background', handles.image, ...
    'overlay', handles.dose, 'alpha', ...
    sscanf(get(handles.alpha, 'String'), '%f%%')/100, ...
    'structures', handles.image.structures, ...
    'slider', handles.dose_slider, 'cbar', 'on', 'pixelval', 'off');

% Enable TCS/alpha inputs
set(handles.tcs_button, 'visible', 'on');
set(handles.alpha, 'visible', 'on');

% Update waitbar
waitbar(1.0, progress, 'Plan load completed');

% Close waitbar
close(progress);

% Clear temporary variables
clear progress i prescription width;

% Enable DICOM export button
set(handles.dicom_button, 'Enable', 'on');