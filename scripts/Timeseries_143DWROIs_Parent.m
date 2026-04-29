function Timeseries_143DWROIs_Parent(ROI_number, scan_length_volumes, dtseries_P_sessions_DORA, dtseries_P_sessions_RX, dtseries_P_sessions_YT)

%Extract Timeseries from vertices from ROIS belonging to PK consensus networks overlap with 144DWROIs

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Using template matched consensus networks from
%NetworkConsensus_IndividualParticipant_TemplateMatchingMaps.m file
%Using code from here: https://github.com/leotozzi88/reliability_study/tree/master
% %Assumed network order in conc file. = {'DMN-1','VIS-2','FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11'...
% cont'd...'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
%make sure to ignore network 4 and 6 as they do not exist
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
ROIs_outputpath='/Users/shefalirai/Desktop/PK_ROIs'; % where edges will be saved
 %Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7
subject='P';
subject_types = {'P'};
% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%% Must uncomment this code below if you are switching from parent/adult to
% %child, otherwise can leave commented and run for all 14 networks 
% 
% % Code below for opening and censoring dtseries
% 
% % Assume each session contributes an equal number of columns
% columns_per_session = 410;
% tasks = {'task-DORA', 'task-RX', 'task-YT'};
% 
% % Loop through each task
% for t = 1:length(tasks)
%     task = tasks{t};
% 
%     % Load and split the data for each task
%     dtseries_P_sessions = cell(26, 4); % 26 subjects x 4 sessions
%     for sub = 2:26
%         % Construct file path
%         file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_resampled_dtseries/sub-19730%02d%s_%s_allsessions_resampled.dtseries.nii', sub, subject, task);
% 
%         try
%             % Load data
%             data = ciftiopen(file_path, wbcommand);
%             data = data.cdata; % Extract cdata
% 
%             % Split data into sessions
%             for ses = 1:4
%                 start_col = (ses - 1) * columns_per_session + 1;
%                 end_col = ses * columns_per_session;
%                 dtseries_P_sessions{sub, ses} = data(:, start_col:end_col);
%             end
%         catch
%             fprintf('Error: file does not exist for subject %d\n', sub);
%         end
%     end
%     assignin('base', sprintf('dtseries_P_sessions_%s', task(6:end)), dtseries_P_sessions);
% end
% 
% 
% %% Remove motion volumes using FD>0.15mm threshold
% 
% % Define threshold for high motion
% threshold = 0.15;
% 
% % Define your sessions and updated tasks with two variants for each original task
% sessions = {'ses-1', 'ses-2', 'ses-3', 'ses-4'};
% original_tasks = {'DORA', 'RX', 'YT'};
% sub_tasks = {'1', '2'}; % Two sub-tasks for each original task
% 
% % List of subject numbers
% subject_numbers = 2:26; % From 2 to 26
% subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3
% 
% % Assume each sub-task has an equal number of volumes
% num_volumes_per_sub_task = 205;
% 
% 
% % Process each subject type and number
% for type = subject_types
%     for sub = subject_numbers
%         % Create subject identifier with appropriate leading zeros
%         subject_identifier = sprintf('19730%02d%s', sub, type{1});
% 
%         % Process each session
%         for ses = 1:4
%             % Loop over each original task
%             for t = 1:length(original_tasks)
%                 task = original_tasks{t};
%                 
%                 % Select the appropriate session data
%                 data_variable_name = sprintf('dtseries_%s_sessions_%s', type{1}, task);
%                 sub_data = eval([data_variable_name '{sub, ses}']);
% 
%                 % Initialize the full columns to remove for this session
%                 full_columns_to_remove = [];
% 
%                 % Process each sub-task
%                 for st = 1:length(sub_tasks)
%                     sub_task = sub_tasks{st};
%                     task_with_sub = [task sub_task]; % Combine task with its sub-task
%                     
%                     % Initialize the indices of columns to remove for this sub-task
%                     columns_to_remove = [];
% 
%                     % Handle the special case for sub-1973024P and ses-6
%                     session_id = sessions{ses};
%                     if strcmp(subject_identifier, '1973024P') && ses == 4
%                         session_id = 'ses-6';
%                     end
% 
%                     % Construct the CSV file path for the current session and sub-task
%                     csv_file_path = sprintf('/Volumes/Prckids/sub-%s/%s/func/sub-%s_%s_task-%s_echo-2_PowerFDFlt.csv', subject_identifier, session_id, subject_identifier, session_id, task_with_sub);
% 
%                     % Load the motion parameters from the CSV file
%                     try
%                         fd = readtable(csv_file_path);
%                     catch
%                         warning('Unable to read file: %s', csv_file_path);
%                         continue;
%                     end
% 
%                     % Find volumes with high motion for this sub-task
%                     high_motion_volumes = find(fd.FD > threshold);
% 
%                     % Adjust the indices for the current sub-task
%                     adjusted_indices = high_motion_volumes + (st - 1) * num_volumes_per_sub_task;
%                     columns_to_remove = [columns_to_remove; adjusted_indices];
%                     
%                     % Append to the full columns to remove for this session
%                     full_columns_to_remove = [full_columns_to_remove; columns_to_remove];
%                 end
% 
%                 % Remove duplicates and sort the indices for the full session
%                 full_columns_to_remove = unique(sort(full_columns_to_remove));
% 
%                 % Remove the high motion columns for this session
%                 for idx = length(full_columns_to_remove):-1:1
%                     if full_columns_to_remove(idx) <= size(sub_data, 2)
%                         sub_data(:, full_columns_to_remove(idx)) = [];
%                     else
%                         warning('Attempted to remove a column that does not exist. Index: %d', full_columns_to_remove(idx));
%                     end
%                 end
% 
%                 % Store the cleaned data back
%                 eval([data_variable_name '{sub, ses} = sub_data;']);
%             end
%         end
%     end
% end
% 


%% If needed, can save dtseries for each task

% % % % save('dtseries_P_sessions_DORA', 'dtseries_P_sessions_DORA', '-v7.3');
% % % % save('dtseries_P_sessions_RX', 'dtseries_P_sessions_RX', '-v7.3');
% % % % save('dtseries_P_sessions_YT', 'dtseries_P_sessions_YT', '-v7.3');
% % % % %takes about 5 minutes each task variable

%% Extract vertices from specified ROIs from each task variable
% we are not removing SNR regions since we want specific vertices to be extracted that may be in the SNR region

%assumed network order in conc file =  {'DMN','Vis','FP','DAN','VAN','Sal','CO','SMd','SML','AUD', 'Tpole', 'MTL','PMN','PON'};

roi_map=ciftiopen(sprintf('/Users/shefalirai/Desktop/DW153_ROIs/ROI_dscalar_networklabels/%dROI_3mmSpheres_withnetworklabels.dscalar.nii', ROI_number), wbcommand);
roi_map_data=roi_map.cdata;

roi_vertices=[];

% Find the vertices from ROI network map
roi_vertices = find(roi_map_data(:,2) > 0 ); 

% Define the cell arrays corresponding to each variable
variables = {dtseries_P_sessions_DORA, dtseries_P_sessions_YT, dtseries_P_sessions_RX};

% Initialize cell arrays to store the extracted matrices for each variable
ROI_P_DORA = cell(size(dtseries_P_sessions_DORA));
ROI_P_YT = cell(size(dtseries_P_sessions_YT));
ROI_P_RX = cell(size(dtseries_P_sessions_RX));

% Loop through each variable
for v = 1:numel(variables)
    % Loop through each cell in the current variable
    for i = 1:numel(variables{v})
        % Check if the cell is empty
        if isempty(variables{v}{i})
            % If empty, continue to the next iteration
            continue;
        end
        
        % Get the matrix from the current cell
        current_matrix = variables{v}{i};
        
        % Extract the rows corresponding to roi_vertices
        extracted_matrix = current_matrix(roi_vertices,:);
        
        % Store the extracted matrix in the corresponding cell of the output cell array
        switch v
            case 1
                ROI_P_DORA{i} = extracted_matrix;
            case 2
                ROI_P_YT{i} = extracted_matrix;
            case 3
                ROI_P_RX{i} = extracted_matrix;
        end
    end
end


%% Create first and last half session before creating connectomes

% Initialize new variables for combined sessions across all tasks
ROI_P_Timeseries1 = cell(26, 1); % Combining sessions 1 and 4 across all tasks
ROI_P_Timeseries2 = cell(26, 1); % Combining sessions 2 and 3 across all tasks

% List of tasks
tasks = {'DORA', 'RX', 'YT'};

% Combine sessions for each subject across all tasks
for sub = subject_numbers
    % Initialize temporary variables to store combined data for this subject
    temp_P_combined1 = [];
    temp_P_combined2 = [];
    for task = tasks
        % Construct the variable name for the task-specific cell array
        data_variable_name_P = sprintf('ROI_P_%s', task{1});
        
        % Combine for Child subjects
        temp_P_combined1 = [temp_P_combined1, eval(sprintf('cat(2, %s{sub, [1, 4]})', data_variable_name_P))];
        temp_P_combined2 = [temp_P_combined2, eval(sprintf('cat(2, %s{sub, [2, 3]})', data_variable_name_P))];
    end

    % Assign the temporary combined data to the final combined variables
    ROI_P_Timeseries1{sub,1} = temp_P_combined1;
    ROI_P_Timeseries2{sub,1} = temp_P_combined2;
end


% Initialize the matrix to store the averaged values
num_columns = scan_length_volumes; % 150 volumes is 5 minutes
num_cells = size(ROI_P_Timeseries1, 1);
ROI_P_Timeseries1_averaged = zeros(num_cells, num_columns);
ROI_P_Timeseries2_averaged = zeros(num_cells, num_columns);


% Iterate through each cell in the cell array
for i = 1:num_cells
    % Check if the cell is empty (for row 1 and 3)
    if isempty(ROI_P_Timeseries1{i})
        continue; % Skip to the next iteration
    end
    
    % Calculate the mean of each column across all rows
    mean_values1 = mean(ROI_P_Timeseries1{i}(:, 1:num_columns), 1);
    mean_values2 = mean(ROI_P_Timeseries2{i}(:, 1:num_columns), 1);

    % Store the mean values in the new matrix
    ROI_P_Timeseries1_averaged(i, :) = mean_values1;
    ROI_P_Timeseries2_averaged(i, :) = mean_values2;
end


% Remove rows 1 and 3 since missing subjects
ROI_P_Timeseries1_averaged_final=ROI_P_Timeseries1_averaged([2,4:end],:); %sessions 1 and 4
ROI_P_Timeseries2_averaged_final=ROI_P_Timeseries2_averaged([2,4:end],:); %sessions 2 and 3


%Save mean Timeseries ROI values for each network
csvwrite(strcat(ROIs_outputpath, sprintf('/Parent_Timeseries_%dROI_sessions1and4.csv', ROI_number)), ROI_P_Timeseries1_averaged_final)
csvwrite(strcat(ROIs_outputpath, sprintf('/Parent_Timeseries_%dROI_sessions2and3.csv', ROI_number)), ROI_P_Timeseries2_averaged_final)



end


