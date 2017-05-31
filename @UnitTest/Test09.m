function Test09(testCase)
% UNIT TEST 9: DICOM Images Identical to TPS
%
% DESCRIPTION: This unit test compares the exported DICOM files to DICOM
%   files exported from the TPS, and compares them using the LoadDICOM*
%   functions of the dicom_tools submodule. The image, structure set, and
%   dose DICOM files are compared (plan is not as it is known to not
%   match). 
%
% RELEVANT REQUIREMENTS: F028, F029
%
% INPUT DATA: DICOM file exported from tool (testCase.exportPath), 
%   reference DICOM files(testCase.dicomData)
%
% CONDITION A (+): The exported DICOM CT patient name matches the reference
%
% CONDITION B (-): The exported DICOM CT patient name is not empty
%
% CONDITION C (+): The exported RTDose patient name matches the reference
%
% CONDITION D (-): The exported RTDose CT patient name is not empty
%
% CONDITION E (+): The exported DICOM CT patient ID matches the reference
%
% CONDITION F (-): The exported DICOM CT patient ID is not empty
%
% CONDITION G (+): The exported RTDose CT patient ID matches the reference
%
% CONDITION H (-): The exported RTDose CT patient ID is not empty
%
% CONDITION I (+): The exported DICOM CT image versus reference CT image 
%   RMS difference is less than 2 HU
%
% CONDITION J (+): The exported DICOM dose image versus reference CT dose 
%   RMS difference is less than 0.2 Gy
%
% CONDITION K (+): The exported DICOM RTSS structure names match the
%   reference
%
% CONDITION L (-): The exported DICOM RTSS structure names are not empty
%
% CONDITION M (+): The exported DICOM RTSS structure colors match the
%   reference
%
% CONDITION N (-): The exported DICOM RTSS structure colors are not empty
%
% CONDITION O (+): The exported DICOM RTSS binary mask versus reference
%   RTSS mask RMS difference is less than 0.1

% Log test
Event('Executing unit test 9', 'UNIT');

% Store test summary
testCase.testSummaries{9} = 'DICOM File RMS Difference';

% Store test requirements
testCase.testRequirements{9} = {'F028', 'F029'};

% Initialize array to store stats
stats = zeros(size(testCase.dicomData, 1), 3);

