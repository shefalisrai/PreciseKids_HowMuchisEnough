function Dtseries_Resample_DW144ROIs_Prep(directory)
%FC_ROIWISE_AllTasks for Children
%First we need to resample all uncensored dtseries in order to obtain surface ROI vertices 
% Define the directory where your files are located
%Example input for directory = '/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_dtseries/';

% List all files in the directory
file_list = dir(fullfile(directory, '*.dtseries.nii'));

% Loop through all files in the directory
for people = 1:length(file_list)
    % Get the filename for the current file
    inputFile = fullfile(directory, file_list(people).name);
    resampleCIFTIFile='/Users/shefalirai/Downloads/Parcellations/HCP/fslr32k/cifti/Schaefer2018_200Parcels_17Networks_order.dscalar.nii';
    resampledOutputFile=sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_resampled_dtseries/%s', file_list(people).name);
    eval(['! /Applications/workbench/bin_macosx64/wb_command -cifti-resample ' inputFile ' COLUMN ' resampleCIFTIFile ' COLUMN ADAP_BARY_AREA CUBIC ' resampledOutputFile])
end

end