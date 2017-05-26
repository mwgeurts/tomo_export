function [image, dose] = LoadDICOMFiles(path)

% Scan the directory for DICOM files
if exist('Event', 'file') == 2
    Event(['Scanning ', path, ' for DICOM files'], 'UNIT');
end

% Retrieve folder contents of selected directory
list = dir(path);

% Initialize folder counter
i = 0;

% Initialize list of DICOM files
imagefiles = cell(0);
rtssfiles = cell(0);
dosefiles = cell(0);

% Start recursive loop through each folder, subfolder
while i < length(list)

    % Increment current folder being analyzed
    i = i + 1;

    % If the folder content is . or .., skip to next folder in list
    if strcmp(list(i).name, '.') || strcmp(list(i).name, '..')
        continue

    % Otherwise, if the folder content is a subfolder    
    elseif list(i).isdir == 1

        % Retrieve the subfolder contents
        sublist = dir(fullfile(path, list(i).name));

        % Look through the subfolder contents
        for j = 1:size(sublist, 1)

            % If the subfolder content is . or .., skip to next subfolder 
            if strcmp(sublist(j).name, '.') || ...
                    strcmp(sublist(j).name, '..')
                continue
            else

                % Otherwise, replace the subfolder name with its full
                % reference
                sublist(j).name = fullfile(list(i).name, ...
                    sublist(j).name);
            end
        end

        % Append the subfolder contents to the main folder list
        list = vertcat(list, sublist); %#ok<AGROW>

        % Clear temporary variable
        clear sublist;

    % Otherwise, see if the file is a DICOM file
    else

        % Attempt to parse the DICOM header
        try
            % Execute dicominfo
            info = dicominfo(fullfile(path, list(i).name));

            % Verify storage class field exists
            if ~isfield(info, 'MediaStorageSOPClassUID')
                continue
            end

            % If CT or MR, add to imagefiles
            if strcmp(info.MediaStorageSOPClassUID, ...
                    '1.2.840.10008.5.1.4.1.1.2') || ...
                    strcmp(info.MediaStorageSOPClassUID, ...
                    '1.2.840.10008.5.1.4.1.1.4')
                imagefiles{length(imagefiles)+1} = list(i).name;

            % Otherwise, if structure, add to rtssfiles
            elseif strcmp(info.MediaStorageSOPClassUID, ...
                    '1.2.840.10008.5.1.4.1.1.481.3')
                rtssfiles{length(rtssfiles)+1} = list(i).name;

            % Otherwise, if dose, add to dosefiles
            elseif strcmp(info.MediaStorageSOPClassUID, ...
                    '1.2.840.10008.5.1.4.1.1.481.2')
                dosefiles{length(dosefiles)+1} = list(i).name;
            end

        % If an exception occurs, the file is not a DICOM file so skip
        catch
            continue
        end
    end
end

% Log completion
if exist('Event', 'file') == 2
    Event(sprintf(['Scan completed, finding %i image, %i structure ', ...
        'sets, and %i dose files'], length(imagefiles), length(rtssfiles), ...
        length(dosefiles)), 'UNIT');
end

% Only continue if at least one image was found
if ~isempty(imagefiles)

    % Load the DICOM CT
    image = LoadDICOMImages(path, imagefiles);

    % If a structure set was found
    if ~isempty(rtssfiles)

        % Load the first RTSS
        image.structures = LoadDICOMStructures(path, ...
            rtssfiles{1}, image);
    end

    % If a dose was found
    if ~isempty(dosefiles)

        % Load the first RTDOSE
        dose = LoadDICOMDose(path, dosefiles{1});
        dose.registration = [0 0 0 0 0 0];
    else
        dose = struct();
    end
else
    image = struct();
    dose = struct();
end