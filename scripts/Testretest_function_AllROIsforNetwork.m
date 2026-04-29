% Loop to run function TestretestReliability_FullCurves_AllROIsforNetwork_Child or _Parent.m
% PK All ROIs for each Network FCTRC reliability vs. scan length for either children or parents

%After running Timeseries_143DWROIs_function.m and AveragedFC_143ROIs_EachNetwork.m
networks = {'AUD-1','CON-2', 'DAN-3','DMN-4','FP-5','MTL-6','PMN-7','PON-8','SAL-9', 'SMd-10', 'SMl-11', 'VAN-12','VIS-13'};
%Note: This is the re-ordered network structure that the ROIs are based off of

for i = 1:numel(networks)
    % Extract network number and name
    network_str = networks{i};
    split_str = split(network_str, '-');
    network_number = str2double(split_str{2});
    network_name = split_str{1};

    % Call the function with current network parameters
    TestretestReliability_FullCurves_AllROIsforNetwork_Child(network_number, network_name);
    TestretestReliability_FullCurves_AllROIsforNetwork_Parent(network_number, network_name);
end


