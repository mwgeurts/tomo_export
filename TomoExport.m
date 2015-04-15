function varargout = TomoExport(varargin)
% The TomoTherapy Patient Archive DICOM Export Tool reads in a patient 
% archive and allows the user to view and export approved treatments plans 
% to DICOM CT, RTstruct, and RT Dose files for archival in PACS systems.
%
% TomoTherapy is a registered trademark of Accuray Incorporated. See the
% README for more information, including installation instructions.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2015 University of Wisconsin Board of Regents
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

% Last Modified by GUIDE v2.5 09-Apr-2015 20:21:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TomoExport_OpeningFcn, ...
                   'gui_OutputFcn',  @TomoExport_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TomoExport_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TomoExport (see VARARGIN)

% Turn off MATLAB warnings
warning('off','all');

% Choose default command line output for TomoExport
handles.output = hObject;

% Set version handle
handles.version = '1.0.2';

% Determine path of current application
[path, ~, ~] = fileparts(mfilename('fullpath'));

% Set current directory to location of this application
cd(path);

% Clear temporary variable
clear path;

% Set version information.  See LoadVersionInfo for more details.
handles.versionInfo = LoadVersionInfo;

% Store program and MATLAB/etc version information as a string cell array
string = {'TomoTherapy Patient Archive Export Tool'
    sprintf('Version: %s (%s)', handles.version, handles.versionInfo{6});
    sprintf('Author: Mark Geurts <mark.w.geurts@gmail.com>');
    sprintf('MATLAB Version: %s', handles.versionInfo{2});
    sprintf('MATLAB License Number: %s', handles.versionInfo{3});
    sprintf('Operating System: %s', handles.versionInfo{1});
    sprintf('CUDA: %s', handles.versionInfo{4});
    sprintf('Java Version: %s', handles.versionInfo{5})
};

% Add dashed line separators      
separator = repmat('-', 1,  size(char(string), 2));
string = sprintf('%s\n', separator, string{:}, separator);

% Log information
Event(string, 'INIT');

%% Add Tomo archive extraction tools submodule
% Add archive extraction tools submodule to search path
addpath('./tomo_extract');

% Check if MATLAB can find CalcDose
if exist('FindPlans', 'file') ~= 2
    
    % If not, throw an error
    Event(['The Archive Extraction Tools submodule does not exist in the ', ...
        'search path. Use git clone --recursive or git submodule init ', ...
        'followed by git submodule update to fetch all submodules'], ...
        'ERROR');
end

%% Add DICOM tools submodule
% Add DICOM tools submodule to search path
addpath('./dicom_tools');

% Check if MATLAB can find LoadDICOMImages
if exist('WriteDICOMDose', 'file') ~= 2
    
    % If not, throw an error
    Event(['The DICOM Tools submodule does not exist in the ', ...
        'search path. Use git clone --recursive or git submodule init ', ...
        'followed by git submodule update to fetch all submodules'], ...
        'ERROR');
end

%% Initialize UI
% Set version UI text
set(handles.version_text, 'String', sprintf('Version %s', handles.version));

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
set(handles.plan_info, 'Data', cell(14, 2));

%% Initialize global variables
% Prefix for series description in written DICOM files. This prefix will be
% followed by the plan name.
handles.descriptionPrefix = 'TomoTherapy Plan: ';

% Default folder path when selecting input files
handles.userpath = userpath;
Event(['Default file path set to ', handles.userpath]);

