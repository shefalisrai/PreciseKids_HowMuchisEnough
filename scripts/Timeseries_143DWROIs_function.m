% Loop to run function FC_143DWROIs_Child or _Parent.m

%For this script to run, must have dtseries_C/P_sessions_{task} already in workspace
%networks = {'DMN-1','VIS-2', 'FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11', 'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7

% Define the total number of ROIs
total_ROIs = 153;

% Define the missing ROI numbers
missing_ROIs = [9, 14, 40, 41, 46, 86, 93, 116, 126, 130];

% Loop through each ROI number
for i = 1:total_ROIs
        % Skip if ROI number is in the list of missing ROIs
        if ismember(i, missing_ROIs)
            continue;
        end

        % For each ROI number
        scan_length_volumes = 709; %lowest from Sub17P for sessions1and4 combined
        ROI_number = i;

        % Call the function using parameters above
        Timeseries_143DWROIs_Child(ROI_number, scan_length_volumes, dtseries_C_sessions_DORA, dtseries_C_sessions_RX, dtseries_C_sessions_YT);
        Timeseries_143DWROIs_Parent(ROI_number, scan_length_volumes, dtseries_P_sessions_DORA, dtseries_P_sessions_RX, dtseries_P_sessions_YT);
end



%% Concatenate both Child and Parent CSVs
% 
% % Define the directory containing the CSV files
% directory_path = '/Users/shefalirai/Desktop/PK_ROIs/';
% 
% % List all files in the directory
% file_list = dir(fullfile(directory_path, '*.csv'));
% 
% % Loop through all files in the directory
% for file_idx = 1:length(file_list)
%     % Extract the file name
%     file_name = file_list(file_idx).name;
%     
%     % Check if the file is a child or parent file
%     if startsWith(file_name, 'Child_Timeseries_') % Check if it's a child file
%         child_file_path = fullfile(directory_path, file_name);
%         
%         % Modify the file name to match the corresponding parent file
%         parent_file_name = strrep(file_name, 'Child_Timeseries_', 'Parent_Timeseries_');
%         parent_file_path = fullfile(directory_path, parent_file_name);
%         
%         % Read data from the child and parent CSV files
%         child_data = csvread(child_file_path); 
%         parent_data = csvread(parent_file_path); 
%                  
%         % Vertically concatenate the data
%         concatenated_data = [child_data; parent_data];
%         
%         % Modify the file name for the concatenated CSV file
%         concatenated_file_name = strrep(file_name, 'Child_Timeseries_', 'ConcatenatedChildParent_Timeseries_');
%         concatenated_file_path = fullfile(directory_path, concatenated_file_name);
%         
%         % Save the concatenated data into a new CSV file
%         csvwrite(concatenated_file_path, concatenated_data);
%     end
% end

