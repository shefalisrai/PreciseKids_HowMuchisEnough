function AveragedFC_143ROIs_EachNetwork(group)
% Create connectomes for all averaged timeseries within each ROI for each network
% Run this script after Timeseries_143DWROIs_Child.m 

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
ROIs_path='/Users/shefalirai/Desktop/PK_ROIs/'; % where each ROI averaged vertices full timeseries is saved
%group='Parent'; %Or 'Child'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Open list of all ROIs and their network assignment
load("143ROI_Orderedby_NetworkGroup.mat");

% Get unique network names
networks = unique(matched_networks_final(:, 1));

% Initialize a cell array to store lists of numbers for each network
number_lists = cell(size(networks));

% Iterate over each network
for i = 1:numel(networks)
    network_name = networks{i};
    % Find indices of rows corresponding to the current network
    indices = strcmp(matched_networks_final(:, 1), network_name);
    % Extract numbers for the current network
    numbers = matched_networks_final(indices, 2);
    % Store the numbers in the cell array
    number_lists{i} = numbers;
end

% Add network labels to numbers list
for j=1:numel(networks)
    number_lists{j,2}=networks{j,1};
end

%% Open ROI csvs based on network list
% Initialize network_data cell array
network_data_1and4 = cell(1, numel(networks));
network_data_2and3 = cell(1, numel(networks));

% Open ROI csvs based on network list
for i = 1:numel(networks)
    network_name = networks{i};
    numbers = number_lists{i};
    data_1and4 = cell(1, numel(numbers));  
    data_2and3 = cell(1, numel(numbers));  
    
    % Iterate over each number in the list
    for j = 1:numel(numbers)
        number = numbers{j};
        % Construct the file path
        file_path_2and3 = fullfile(ROIs_path, sprintf('%s_Timeseries_%dROI_sessions2and3.csv', group, number));
        file_path_1and4 = fullfile(ROIs_path, sprintf('%s_Timeseries_%dROI_sessions1and4.csv', group, number));

        % Check if the file exists
        if exist(file_path_2and3, 'file') == 2
            % If the file exists, open it
            data_2and3{j} = csvread(file_path_2and3);  
        else
            % If the file does not exist, display a warning
            warning(['File does not exist: ' file_path_2and3]);
        end

        % Check if the file exists
        if exist(file_path_1and4, 'file') == 2
            % If the file exists, open it
            data_1and4{j} = csvread(file_path_1and4);  
        else
            % If the file does not exist, display a warning
            warning(['File does not exist: ' file_path_1and4]);
        end

    end
    
    % Store data for this network in network_data
    network_data_2and3{i} = data_2and3;
    network_data_1and4{i} = data_1and4;
end

save(sprintf('EachNetwork_AveragedROI_Timeseries_%s_Session1and4.mat', group), 'network_data_1and4');
save(sprintf('EachNetwork_AveragedROI_Timeseries_%s_Session2and3.mat', group), 'network_data_2and3');


end

