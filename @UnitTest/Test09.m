function Test09(testCase)
% UNIT TEST 9: DICOM Images Identical to TPS
%
% DESCRIPTION: This unit test compares the exported DICOM files to DICOM
%   files exported from the TPS, and compares them using the LoadDICOM*
%   functions of the dicom_tools submodule. The image, structure set, and
%   dose DICOM files are compared (plan is not as it is known to not match)
%
% RELEVANT REQUIREMENTS: F028, F029
%
% INPUT DATA: DICOM file exported from Test07 (testCase.exportPath), 
%   reference DICOM files(testCase.dicomData)
%
% CONDITION A (+): The exported DICOM CT file image data, image positions,
%   and orientation match the TPS
%
% CONDITION B (+): The exported DICOM RTSS file contour list matches the
%   TPS
%
% CONDITION C (+): The exported DICOM RTDOSE file image data and position 
%   matches the TPS

% Log test
Event('Executing unit test 9', 'UNIT');

% Store test summary
testCase.testSummaries{9} = 'DICOM Files Match TPS';

% Store test requirements
testCase.testRequirements{9} = {'U009', 'U010', 'U011', 'F018', 'F019', ...
    'F020', 'F021', 'F022', 'P003'};
 
% Loop through reference DICOM data
for i = 1:size(testCase.dicomData, 1)
    
    %% Load DICOM images
    % Load reference DICOM data
    [ref.image, ref.dose] = ...
        testCase.LoadDICOMFiles(testCase.dicomData{i,2});
    
    % Load target DICOM data
    [tar.image, tar.dose] = testCAse.LoadDICOMFiles(fullfile(...
        testCase.exportPath, testCase.dicomData{i,1}));
    
    %% Interpolate reference image to target image coordinate system
    % Compute X, Y, and Z meshgrids for the reference image dataset 
    % positions using the start and width values, permuting X/Y
    [refX, refY, refZ] = meshgrid(single(ref.image.start(2) + ...
        ref.image.width(2) * (size(ref.image.data,2) - 1): ...
        -ref.image.width(2):ref.image.start(2)), ...
        single(ref.image.start(1):ref.image.width(1)...
        :ref.image.start(1) + ref.image.width(1)...
        * (size(ref.image.data,1) - 1)), ...
        single(ref.image.start(3):ref.image.width(3):...
        ref.image.start(3) + ref.image.width(3)...
        * (size(ref.image.data,3) - 1)));

    % Compute X, Y, and Z meshgrids for the target dataset using
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
        iref.data = gather(interp3(gpuArray(refX), ...
            gpuArray(refY), gpuArray(refZ), ...
            gpuArray(single(ref.image.data)), gpuArray(tarX), ...
            gpuArray(tarY), gpuArray(tarZ), 'linear', 0));

    % If GPU fails, revert to CPU computation
    catch

        % Run CPU interp3 function to compute the reference image
        % values at the specified target coordinate points
        iref.data = interp3(refX, refY, refZ, ...
            single(ref.image.data), tarX, ...
            tarY, tarZ, '*linear', 0);
    end

    % Compute image difference
    diff = (tar.data - iref.data) ./ iref.data;
    rms = sqrt(mean(diff(~isnan(diff)) .^ 2));
    
    
    
end