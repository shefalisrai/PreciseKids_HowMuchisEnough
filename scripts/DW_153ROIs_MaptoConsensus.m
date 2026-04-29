%% Create ROIS using Dworetzsky 153 ROI volume nifti

% First turn 153 ROIs to spheres in volume space then project 153 ROIs to the MSC averaged surface 
% See DW153ROIs_VolumeSphereCreation.txt for instructions
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

networks = {'DMN-1','VIS-2', 'FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11', 'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7

% Open Parent and Child consensus network map
third_consensus_map=ciftiopen('/Users/shefalirai/Desktop/PK_networkassignment/Thirdconsensus_adultchildcombined_templatematching_66percent_networkconsensusmap.dscalar.nii', wbcommand);
third_consensus_map_data=third_consensus_map.cdata;

% Read file paths from the .txt file
fileID = fopen('/Users/shefalirai/Desktop/DW153_ROIs/ROI_paths_all.txt', 'r');
file_paths = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

% Iterate through each file path and process them
for j = 1:numel(file_paths{1})
    roi_file_path = file_paths{1}{j};
    
    % Extract network name from the ROI path
    [~, roi_filename, ~] = fileparts(roi_file_path);
    roi_network_name = regexp(roi_filename, '\d+_(\w+)_', 'tokens', 'once');

    % Check if network name is extracted
    if isempty(roi_network_name)
        warning(['Network name not found for the ROI: ', roi_file_path]);
        continue; % Skip to the next file path
    end

    % Initialize network number
    network_number = [];

    % Iterate through the networks list to find the matching network name
    for i = 1:numel(networks)
        % Extract network name and number from the networks list
        split_str = split(networks{i}, '-');
        network_name = split_str{1};
        network_num = str2double(split_str{2});
        % Check if the network name from the ROI path matches with the network name from the networks list
        if strcmp(network_name, roi_network_name)
            % Store the network number
            network_number = network_num;
            break;
        end
    end

    % Check if network number is found
    if isempty(network_number)
        warning(['Network number not found for the ROI: ', roi_file_path]);
        continue; % Skip to the next file path
    end

    % Open ROI dscalar
    dw_roi = ciftiopen(roi_file_path, wbcommand);
    dw_roi_data = dw_roi.cdata;

    % Initialize overlap_rois_consensus
    overlap_roi_consensus = zeros(size(dw_roi_data));

    % Find non-zero indices in dw_rois_data
    non_zero_indices = find(dw_roi_data ~= 0);

    % Iterate through non-zero indices and assign values from third_consensus_map_data
    for i = 1:length(non_zero_indices)
        index = non_zero_indices(i);
        % Check if the corresponding value in third_consensus_map_data is equal to network_number
        if third_consensus_map_data(index) == network_number
            overlap_roi_consensus(index) = third_consensus_map_data(index);
        end
    end

    % Replace zeros with NaNs
    overlap_roi_consensus(overlap_roi_consensus == 0) = NaN;

    % Visualize on surface
    dw_roi.cdata = overlap_roi_consensus;
    [~, roi_name, ~] = fileparts(roi_file_path);
    output_file_path = ['/Users/shefalirai/Desktop/DW153_ROIs/', roi_name, '_overlap_adultchild_66percentnetworkconsensusmap.dscalar.nii'];
    ciftisavereset(dw_roi, output_file_path, wbcommand);
end


%% Create combined ROI and network map regions


% Initialize combined overlap matrix
combined_overlap_matrix = [];

% Iterate through each file path and process them
for j = 1:numel(file_paths{1})
    roi_file_path = file_paths{1}{j};
    
    % Open ROI dscalar
    dw_roi = ciftiopen(roi_file_path, wbcommand);
    dw_roi_data{j} = dw_roi.cdata;

end

% Initialize the combined matrix with NaNs
combined_matrix = NaN(91282, 1);

% Iterate through each cell of dw_roi_data
for i = 1:numel(dw_roi_data)
    % Get the current cell
    current_cell = dw_roi_data{i};
    
    % Find indices where there are non-zero values
    non_zero_indices = find(current_cell ~= 0);
    
    % Assign non-zero values to the corresponding indices in the combined matrix
    combined_matrix(non_zero_indices) = current_cell(non_zero_indices);
end

% Iterate through each cell of dw_roi_data
for i = 1:numel(dw_roi_data)
    % Get the current cell
    current_cell = dw_roi_data{i};
    
    % Find indices where there are non-zero values
    non_zero_indices = find(current_cell ~= 0);
    
    % Assign non-zero values to the corresponding indices in the combined matrix
    combined_matrix(non_zero_indices, 1) = current_cell(non_zero_indices);
    combined_matrix(non_zero_indices, 2) = third_consensus_map_data(non_zero_indices);
end

% Replace zeros with NaNs
combined_matrix(combined_matrix == 0) = NaN;

% Visualize on surface
dw_roi.cdata = combined_matrix;
output_file_path = ['/Users/shefalirai/Desktop/DW153_ROIs/CombinedMatrix_ROIoverlap_adultchild_66percentnetworkconsensusmap.dscalar.nii'];
ciftisavereset(dw_roi, output_file_path, wbcommand);
