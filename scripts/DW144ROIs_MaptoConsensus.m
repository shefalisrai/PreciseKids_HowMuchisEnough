%% 144 ROIs based on central vertices using DW153 ROIS and PK Third Consensus Map

% Run this script after 144ROIs_toSpheres_144ROIdscalarfiles.sh
% Script to open and assign new vertex based 144 ROIs to networks
% See DW153ROIspheres_Creation_Ciftify_Surface_ROIs.txt for instructions
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

networks = {'DMN-1','VIS-2', 'FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11', 'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7

% Open Parent and Child consensus network map
third_consensus_map=ciftiopen('/Users/shefalirai/Desktop/DW153_ROIs/Thirdconsensus_resample_Schaefer2018.dscalar.nii', wbcommand);
third_consensus_map_data=third_consensus_map.cdata;

% Open 144 ROI spheres on surface
roisphere_map = ciftiopen('/Users/shefalirai/Desktop/DW153_ROIs/sub-MSCAvg_PKconsensusmap_144DWROI_3mmSpheres.dscalar.nii', wbcommand);
roisphere_map_data = roisphere_map.cdata;

% Find indices where roisphere_map is 1 or 2 in the first column
indices = roisphere_map_data(:, 1) == 1 | roisphere_map_data(:, 1) == 2;

% Update values in the roisphere_map_data based on the condition
roisphere_map_data(indices, 2) = third_consensus_map_data(indices);

% Visualize on surface
roisphere_map.cdata = roisphere_map_data;
output_file_path = '/Users/shefalirai/Desktop/DW153_ROIs/sub-MSCAvg_PKconsensusmap_144DWROI_3mmSpheres_withnetworklabels.dscalar.nii';
ciftisavereset(roisphere_map, output_file_path, wbcommand);