% Loop through reference DICOM data
for i = 1:size(testCase.inputData, 1)
    
    %% Export DICOM images
    Event(['Exporting DICOM images from ', testCase.inputData{i,2}], 'UNIT');
    
    % Separate into file parts
    [path, name, ext] = fileparts(fullfile(testCase.inputData{i,2}));
    
    % Set archive path/name
    testCase.config.UNIT_FLAG = '1';
    testCase.config.UNIT_PATH = path;
    testCase.config.UNIT_NAME = [name, ext];
    testCase.config.UNIT_EXPORT_PATH = testCase.exportPath;
    
    % Write config options
    testCase.WriteConfigFile(testCase.configFile, testCase.config);
    
    % Open application
    testCase.figure = testCase.executable();

    % Retrieve handles
    handles = guidata(testCase.figure);

    % Retrieve callback to archive browse button
    callback = get(handles.archive_browse, 'Callback');
    
    % Execute browse
    callback(handles.archive_browse, handles);
    
    % Retrieve handles
    handles = guidata(testCase.figure);
    
    % Retrieve callback to DICOM export button
    callback = get(handles.dicom_button, 'Callback');
    
    % Execute export
    callback(handles.dicom_button, handles);

    % Close file handle
    close(testCase.figure);
    
    %% Load DICOM images
    % Load reference DICOM data
    Event(['Loading reference DICOM data from ', ...
        testCase.dicomData{i,2}], 'UNIT');
    [ref.image, ref.dose] = ...
        testCase.LoadDICOMFiles(testCase.dicomData{i,2});
    
    % Load target DICOM data
    Event(['Loading target DICOM data from ', ...
        fullfile(testCase.exportPath, testCase.dicomData{i,1})], 'UNIT');
    [tar.image, tar.dose] = testCase.LoadDICOMFiles(fullfile(...
        testCase.exportPath, testCase.dicomData{i,1}));
    
    %% Interpolate reference image to target image coordinate system
    % Compute X, Y, and Z meshgrids for the reference image dataset 
    % positions using the start and width values, permuting X/Y
    [refXi, refYi, refZi] = meshgrid(single(ref.image.start(2) + ...
        ref.image.width(2) * (size(ref.image.data,2) - 1): ...
        -ref.image.width(2):ref.image.start(2)), ...
        single(ref.image.start(1):ref.image.width(1)...
        :ref.image.start(1) + ref.image.width(1)...
        * (size(ref.image.data,1) - 1)), ...
        single(ref.image.start(3):ref.image.width(3):...
        ref.image.start(3) + ref.image.width(3)...
        * (size(ref.image.data,3) - 1)));
    
    % Compute X, Y, and Z meshgrids for the reference dose dataset 
    % positions using the start and width values, permuting X/Y
    [refXd, refYd, refZd] = meshgrid(single(ref.dose.start(2) + ...
        ref.dose.width(2) * (size(ref.dose.data,2) - 1): ...
        -ref.dose.width(2):ref.dose.start(2)), ...
        single(ref.dose.start(1):ref.dose.width(1)...
        :ref.dose.start(1) + ref.dose.width(1)...
        * (size(ref.dose.data,1) - 1)), ...
        single(ref.dose.start(3):ref.dose.width(3):...
        ref.dose.start(3) + ref.dose.width(3)...
        * (size(ref.dose.data,3) - 1)));

    % Compute X, Y, and Z meshgrids for the target image dataset using
    % the start and width values, permuting X/Y
    [tarX, tarY, tarZ] = meshgrid(single(tar.image.start(2) + ...
        tar.image.width(2) * (size(tar.image.data,2) - 1): ...
        -tar.image.width(2):tar.image.start(2)), ...
        single(tar.image.start(1):tar.image.width(1):...
        tar.image.start(1) + tar.image.width(1) ...
        * (size(tar.image.data,1) - 1)), ...
        single(tar.image.start(3):tar.image.width(3):...
        tar.image.start(3) + tar.image.width(3) ...
        * (size(tar.image.data,3) - 1)));
    
    % Start try-catch block to safely test for CUDA functionality
    try
        % Clear and initialize GPU memory.  If CUDA is not enabled, or if the
        % Parallel Computing Toolbox is not installed, this will error, and the
        % function will automatically rever to CPU computation via the catch
        % statement
        gpuDevice(1);

        % Run GPU interp3 function to compute the reference image
        % values at the specified target coordinate points
        iref.image.data = gather(interp3(gpuArray(refXi), ...
            gpuArray(refYi), gpuArray(refZi), ...
            gpuArray(single(ref.image.data)), gpuArray(tarX), ...
            gpuArray(tarY), gpuArray(tarZ), 'linear', 0));
        
        % Run GPU interp3 function to compute the reference dose
        % values at the specified target coordinate points
        iref.dose.data = gather(interp3(gpuArray(refXd), ...
            gpuArray(refYd), gpuArray(refZd), ...
            gpuArray(single(ref.dose.data)), gpuArray(tarX), ...
            gpuArray(tarY), gpuArray(tarZ), 'linear', 0));

        % Loop through structures
        for j = 1:length(ref.image.structures)
            
            % Run GPU interp3 function to compute the reference structure
            % masks at the specified target coordinate points
            iref.structures{j}.mask = gather(interp3(gpuArray(refXi), ...
                gpuArray(refYi), gpuArray(refZi), ...
                gpuArray(single(ref.image.structures{j}.mask)), ...
                gpuArray(tarX), gpuArray(tarY), gpuArray(tarZ), 'linear', 0));
        end
        
    % If GPU fails, revert to CPU computation
    catch

        % Run CPU interp3 function to compute the reference image
        % values at the specified target coordinate points
        iref.image.data = interp3(refXi, refYi, refZi, ...
            single(ref.image.data), tarX, ...
            tarY, tarZ, '*linear', 0);
        
        % Run CPU interp3 function to compute the reference dose
        % values at the specified target coordinate points
        iref.dose.data = interp3(refXd, refYd, refZd, ...
            single(ref.dose.data), tarX, ...
            tarY, tarZ, '*linear', 0);
        
        % Loop through structures
        for j = 1:length(ref.image.structures)
            
            % If a mask exists for this structure
            if isfield(ref.image.structures{j}, 'mask')
                
                % Run CPU interp3 function to compute the reference 
                % structure masks at the specified target coordinate points
                iref.structures{j}.mask = interp3(refXi, refYi, refZi, ...
                    single(ref.image.structures{j}.mask), tarX, ...
                    tarY, tarZ, 'nearest', 0);
            
            % Otherwise, store an empty array
            else
                iref.structures{j}.mask = zeros(size(tarX));
            end
        end
    end

    %% Compare datasets
    % Verify name, patient ID match in image, dose volumes, and are not
    % empty
    testCase.verifyEqual(tar.image.patientName, ref.image.patientName);
    testCase.verifyNotEqual(tar.image.patientName, '');
    testCase.verifyEqual(tar.dose.patientName, ref.dose.patientName);
    testCase.verifyNotEqual(tar.dose.patientName, '');
    testCase.verifyEqual(tar.image.patientID, ref.image.patientID);
    testCase.verifyNotEqual(tar.image.patientID, '');
    testCase.verifyEqual(tar.dose.patientID, ref.dose.patientID);
    testCase.verifyNotEqual(tar.dose.patientID, '');
    
    % Compute image difference
    diff = (tar.image.data - iref.image.data) .* (iref.image.data > 0);
    rms = sqrt(mean(diff(~isnan(diff)) .^ 2));
    testCase.verifyLessThan(rms, 2.0);
    stats(i,1) = rms;
    
    % Compute dose difference
    diff = (tar.dose.data - iref.dose.data) .* (iref.dose.data > 0);
    rms = sqrt(mean(diff(~isnan(diff)) .^ 2));
    testCase.verifyLessThan(rms, 0.01);
    stats(i,2) = rms;
    
    % Loop through structures
    for j = 1:length(ref.image.structures)

        % If structure is missing color or points, skip
        if ~isfield(ref.image.structures{j}, 'color') || ...
                ~isfield(ref.image.structures{j}, 'points')
            continue;
        end
        
        % Verify structure names are equal
        testCase.verifyEqual(tar.image.structures{j}.name, ...
            ref.image.structures{j}.name);
        testCase.verifyNotEqual(tar.image.structures{j}.name, '');
        
        % Verify structure colors are equal
        testCase.verifyEqual(tar.image.structures{j}.color, ...
            ref.image.structures{j}.color);
        testCase.verifyNotEqual(tar.image.structures{j}.color, []);
        
        % Compute dose difference
        diff = (tar.image.structures{j}.mask - iref.structures{j}.mask);
        rms = sqrt(mean(diff(~isnan(diff)) .^ 2));
        testCase.verifyLessThan(rms, 0.2);
        stats(i,3) = stats(i,3) + rms;
    end
    stats(i,3) = stats(i,3) / length(ref.image.structures);
end

% Record average RMS values across all datasets
testCase.testResults{9}{1} = sprintf('%0.2f HU', mean(stats(:,1)));
testCase.testResults{9}{2} = sprintf('%0.2f Gy', mean(stats(:,2)));
testCase.testResults{9}{3} = sprintf('%0.2f voxels', mean(stats(:,3)));