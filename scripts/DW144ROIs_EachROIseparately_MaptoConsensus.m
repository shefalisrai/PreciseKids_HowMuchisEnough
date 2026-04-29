%% 144 ROIs based on central vertices using DW153 ROIS and PK Third Consensus Map

% Run this script after 144ROIs_toSpheres_144ROIdscalarfiles.sh
% Script to open and assign new vertex based 144 ROIs to networks
% See DW153ROIspheres_Creation_Ciftify_Surface_ROIs.txt for instructions
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Path to the network consensus map file
consensus_map = '/Users/shefalirai/Desktop/DW153_ROIs/Thirdconsensus_resample_Schaefer2018.dscalar.nii';

% Path to the directory containing the 144 dscalar files
dscalar_directory = '/Users/shefalirai/Desktop/DW153_ROIs/ROI144_3mmSpheres';

% Path to the output directory for the modified dscalar files
output_directory = '/Users/shefalirai/Desktop/DW153_ROIs/ROI_dscalar_networklabels';

% % Create output directory if it doesn't exist
% mkdir(output_directory);

% Iterate over each dscalar file in the directory
dscalar_files = dir(fullfile(dscalar_directory, '*.dscalar.nii'));
for i = 1:numel(dscalar_files)
    % Load current dscalar file
    dscalar_file = fullfile(dscalar_files(i).folder, dscalar_files(i).name);
    dscalar_data = ciftiopen(dscalar_file, wbcommand);
    
    % Extract the data from the dscalar file
    dscalar_map_data = dscalar_data.cdata;
    
    % Open the network consensus map
    third_consensus_map = ciftiopen(consensus_map, wbcommand);
    third_consensus_map_data = third_consensus_map.cdata;
    
    % Find indices where dscalar_map_data is 1 or 2
    indices = dscalar_map_data(:, 1) > 0; 

    % Update values in the dscalar_map_data based on the condition
    dscalar_map_data(indices, 2) = third_consensus_map_data(indices);
    
    % Visualize on surface
    dscalar_data.cdata = dscalar_map_data;
    output_file_path = fullfile(output_directory, sprintf('%s_withnetworklabels.dscalar.nii', strrep(dscalar_files(i).name, '.dscalar.nii', '')));
    ciftisavereset(dscalar_data, output_file_path, wbcommand);
end