% Initialize unit test flag to false (don't run in Unit Test mode)
handles.unitflag = 0;

% Set the initial image view orientation to Transverse (T)
handles.tcsview = 'T';
Event('Default dose view set to Transverse');

% Set the default transparency
set(handles.alpha, 'String', '40%');
Event(['Default dose view transparency set to ', ...
    get(handles.alpha, 'String')]);

%% Complete initialization
% Report initilization status
Event(['Initialization completed successfully. Start by selecting a ', ...
    'patient archive.']);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = TomoExport_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archive_file_Callback(~, ~, ~) %#ok<*DEFNU>
% hObject    handle to archive_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archive_file_CreateFcn(hObject, ~, ~)
% hObject    handle to archive_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Edit controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archive_browse_Callback(hObject, ~, handles)
% hObject    handle to archive_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log event
Event('Archive browse button selected');

% Request the user to select the Daily QA DICOM or XML
Event('UI window opened to select file');
[handles.name, handles.path] = uigetfile({'*_patient.xml', ...
    'Patient Archive (*_patient.xml)'; '*.xml', ...
    'Legacy Archive (*.xml)'}, 'Select the Archive Patient XML File', ...
    handles.userpath);
    
% If the user selected a file
if ~isequal(handles.name, 0)
    
    % Update default path
    handles.userpath = handles.path;
    Event(['Default file path updated to ', handles.path]);
    
    % Update archive_file text box
    set(handles.archive_file, 'String', ...
        fullfile(handles.path, handles.name));
       
    % Find plan version
    handles.version = FindVersion(handles.path, handles.name);
    
    % If the version is 3.X or later
    if str2double(handles.version(1)) >= 3
    
        % Retrieve all approved plan plan UIDs
        handles.planUIDs = FindPlans(handles.path, handles.name);
        
        % Update plan dropdown menu
        set(handles.plan_select, 'String', handles.planUIDs);
        
        % If at least 1 plan was found
        if length(handles.planUIDs) >= 1
            
            % Update selected plan
            set(handles.plan_select, 'Value', 1);
            
            % Enable dropdown menu
            set(handles.plan_select, 'enable', 'on');
            
            % Execute plan_select
            handles = ...
                plan_select_Callback(handles.plan_select, '', handles);
        
        % Otherwise 
        else
            
            % Warn user no plans were found
            Event('No approved plans were found in the provided archive', ...
                'ERROR');
        end
        
    % If the version is 2.X
    elseif str2double(handles.version(1)) == 2
        
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
            handles = ...
                plan_select_Callback(handles.plan_select, '', handles);
        
        % Otherwise 
        else
            
            % Warn user no plans were found
            Event('No approved plans were found in the provided archive', ...
                'ERROR');
        end
        
    % Otherwise the file version is not supported   
    else
        
        % Log error
        Event(['Archive version ', handles.version, ' is not supported'], ...
                'ERROR');
    end
    
% Otherwise the user did not select a file
else
    Event('No archive file was selected');
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = plan_select_Callback(hObject, ~, handles)
% hObject    handle to plan_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log selected plan UID
Event(sprintf('Plan UID %s selected to load', ...
    handles.planUIDs{get(hObject, 'Value')}));

% Start waitbar
progress = waitbar(0, 'Loading CT Image');

% If the version is 3.X or later
if str2double(handles.version(1)) >= 3

    % Retrieve CT 
    handles.image = LoadImage(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadPlan(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadStructures(handles.path, handles.name, ...
        handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});

% If the version is 2.X
elseif str2double(handles.version(1)) == 2

    % Retrieve CT 
    handles.image = LoadLegacyImage(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadLegacyPlan(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadLegacyStructures(handles.path, ...
        handles.name, handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{get(hObject, 'Value')});
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

% Update plan information table
data = {    
    'Patient Name'      handles.plan.patientName
    'Patient ID'        handles.plan.patientID
    'Birth Date'        datestr(datenum(handles.plan.patientBirthDate, ...
                            'yyyymmdd'))
    'Gender'            handles.plan.patientSex
    'Plan Name'         handles.plan.planLabel
    'Plan Type'         handles.plan.planType
    'Plan Date/Time'    datestr(handles.plan.timestamp)
    'Patient Position'  handles.image.position

};
set(handles.plan_info, 'Data', data);
set(handles.plan_info, 'Enable', 'on');

% Initialize Dose Viewer
InitializeViewer(handles.dose_axes, handles.tcsview, ...
    sscanf(get(handles.alpha, 'String'), '%f%%')/100, handles.image, ...
    handles.dose, handles.dose_slider);

% Enable dose slider/TCS/alpha
set(handles.dose_slider, 'visible', 'on');
set(handles.tcs_button, 'visible', 'on');
set(handles.alpha, 'visible', 'on');

% Update waitbar
waitbar(1.0, progress, 'Plan load completed');

% Close waitbar
close(progress);

% Clear temporary variables
clear progress;

% Enable DICOM export button
set(handles.dicom_button, 'Enable', 'on');

% If called through the UI, and not another function
if nargout == 0
    
    % Update handles structure
    guidata(hObject, handles);
    
else
    
    % Otherwise return the modified handles
    varargout{1} = handles;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plan_select_CreateFcn(hObject, ~, ~)
% hObject    handle to plan_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dose_slider_Callback(hObject, ~, handles)
% hObject    handle to dose_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Round the current value to an integer value
set(hObject, 'Value', round(get(hObject, 'Value')));

% Log event
Event(sprintf('Dose viewer slice set to %i', get(hObject,'Value')));

% Update viewer with current slice and transparency value
UpdateViewer(get(hObject,'Value'), ...
    sscanf(get(handles.alpha, 'String'), '%f%%')/100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dose_slider_CreateFcn(hObject, ~, ~)
% hObject    handle to dose_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alpha_Callback(hObject, ~, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the string contains a '%', parse the value
if ~isempty(strfind(get(hObject, 'String'), '%'))
    value = sscanf(get(hObject, 'String'), '%f%%');
    
% Otherwise, attempt to parse the response as a number
else
    value = str2double(get(hObject, 'String'));
end

% Bound value to [0 100]
value = max(0, min(100, value));

% Log event
Event(sprintf('Dose transparency set to %0.0f%%', value));

% Update string with formatted value
set(hObject, 'String', sprintf('%0.0f%%', value));

% Update viewer with current slice and transparency value
UpdateViewer(get(handles.dose_slider,'Value'), value/100);

% Clear temporary variable
clear value;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alpha_CreateFcn(hObject, ~, ~)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Edit controls usually have a white background on Windows.
if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor', 'white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_button_Callback(hObject, ~, handles)
% hObject    handle to tcs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Based on current tcsview handle value
switch handles.tcsview
    
    % If current view is transverse
    case 'T'
        handles.tcsview = 'C';
        Event('Updating viewer to Coronal');
        
    % If current view is coronal
    case 'C'
        handles.tcsview = 'S';
        Event('Updating viewer to Sagittal');
        
    % If current view is sagittal
    case 'S'
        handles.tcsview = 'T';
        Event('Updating viewer to Transverse');
end

% Re-initialize image viewer with new T/C/S value
InitializeViewer(handles.dose_axes, handles.tcsview, ...
    sscanf(get(handles.alpha, 'String'), '%f%%')/100, handles.image, ...
    handles.dose, handles.dose_slider);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dicom_button_Callback(hObject, ~, handles)
% hObject    handle to dicom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log event
Event('DICOM export button selected');

% Prompt user to select save location
Event('UI window opened to select save folder location');
path = uigetdir(handles.userpath, 'Select Directory to Save DICOM Data');

% If the user chose a directory
if ~isequal(path, 0)
    
    % Start waitbar
    progress = waitbar(0, 'Exporting Plan to DICOM');
    
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
    
    % Create series description
    handles.image.seriesDescription = [handles.descriptionPrefix, ...
        handles.plan.planLabel];
    
    % Generate series and study UIDs
    handles.image.seriesUID = dicomuid;
    handles.image.studyUID = dicomuid;
    
    %% Export CT
    % If the user provided a file location
    if isfield(handles, 'image')

        % Update progress bar
        waitbar(0.1, progress, 'Exporting DICOM CT');
        
        % Make CT folder unless they already exist
        if ~isdir(fullfile(path, patientDir, planDir, 'CT'))
            mkdir(fullfile(path, patientDir, planDir, 'CT'));
        end 
        
        % Write images to file
        WriteDICOMImage(handles.image, fullfile(path, patientDir, planDir, ...
            'CT', 'CT'), handles.image);
        
    % Otherwise no file was selected
    else
        Event('DICOM CT not saved as CT data not is present', 'WARN');
    end

    %% Export RTSS
    % If the user provided a file location
    if isfield(handles, 'image') && isfield(handles.image, 'structures')

        % Update progress bar
        waitbar(0.4, progress, 'Exporting DICOM RT Structure Set');

        % Make RTStruct folder unless they already exist
        if ~isdir(fullfile(path, patientDir, planDir, 'RTStruct'))
            mkdir(fullfile(path, patientDir, planDir, 'RTStruct'));
        end 
        
        % Write dose to file
        WriteDICOMStructures(handles.image.structures, ...
            fullfile(path, patientDir, planDir, 'RTStruct', 'RTStruct.dcm'), ...
            handles.image);
        
    % Otherwise no file was selected
    else
        Event('DICOM RTSS not saved as RTSS data is not present', 'WARN');
    end

    %% Export Dose
    % If the user provided a file location
    if isfield(handles, 'dose')

        % Update progress bar
        waitbar(0.7, progress, 'Exporting DICOM Dose');
        
        % Make Dose folder unless they already exist
        if ~isdir(fullfile(path, patientDir, planDir, 'Dose'))
            mkdir(fullfile(path, patientDir, planDir, 'Dose'));
        end 
        
        % Write dose to file
        WriteDICOMDose(handles.dose, fullfile(path, patientDir, planDir, ...
            'Dose', 'RTDose.dcm'), handles.image);
        
    % Otherwise no file was selected
    else
        Event('DICOM Dose not saved as dose data is not present');
    end
 
    % Update waitbar
    waitbar(1.0, progress, 'DICOM export completed');

    % Close waitbar
    close(progress);
else
    Event('No directory was selected for export');
end

% Clear temporary variables
clear progress path;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figure1_SizeChangedFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set units to pixels
set(hObject,'Units','pixels') 

% Get table width
pos = get(handles.plan_info, 'Position') .* ...
    get(handles.uipanel3, 'Position') .* ...
    get(hObject, 'Position');

% Update column widths to scale to new table size
set(handles.plan_info, 'ColumnWidth', ...
    {floor(0.4*pos(3)) - 5 floor(0.6*pos(3))});

% Clear temporary variables
clear pos;
