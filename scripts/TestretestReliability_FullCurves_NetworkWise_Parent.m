function TestretestReliability_FullCurves_NetworkWise_Parent(network_number, network_name, dtseries_P_sessions_DORA, dtseries_P_sessions_RX, dtseries_P_sessions_YT)
%TestretestReliability_FCTRC_Networkwise_AllTasks for Parents
% PK Network-wise FCTRC reliability vs. scan length
% For parent up to 24 minutes split-half is where we retain all 24 participants 


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Using template matched consensus networks from
%NetworkConsensus_IndividualParticipant_TemplateMatchingMaps.m file
%Using code from here: https://github.com/leotozzi88/reliability_study/tree/master
% %Assumed network order in conc file. = {'DMN-1','VIS-2','FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11'...
% cont'd...'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
FCTRC_outputpath='/Users/shefalirai/Desktop/PK_FCTRCs'; % where edges will be saved
 %Note: Network 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7
subject='P';
subject_types = {'P'};
% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


 
% %Must uncomment this code below if you are switching from parent/adult to
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
%         file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_dtseries/sub-19730%02d%s_%s_allsessions.dtseries.nii', sub, subject, task);
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


%% Extract vertices from specified Network from each task variable
% we are not removing SNR regions since we want specific vertices to be extracted that may be in the SNR region

%assumed network order in conc file. =  {'DMN','Vis','FP','DAN','VAN','Sal','CO','SMd','SML','AUD', 'Tpole', 'MTL','PMN','PON'};

parent_networkconsensus_map=ciftiopen('/Users/shefalirai/Desktop/PK_networkassignment/Thirdconsensus_adultchildcombined_templatematching_66percent_networkconsensusmap.dscalar.nii', wbcommand);
parent_networkconsensus=parent_networkconsensus_map.cdata;

dmn_vertices = [];
% Find the DMN vertices 
dmn_vertices = find(parent_networkconsensus(:,1) == network_number); %between 1 and 16 for networks, make sure to ignore network 4 and 6 as they do not exist

% Define the cell arrays corresponding to each variable
variables = {dtseries_P_sessions_DORA, dtseries_P_sessions_YT, dtseries_P_sessions_RX};

% Initialize cell arrays to store the extracted matrices for each variable
DMN_P_DORA = cell(size(dtseries_P_sessions_DORA));
DMN_P_YT = cell(size(dtseries_P_sessions_YT));
DMN_P_RX = cell(size(dtseries_P_sessions_RX));

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
        
        % Extract the rows corresponding to dmn_vertices
        extracted_matrix = current_matrix(dmn_vertices,:);
        
        % Store the extracted matrix in the corresponding cell of the output cell array
        switch v
            case 1
                DMN_P_DORA{i} = extracted_matrix;
            case 2
                DMN_P_YT{i} = extracted_matrix;
            case 3
                DMN_P_RX{i} = extracted_matrix;
        end
    end
end


%% Create first and last half session before creating connectomes

% Initialize new variables for combined sessions across all tasks
DMN_P_combined1 = cell(26, 1); % Combining sessions 1 and 4 across all tasks
DMN_P_combined2 = cell(26, 1); % Combining sessions 2 and 3 across all tasks

% List of tasks
tasks = {'DORA', 'RX', 'YT'};

% Combine sessions for each subject across all tasks
for sub = subject_numbers
    % Initialize temporary variables to store combined data for this subject
    temp_P_combined1 = [];
    temp_P_combined2 = [];

    for task = tasks
        % Construct the variable name for the task-specific cell array
        data_variable_name_P = sprintf('DMN_P_%s', task{1});
        
        % Combine for Parent subjects
        temp_P_combined1 = [temp_P_combined1, eval(sprintf('cat(2, %s{sub, [1, 4]})', data_variable_name_P))];
        temp_P_combined2 =  [temp_P_combined2, eval(sprintf('cat(2, %s{sub, [2, 3]})', data_variable_name_P))];
    end

    % Assign the temporary combined data to the final combined variables
    DMN_P_combined1{sub} = temp_P_combined1;
    DMN_P_combined2{sub} = temp_P_combined2;
end


%% Calculate DMN connectomes for each scan length increment manually for lower computational load

% Calculate scan_length
% Initialize the cell array for storing the matrices with the largest column size
scan_length_max_P = cell(1, numel(DMN_P_combined1));

for i = 1:numel(DMN_P_combined1)
    % Get the size of the matrices in the current cells 
    size_firstfourth_P = size(DMN_P_combined1{i});
    size_secondthird_P = size(DMN_P_combined2{i});
    
    % Compare the column sizes and store the matrix with the largest column size
    if size_firstfourth_P(2) >= size_secondthird_P(2)
        scan_length_max_P{i} = size(DMN_P_combined1{i},2);
    else
        scan_length_max_P{i} = size(DMN_P_combined2{i},2);
    end
end

% Define the increment for the scan length, 5 minutes
% 150 volumes is 5 mins, 30 volumes is 1 min
scan_length_increment = 30;

% Initialize the reliability_scanlength_cell cell array
reliability_scanlength_cell_P = cell(1, numel(DMN_P_combined1));

% Outer loop for each subject
for j = 1:numel(DMN_P_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(DMN_P_combined1{j}) && ~isempty(DMN_P_combined2{j})
        % Calculate scan_length_max for the current subject
        scan_length_max_P_subject = max(size(DMN_P_combined1{j}, 2), size(DMN_P_combined2{j}, 2));

        % Initialize reliability_scanlength for the current subject
        reliability_scanlength_P = zeros(1, ceil(scan_length_max_P_subject / scan_length_increment));

        % Inner loop through increments for the scan length
        for i = scan_length_increment:scan_length_increment:scan_length_max_P_subject
            % Ensure the loop index is within bounds for scan_length_max
            if i > scan_length_max_P_subject
                break;
            end

            % Extract the first i columns from the matrix for the current subject
            DMN_firstfourth_columns_P = DMN_P_combined1{j}(:, 1:min(i, size(DMN_P_combined1{j}, 2)));
            DMN_secondthird_columns_P = DMN_P_combined2{j}(:, 1:min(i, size(DMN_P_combined2{j}, 2)));

            % Compute correlations for the current subject
            DMN_firstfourth_connectome_P = corr(DMN_firstfourth_columns_P');
            DMN_secondthird_connectome_P = corr(DMN_secondthird_columns_P');

            DMN_corr_allses_P = zeros(1, size(DMN_firstfourth_connectome_P, 1));

            % Remove NaNs
            DMN_firstfourth_connectome_P(isnan(DMN_firstfourth_connectome_P)) = 0;
            DMN_secondthird_connectome_P(isnan(DMN_secondthird_connectome_P)) = 0;

            % Correlate
            for r = 1:size(DMN_firstfourth_connectome_P, 1)
               DMN_corr_allses_P(r) = corr(DMN_firstfourth_connectome_P(r, :)', DMN_secondthird_connectome_P(r, :)');
            end

            % Store the mean correlation for the current scan length
            reliability_scanlength_P(i/scan_length_increment) = nanmean(DMN_corr_allses_P);
                 
        end

        % Store reliability_scanlength for the current subject
        reliability_scanlength_cell_P{j} = reliability_scanlength_P;

    end
end

% Remove trailing zeros for each subject
for j = 1:numel(reliability_scanlength_cell_P)
    reliability_scanlength_cell_P{j} = reliability_scanlength_cell_P{j}(reliability_scanlength_cell_P{j} ~= 0);
end


%% Find mean and standard deviation of all 24 subjects

% Find the shortest length for both conditions
min_length_P = min(cellfun('prodofsize', reliability_scanlength_cell_P(~cellfun('isempty', reliability_scanlength_cell_P))));

% Create matrices with matched lengths for both conditions
matched_matrix_P = nan(numel(reliability_scanlength_cell_P), min_length_P);

% Populate the matched matrices for condition P
for i = 1:numel(reliability_scanlength_cell_P)
    current_data = reliability_scanlength_cell_P{i};
    if ~isempty(current_data)
        matched_matrix_P(i, 1:numel(current_data)) = current_data;
    end
end

% Replace 0 values with NaN in matched_matrix_P
matched_matrix_P(matched_matrix_P == 0) = NaN;

% Calculate the mean of each corresponding element across cells for both conditions
mean_values_P = mean(matched_matrix_P, 'omitnan');

% Calculate the standard deviation of each corresponding element across cells for both conditions
std_values_P = std(matched_matrix_P, 'omitnan');


%Save FCTRC values for DMN
csvwrite(strcat(FCTRC_outputpath, sprintf('/Parent_FCTRC_%s_allscantimes_meanvalues.csv', network_name)), mean_values_P)
csvwrite(strcat(FCTRC_outputpath, sprintf('/Parent_FCTRC_%s_allscantimes_stdvalues.csv', network_name)), std_values_P)

end


