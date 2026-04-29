% Loop to run function TestretestReliability_FullCurves_NetworkWise_Child or _Parent.m
% PK Network-wise FCTRC reliability vs. scan length for either children or parents
% For parent up to 24 mins and child up to 36 minutes split-half is where we retain all 24 participants 

%For this script to run, must have dtseries_C/P_sessions_{task} already in workspace
networks = {'DMN-1','VIS-2', 'FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11', 'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7

for i = 1:numel(networks)
    % Extract network number and name
    network_str = networks{i};
    split_str = split(network_str, '-');
    network_number = str2double(split_str{2});
    network_name = split_str{1};

%     % If not already loaded into workspace:
%     % Load saved dtseries variables       
%     loaded_data_DORA = load('dtseries_C_sessions_DORA.mat');
%     loaded_data_RX = load('dtseries_C_sessions_RX.mat');
%     loaded_data_YT = load('dtseries_C_sessions_YT.mat');
% 
%     % Extract the actual variables from the loaded data structures
%     dtseries_C_sessions_DORA = loaded_data_DORA.dtseries_C_sessions_DORA  ;
%     dtseries_C_sessions_RX = loaded_data_RX.dtseries_C_sessions_RX;
%     dtseries_C_sessions_YT = loaded_data_YT.dtseries_C_sessions_YT;

    % Call the function with current network parameters
    %TestretestReliability_FullCurves_NetworkWise_Child(network_number, network_name, dtseries_C_sessions_DORA, dtseries_C_sessions_RX, dtseries_C_sessions_YT);
    TestretestReliability_FullCurves_NetworkWise_Parent(network_number, network_name, dtseries_P_sessions_DORA, dtseries_P_sessions_RX, dtseries_P_sessions_YT);
end


