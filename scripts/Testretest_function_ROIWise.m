% Loop to run function TestretestReliability_FullCurves_ROI_Child or _Parent.m

%For this script to run, must have dtseries_C/P_sessions_{task} already in workspace
%networks = {'DMN-1','VIS-2', 'FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11', 'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7

% Define the total number of ROIs
total_ROIs = 152;

% Define the missing ROI numbers
missing_ROIs = [9, 14, 40, 41, 46, 86, 93, 116, 126, 130];

% Loop through each ROI number
for i = 1:total_ROIs
    % Skip if ROI number is in the list of missing ROIs
    if ismember(i, missing_ROIs)
        continue;
    end
    
    % For each ROI number
    ROI_number = i;
    
    % Call the function using parameters above
    TestretestReliability_FullCurves_ROI_Child(ROI_number,  dtseries_C_sessions_DORA, dtseries_C_sessions_RX, dtseries_C_sessions_YT);
    %TestretestReliability_FullCurves_ROI_Parent(ROI_number, dtseries_P_sessions_DORA, dtseries_P_sessions_RX, dtseries_P_sessions_YT);
end



