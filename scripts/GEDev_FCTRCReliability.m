%% Test retest reliability surface maps 

wb_command = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');

% 3 echo dataset with new version of tedana v23.0.2
ses1_3echo=ciftiopen('/Users/shefalirai/Desktop/sub-DEV_ses-DEV_task-vanilla_run-01_Atlas_s4.ptseries.nii',wb_command);
ses2_3echo=ciftiopen('/Users/shefalirai/Desktop/sub-DEV_ses-DEV_task-vanilla_run-02_Atlas_s4.ptseries.nii',wb_command);
% ses1_5echo=ciftiopen('/Users/shefalirai/Desktop/sub-DEV_ses-DEV_task-rest_run-03_Atlas_s4.ptseries.nii',wb_command);
% ses2_5echo=ciftiopen('/Users/shefalirai/Desktop/sub-DEV_ses-DEV_task-rest_run-04_Atlas_s4.ptseries.nii',wb_command);

ses1_3echo_data=ses1_3echo.cdata;
ses2_3echo_data=ses2_3echo.cdata;
ses1_5echo_data=ses1_5echo.cdata;
ses2_5echo_data=ses2_5echo.cdata;

% Assign tables to variables
first_session = [ses1_3echo_data];
second_session = [ses2_3echo_data];

gescan_first_connectome = corr(first_session');
gescan_second_connectome = corr(second_session');

gescan_corr_allses = zeros(1, size(gescan_first_connectome, 1));

gescan_first_connectome(isnan(gescan_first_connectome)) = 0;
gescan_second_connectome(isnan(gescan_second_connectome)) = 0;

for r = 1:size(gescan_first_connectome, 1)
     gescan_corr_allses(r) = corr(gescan_first_connectome(r, :)', gescan_second_connectome(r, :)');
end

reliability_scanlength = nanmean(gescan_corr_allses);


ses1_3echo.cdata=gescan_corr_allses';
ciftisavereset(ses1_3echo, '/Users/shefalirai/Desktop/sub-DEV_VanillaFCTRC_parcellated.pscalar.nii', wb_command);




