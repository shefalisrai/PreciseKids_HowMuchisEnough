%% Test retest reliability surface maps 

wb_command = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');

% 3 echo dataset with new version of tedana v23.0.2
ses1_3echo=ciftiopen('/Users/shefalirai/Desktop/sub-shef_ses-1_task-rest_netaGEDevscan_parcellated.ptseries.nii',wb_command);
ses2_3echo=ciftiopen('/Users/shefalirai/Desktop/sub-shef_ses-2_task-rest_netaGEDevscan_parcellated.ptseries.nii',wb_command);

ses1_3echo_data=ses1_3echo.cdata;
ses2_3echo_data=ses2_3echo.cdata;

% Assign tables to variables
first_session = ses1_3echo_data;
second_session = ses2_3echo_data;

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
ciftisavereset(ses1_3echo, '/Users/shefalirai/Desktop/sub-shef_3echoFCTRC_task-rest_GEDevscan_parcellated.pscalar.nii', wb_command);




