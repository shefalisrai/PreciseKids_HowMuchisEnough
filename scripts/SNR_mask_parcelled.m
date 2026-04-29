

wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

% Open SNR mask computed from Midnight Scan Avg 
inputFile='/Users/shefalirai/Desktop/MSCavg_SNRmask.dtseries.nii';
parcelCIFTIFile='/Users/shefalirai/Downloads/Parcellations/HCP/fslr32k/cifti/Schaefer2018_200Parcels_17Networks_order.dlabel.nii';
parcelFile='/Users/shefalirai/Desktop/MSCavg_SNRmask_200parcelled.ptseries.nii';
eval(['! /Applications/workbench/bin_macosx64/wb_command -cifti-parcellate ' inputFile ' ' parcelCIFTIFile ' COLUMN ' parcelFile ' -method MEAN'])
snrMask_parc=ciftiopen(parcelFile, '/Applications/workbench/bin_macosx64/wb_command');
snrMask_parc=snrMask_parc.cdata;
