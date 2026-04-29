%% Testretest Reliability code for all tasks to create reliability curves for parents and children

% For this code:
% A varying amount of data (ranging from 2.5 minutes to 100 minutes, when
% possible) will be computed for test-retest reliability
% This data was contiguous within sessions but did not necessarily include temporally adjacent sessions. 
% FC-TRC is calculated in each subset, and then FC-TRC measures from the two subsets are compared. 
% Parcel RSFC matrices are compared by correlating the upper triangles of the matrix for each person

% For 200 parcels
wbcommand = '/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

% Assume each session contributes an equal number of columns
columns_per_session = 410;
tasks = {'task-DORA', 'task-RX', 'task-YT'};

% Loop through each task
for t = 1:length(tasks)
    task = tasks{t};

    % Load and split the child data for each task
    subject = 'C';
    ptseries_C_sessions = cell(26, 4); % 26 subjects x 4 sessions
    for sub = 2:26
        % Construct file path
        file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_200parcels_17nets.ptseries.nii', sub, subject, task);

        try
            % Load data
            data = ciftiopen(file_path, wbcommand);
            data = data.cdata; % Extract cdata

            % Split data into sessions
            for ses = 1:4
                start_col = (ses - 1) * columns_per_session + 1;
                end_col = ses * columns_per_session;
                ptseries_C_sessions{sub, ses} = data(:, start_col:end_col);
            end
        catch
            fprintf('Error: file does not exist for subject %d\n', sub);
        end
    end
    assignin('base', sprintf('ptseries_C_sessions_%s', task(6:end)), ptseries_C_sessions);

    % Load and split the parent data for each task
    subject = 'P';
    ptseries_P_sessions = cell(26, 4); % 26 subjects x 4 sessions
    for sub = 2:26
        % Construct file path
        file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_200parcels_17nets.ptseries.nii', sub, subject, task);

        try
            % Load data
            data = ciftiopen(file_path, wbcommand);
            data = data.cdata; % Extract cdata

            % Split data into sessions
            for ses = 1:4
                start_col = (ses - 1) * columns_per_session + 1;
                end_col = ses * columns_per_session;
                ptseries_P_sessions{sub, ses} = data(:, start_col:end_col);
            end
        catch
            fprintf('Error: file does not exist for subject %d\n', sub);
        end
    end
    assignin('base', sprintf('ptseries_P_sessions_%s', task(6:end)), ptseries_P_sessions);
end


%% Remove motion volumes using FD>0.15mm threshold

% Define threshold for high motion
threshold = 0.15;

% Define your sessions and updated tasks with two variants for each original task
sessions = {'ses-1', 'ses-2', 'ses-3', 'ses-4'};
original_tasks = {'DORA', 'RX', 'YT'};
sub_tasks = {'1', '2'}; % Two sub-tasks for each original task

% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Assume each sub-task has an equal number of volumes
num_volumes_per_sub_task = 205;

% Subject types
subject_types = {'C', 'P'};

% Process each subject type and number
for type = subject_types
    for sub = subject_numbers
        % Create subject identifier with appropriate leading zeros
        subject_identifier = sprintf('19730%02d%s', sub, type{1});

        % Process each session
        for ses = 1:4
            % Loop over each original task
            for t = 1:length(original_tasks)
                task = original_tasks{t};
                
                % Select the appropriate session data
                data_variable_name = sprintf('ptseries_%s_sessions_%s', type{1}, task);
                sub_data = eval([data_variable_name '{sub, ses}']);

                % Initialize the full columns to remove for this session
                full_columns_to_remove = [];

                % Process each sub-task
                for st = 1:length(sub_tasks)
                    sub_task = sub_tasks{st};
                    task_with_sub = [task sub_task]; % Combine task with its sub-task
                    
                    % Initialize the indices of columns to remove for this sub-task
                    columns_to_remove = [];

                    % Handle the special case for sub-1973024P and ses-6
                    session_id = sessions{ses};
                    if strcmp(subject_identifier, '1973024P') && ses == 4
                        session_id = 'ses-6';
                    end

                    % Construct the CSV file path for the current session and sub-task
                    csv_file_path = sprintf('/Volumes/Prckids/sub-%s/%s/func/sub-%s_%s_task-%s_echo-2_PowerFDFlt.csv', subject_identifier, session_id, subject_identifier, session_id, task_with_sub);

                    % Load the motion parameters from the CSV file
                    try
                        fd = readtable(csv_file_path);
                    catch
                        warning('Unable to read file: %s', csv_file_path);
                        continue;
                    end

                    % Find volumes with high motion for this sub-task
                    high_motion_volumes = find(fd.FD > threshold);

                    % Adjust the indices for the current sub-task
                    adjusted_indices = high_motion_volumes + (st - 1) * num_volumes_per_sub_task;
                    columns_to_remove = [columns_to_remove; adjusted_indices];
                    
                    % Append to the full columns to remove for this session
                    full_columns_to_remove = [full_columns_to_remove; columns_to_remove];
                end

                % Remove duplicates and sort the indices for the full session
                full_columns_to_remove = unique(sort(full_columns_to_remove));

                % Remove the high motion columns for this session
                for idx = length(full_columns_to_remove):-1:1
                    if full_columns_to_remove(idx) <= size(sub_data, 2)
                        sub_data(:, full_columns_to_remove(idx)) = [];
                    else
                        warning('Attempted to remove a column that does not exist. Index: %d', full_columns_to_remove(idx));
                    end
                end

                % Store the cleaned data back
                eval([data_variable_name '{sub, ses} = sub_data;']);
            end
        end
    end
end


%% Remove SNR regions

% Open SNR mask computed from Midnight Scan Avg
snrMask = ciftiopen('/Users/shefalirai/Desktop/MSCavg_SNRmask_200parcelled.ptseries.nii', wbcommand);
snrMask_data = snrMask.cdata;

% List of subject numbers (excluding subject 3)
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Subject types
subject_types = {'C', 'P'};

% List of tasks
tasks = {'DORA', 'RX', 'YT'};

% Apply the mask to each session for each subject and each task
for type = subject_types
    for sub = subject_numbers
        for ses = 1:4
            for task = tasks
                % Construct the variable name for the task-specific cell array
                data_variable_name = sprintf('ptseries_%s_sessions_%s', type{1}, task{1});
                
                % Check if data is available for this subject, session, and task
                if eval(sprintf('size(%s, 1) >= sub && ~isempty(%s{sub, ses})', data_variable_name, data_variable_name))
                    % Apply the mask
                    masked_data = eval(sprintf('%s{sub, ses}', data_variable_name));
                    masked_data(snrMask_data > 0, :) = NaN;
                    eval(sprintf('%s{sub, ses} = masked_data;', data_variable_name));
                end
            end
        end
    end
end


%% Create first and last half session before creating connectomes

% Initialize new variables for combined sessions across all tasks
ptseries_C_combined1 = cell(26, 1); % Combining sessions 1 and 4 across all tasks
ptseries_C_combined2 = cell(26, 1); % Combining sessions 2 and 3 across all tasks
ptseries_P_combined1 = cell(26, 1); % Combining sessions 1 and 4 across all tasks
ptseries_P_combined2 = cell(26, 1); % Combining sessions 2 and 3 across all tasks

% List of tasks
tasks = {'DORA', 'RX', 'YT'};

% Combine sessions for each subject across all tasks
for sub = subject_numbers
    % Initialize temporary variables to store combined data for this subject
    temp_C_combined1 = [];
    temp_C_combined2 = [];
    temp_P_combined1 = [];
    temp_P_combined2 = [];

    for task = tasks
        % Construct the variable name for the task-specific cell array
        data_variable_name_C = sprintf('ptseries_C_sessions_%s', task{1});
        data_variable_name_P = sprintf('ptseries_P_sessions_%s', task{1});
        
        % Combine for Child subjects
        temp_C_combined1 = [temp_C_combined1, eval(sprintf('cat(2, %s{sub, [1, 4]})', data_variable_name_C))];
        temp_C_combined2 = [temp_C_combined2, eval(sprintf('cat(2, %s{sub, [2, 3]})', data_variable_name_C))];
        
        % Combine for Parent subjects
        temp_P_combined1 = [temp_P_combined1, eval(sprintf('cat(2, %s{sub, [1, 4]})', data_variable_name_P))];
        temp_P_combined2 = [temp_P_combined2, eval(sprintf('cat(2, %s{sub, [2, 3]})', data_variable_name_P))];
    end

    % Assign the temporary combined data to the final combined variables
    ptseries_C_combined1{sub} = temp_C_combined1;
    ptseries_C_combined2{sub} = temp_C_combined2;
    ptseries_P_combined1{sub} = temp_P_combined1;
    ptseries_P_combined2{sub} = temp_P_combined2;
end


%% Reorder ptseries P and C based on low/high motion indices
% Split the motion histogram in half to include 24 subjects for low motion and 24 subjects for high motion variables
% List of tasks

load('PKdata_lowhighmotion_ordered.mat');

% Rows to extract for low motion
low_motion_rows_C = low_motion_C;
low_motion_rows_P = low_motion_P;

% Get indices of high motion rows
high_motion_rows_C = high_motion_C;
high_motion_rows_P = high_motion_P;

% Extract low motion and high motion rows for C and P_combined1/2
ptseries_C_lowmotion_combined1 = ptseries_C_combined1(low_motion_rows_C);
ptseries_P_lowmotion_combined1 = ptseries_P_combined1(low_motion_rows_P);

ptseries_C_lowmotion_combined2 = ptseries_C_combined2(low_motion_rows_C);
ptseries_P_lowmotion_combined2 = ptseries_P_combined2(low_motion_rows_P);

ptseries_C_highmotion_combined1 = ptseries_C_combined1(high_motion_rows_C);
ptseries_P_highmotion_combined1 = ptseries_P_combined1(high_motion_rows_P);

ptseries_C_highmotion_combined2 = ptseries_C_combined2(high_motion_rows_C);
ptseries_P_highmotion_combined2 = ptseries_P_combined2(high_motion_rows_P);



%% Calculate scan_length and reliability for CHILDREN

% Initialize the cell array for storing the matrices with the largest column size
scan_length_max_lowmotion_C = cell(1, numel(ptseries_C_lowmotion_combined1));
scan_length_max_highmotion_C = cell(1, numel(ptseries_C_highmotion_combined1));

for i = 1:numel(ptseries_C_lowmotion_combined1)
    % Get the size of the matrices in the current cells
    size_firstfourth_lowmotion_C = size(ptseries_C_lowmotion_combined1{i});
    size_secondthird_lowmotion_C = size(ptseries_C_lowmotion_combined2{i});
    
    size_firstfourth_highmotion_C = size(ptseries_C_highmotion_combined1{i});
    size_secondthird_highmotion_C = size(ptseries_C_highmotion_combined2{i});
    
    % Compare the column sizes and store the matrix with the largest column size
    if size_firstfourth_lowmotion_C(2) >= size_secondthird_lowmotion_C(2)
        scan_length_max_lowmotion_C{i} = size(ptseries_C_lowmotion_combined1{i},2);
    else
        scan_length_max_lowmotion_C{i} = size(ptseries_C_lowmotion_combined2{i},2);
    end
    
    if size_firstfourth_highmotion_C(2) >= size_secondthird_highmotion_C(2)
        scan_length_max_highmotion_C{i} = size(ptseries_C_highmotion_combined1{i},2);
    else
        scan_length_max_highmotion_C{i} = size(ptseries_C_highmotion_combined2{i},2);
    end
end

% Define the increment for the scan length, 5 minutes
% 150 volumes is 5 mins, 30 volumes is 1 min
scan_length_increment = 30;

% Initialize the reliability_scanlength_cell cell array
reliability_scanlength_cell_lowmotion_C = cell(1, numel(ptseries_C_lowmotion_combined1));
reliability_scanlength_cell_highmotion_C = cell(1, numel(ptseries_C_highmotion_combined1));

% Outer loop for each subject
for j = 1:numel(ptseries_C_lowmotion_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_C_lowmotion_combined1{j}) && ~isempty(ptseries_C_lowmotion_combined2{j})
        % Calculate scan_length_max for the current subject
        scan_length_max_lowmotion_subject_C = max(size(ptseries_C_lowmotion_combined1{j}, 2), size(ptseries_C_lowmotion_combined2{j}, 2));

        % Initialize reliability_scanlength for the current subject
        reliability_scanlength_lowmotion_C = zeros(1, ceil(scan_length_max_lowmotion_subject_C / scan_length_increment));

        % Inner loop through increments for the scan length
        for i = scan_length_increment:scan_length_increment:scan_length_max_lowmotion_subject_C
            % Ensure the loop index is within bounds for scan_length_max
            if i > scan_length_max_lowmotion_subject_C
                break;
            end

            % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_lowmotion_C = ptseries_C_lowmotion_combined1{j}(:, 1:min(i, size(ptseries_C_lowmotion_combined1{j}, 2)));
            ptseries_secondthird_columns_lowmotion_C = ptseries_C_lowmotion_combined2{j}(:, 1:min(i, size(ptseries_C_lowmotion_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_lowmotion_C = corr(ptseries_firstfourth_columns_lowmotion_C');
            ptseries_secondthird_connectome_lowmotion_C = corr(ptseries_secondthird_columns_lowmotion_C');

            ptseries_corr_allses_lowmotion_C = zeros(1, size(ptseries_firstfourth_connectome_lowmotion_C, 1));

            % Remove NaNs
            ptseries_firstfourth_connectome_lowmotion_C(isnan(ptseries_firstfourth_connectome_lowmotion_C)) = 0;
            ptseries_secondthird_connectome_lowmotion_C(isnan(ptseries_secondthird_connectome_lowmotion_C)) = 0;

            % Correlate
            for r = 1:size(ptseries_firstfourth_connectome_lowmotion_C, 1)
                ptseries_corr_allses_lowmotion_C(r) = corr(ptseries_firstfourth_connectome_lowmotion_C(r, :)', ptseries_secondthird_connectome_lowmotion_C(r, :)');
            end


            % Store the mean correlation for the current scan length
            reliability_scanlength_lowmotion_C(i/scan_length_increment) = nanmean(ptseries_corr_allses_lowmotion_C);
        end

        % Store reliability_scanlength for the current subject
        reliability_scanlength_cell_lowmotion_C{j} = reliability_scanlength_lowmotion_C;
    end
end

% Outer loop for each subject
for j = 1:numel(ptseries_C_highmotion_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_C_highmotion_combined1{j}) && ~isempty(ptseries_C_highmotion_combined2{j})
        % Calculate scan_length_max for the current subject
        scan_length_max_highmotion_subject_C = max(size(ptseries_C_highmotion_combined1{j}, 2), size(ptseries_C_highmotion_combined2{j}, 2));

        % Initialize reliability_scanlength for the current subject
        reliability_scanlength_highmotion_C = zeros(1, ceil(scan_length_max_highmotion_subject_C / scan_length_increment));

        % Inner loop through increments for the scan length
        for i = scan_length_increment:scan_length_increment:scan_length_max_highmotion_subject_C
            % Ensure the loop index is within bounds for scan_length_max
            if i > scan_length_max_highmotion_subject_C
                break;
            end

            % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_highmotion_C = ptseries_C_highmotion_combined1{j}(:, 1:min(i, size(ptseries_C_highmotion_combined1{j}, 2)));
            ptseries_secondthird_columns_highmotion_C = ptseries_C_highmotion_combined2{j}(:, 1:min(i, size(ptseries_C_highmotion_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_highmotion_C = corr(ptseries_firstfourth_columns_highmotion_C');
            ptseries_secondthird_connectome_highmotion_C = corr(ptseries_secondthird_columns_highmotion_C');

            ptseries_corr_all_highmotion_C = zeros(1, size(ptseries_firstfourth_connectome_highmotion_C, 1));

            % Remove NaNs
            ptseries_firstfourth_connectome_highmotion_C(isnan(ptseries_firstfourth_connectome_highmotion_C)) = 0;
            ptseries_secondthird_connectome_highmotion_C(isnan(ptseries_secondthird_connectome_highmotion_C)) = 0;

            % Correlate FC-TRC
            for r = 1:size(ptseries_firstfourth_connectome_highmotion_C, 1)
                ptseries_corr_all_highmotion_C(r) = corr(ptseries_firstfourth_connectome_highmotion_C(r, :)', ptseries_secondthird_connectome_highmotion_C(r, :)');
            end


            % Store the mean correlation for the current scan length
            reliability_scanlength_highmotion_C(i/scan_length_increment) = nanmean(ptseries_corr_all_highmotion_C);
        end

        % Store reliability_scanlength for the current subject
        reliability_scanlength_cell_highmotion_C{j} = reliability_scanlength_highmotion_C;
    end
end

% Remove trailing zeros for each subject in reliability_scanlength_cell
for j = 1:numel(reliability_scanlength_cell_lowmotion_C)
    reliability_scanlength_cell_lowmotion_C{j} = reliability_scanlength_cell_lowmotion_C{j}(reliability_scanlength_cell_lowmotion_C{j} ~= 0);
end

for j = 1:numel(reliability_scanlength_cell_highmotion_C)
    reliability_scanlength_cell_highmotion_C{j} = reliability_scanlength_cell_highmotion_C{j}(reliability_scanlength_cell_highmotion_C{j} ~= 0);
end



%% Find mean and standard deviation of all 24 CHILDREN

% Find the shortest length for both conditions
min_length_lowmotion_C = min(cellfun('prodofsize', reliability_scanlength_cell_lowmotion_C(~cellfun('isempty', reliability_scanlength_cell_lowmotion_C))));
min_length_highmotion_C = min(cellfun('prodofsize', reliability_scanlength_cell_highmotion_C(~cellfun('isempty', reliability_scanlength_cell_highmotion_C))));
min_length_C = min(min_length_lowmotion_C, min_length_highmotion_C);

% Create matrices with matched lengths for both conditions
matched_matrix_lowmotion_C = nan(numel(reliability_scanlength_cell_lowmotion_C), min_length_C);
matched_matrix_highmotion_C = nan(numel(reliability_scanlength_cell_highmotion_C), min_length_C);

% Populate the matched matrices for condition lowmotion
for i = 1:numel(reliability_scanlength_cell_lowmotion_C)
    current_data = reliability_scanlength_cell_lowmotion_C{i};
    if ~isempty(current_data)
        matched_matrix_lowmotion_C(i, 1:numel(current_data)) = current_data;
    end
end

% Populate the matched matrices for condition highmotion
for i = 1:numel(reliability_scanlength_cell_highmotion_C)
    current_data = reliability_scanlength_cell_highmotion_C{i};
    if ~isempty(current_data)
        matched_matrix_highmotion_C(i, 1:numel(current_data)) = current_data;
    end
end


% Replace 0 values with NaN in matched_matrix_C
matched_matrix_lowmotion_C(matched_matrix_lowmotion_C == 0) = NaN;

% Replace 0 values with NaN in matched_matrix_P
matched_matrix_highmotion_C(matched_matrix_highmotion_C == 0) = NaN;

% Calculate the mean of each corresponding element across cells for both conditions
mean_values_lowmotion_C = mean(matched_matrix_lowmotion_C, 'omitnan');
mean_values_highmotion_C = mean(matched_matrix_highmotion_C, 'omitnan');

mean_values_highmotion_C = mean_values_highmotion_C(mean_values_highmotion_C ~= 0);

% Calculate the standard deviation of each corresponding element across cells for both conditions
std_values_highmotion_C = std(matched_matrix_highmotion_C, 'omitnan');
std_values_lowmotion_C = std(matched_matrix_lowmotion_C, 'omitnan');

std_values_highmotion_C = std_values_highmotion_C(std_values_highmotion_C ~= 0);

%% Calculate scan_length and reliability for PARENTS

% Initialize the cell array for storing the matrices with the largest column size
scan_length_max_lowmotion_P = cell(1, numel(ptseries_P_lowmotion_combined1));
scan_length_max_highmotion_P = cell(1, numel(ptseries_P_highmotion_combined1));

for i = 1:numel(ptseries_P_lowmotion_combined1)
    % Get the size of the matrices in the current cells
    size_firstfourth_lowmotion_P = size(ptseries_P_lowmotion_combined1{i});
    size_secondthird_lowmotion_P = size(ptseries_P_lowmotion_combined2{i});
    
    size_firstfourth_highmotion_P = size(ptseries_P_highmotion_combined1{i});
    size_secondthird_highmotion_P = size(ptseries_P_highmotion_combined2{i});
    
    % Compare the column sizes and store the matrix with the largest column size
    if size_firstfourth_lowmotion_P(2) >= size_secondthird_lowmotion_P(2)
        scan_length_max_lowmotion_P{i} = size(ptseries_P_lowmotion_combined1{i},2);
    else
        scan_length_max_lowmotion_P{i} = size(ptseries_P_lowmotion_combined2{i},2);
    end
    
    if size_firstfourth_highmotion_P(2) >= size_secondthird_highmotion_P(2)
        scan_length_max_highmotion_P{i} = size(ptseries_P_highmotion_combined1{i},2);
    else
        scan_length_max_highmotion_P{i} = size(ptseries_P_highmotion_combined2{i},2);
    end
end

% Define the increment for the scan length, 5 minutes
% 150 volumes is 5 mins, 30 volumes is 1 min
scan_length_increment = 30;

% Initialize the reliability_scanlength_cell cell array
reliability_scanlength_cell_lowmotion_P = cell(1, numel(ptseries_P_lowmotion_combined1));
reliability_scanlength_cell_highmotion_P = cell(1, numel(ptseries_P_highmotion_combined1));

% Outer loop for each subject
for j = 1:numel(ptseries_P_lowmotion_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_P_lowmotion_combined1{j}) && ~isempty(ptseries_P_lowmotion_combined2{j})
        % Calculate scan_length_max for the current subject
        scan_length_max_lowmotion_subject_P = max(size(ptseries_P_lowmotion_combined1{j}, 2), size(ptseries_P_lowmotion_combined2{j}, 2));

        % Initialize reliability_scanlength for the current subject
        reliability_scanlength_lowmotion_P = zeros(1, ceil(scan_length_max_lowmotion_subject_P / scan_length_increment));

        % Inner loop through increments for the scan length
        for i = scan_length_increment:scan_length_increment:scan_length_max_lowmotion_subject_P
            % Ensure the loop index is within bounds for scan_length_max
            if i > scan_length_max_lowmotion_subject_P
                break;
            end

            % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_lowmotion_P = ptseries_P_lowmotion_combined1{j}(:, 1:min(i, size(ptseries_P_lowmotion_combined1{j}, 2)));
            ptseries_secondthird_columns_lowmotion_P = ptseries_P_lowmotion_combined2{j}(:, 1:min(i, size(ptseries_P_lowmotion_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_lowmotion_P = corr(ptseries_firstfourth_columns_lowmotion_P');
            ptseries_secondthird_connectome_lowmotion_P = corr(ptseries_secondthird_columns_lowmotion_P');

            ptseries_corr_allses_lowmotion_P = zeros(1, size(ptseries_firstfourth_connectome_lowmotion_P, 1));

            % Remove NaNs
            ptseries_firstfourth_connectome_lowmotion_P(isnan(ptseries_firstfourth_connectome_lowmotion_P)) = 0;
            ptseries_secondthird_connectome_lowmotion_P(isnan(ptseries_secondthird_connectome_lowmotion_P)) = 0;

            % Correlate
            for r = 1:size(ptseries_firstfourth_connectome_lowmotion_P, 1)
                ptseries_corr_allses_lowmotion_P(r) = corr(ptseries_firstfourth_connectome_lowmotion_P(r, :)', ptseries_secondthird_connectome_lowmotion_P(r, :)');
            end


            % Store the mean correlation for the current scan length
            reliability_scanlength_lowmotion_P(i/scan_length_increment) = nanmean(ptseries_corr_allses_lowmotion_P);
        end

        % Store reliability_scanlength for the current subject
        reliability_scanlength_cell_lowmotion_P{j} = reliability_scanlength_lowmotion_P;
    end
end

% Outer loop for each subject
for j = 1:numel(ptseries_P_highmotion_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_P_highmotion_combined1{j}) && ~isempty(ptseries_P_highmotion_combined2{j})
        % Calculate scan_length_max for the current subject
        scan_length_max_highmotion_subject_P = max(size(ptseries_P_highmotion_combined1{j}, 2), size(ptseries_P_highmotion_combined2{j}, 2));

        % Initialize reliability_scanlength for the current subject
        reliability_scanlength_highmotion_P = zeros(1, ceil(scan_length_max_highmotion_subject_P / scan_length_increment));

        % Inner loop through increments for the scan length
        for i = scan_length_increment:scan_length_increment:scan_length_max_highmotion_subject_P
            % Ensure the loop index is within bounds for scan_length_max
            if i > scan_length_max_highmotion_subject_P
                break;
            end

            % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_highmotion_P = ptseries_P_highmotion_combined1{j}(:, 1:min(i, size(ptseries_P_highmotion_combined1{j}, 2)));
            ptseries_secondthird_columns_highmotion_P = ptseries_P_highmotion_combined2{j}(:, 1:min(i, size(ptseries_P_highmotion_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_highmotion_P = corr(ptseries_firstfourth_columns_highmotion_P');
            ptseries_secondthird_connectome_highmotion_P = corr(ptseries_secondthird_columns_highmotion_P');

            ptseries_corr_all_highmotion_P = zeros(1, size(ptseries_firstfourth_connectome_highmotion_P, 1));

            % Remove NaNs
            ptseries_firstfourth_connectome_highmotion_P(isnan(ptseries_firstfourth_connectome_highmotion_P)) = 0;
            ptseries_secondthird_connectome_highmotion_P(isnan(ptseries_secondthird_connectome_highmotion_P)) = 0;

            % Correlate FC-TRC
            for r = 1:size(ptseries_firstfourth_connectome_highmotion_P, 1)
                ptseries_corr_all_highmotion_P(r) = corr(ptseries_firstfourth_connectome_highmotion_P(r, :)', ptseries_secondthird_connectome_highmotion_P(r, :)');
            end


            % Store the mean correlation for the current scan length
            reliability_scanlength_highmotion_P(i/scan_length_increment) = nanmean(ptseries_corr_all_highmotion_P);
        end

        % Store reliability_scanlength for the current subject
        reliability_scanlength_cell_highmotion_P{j} = reliability_scanlength_highmotion_P;
    end
end

% Remove trailing zeros for each subject in reliability_scanlength_cell
for j = 1:numel(reliability_scanlength_cell_lowmotion_P)
    reliability_scanlength_cell_lowmotion_P{j} = reliability_scanlength_cell_lowmotion_P{j}(reliability_scanlength_cell_lowmotion_P{j} ~= 0);
end

for j = 1:numel(reliability_scanlength_cell_highmotion_P)
    reliability_scanlength_cell_highmotion_P{j} = reliability_scanlength_cell_highmotion_P{j}(reliability_scanlength_cell_highmotion_P{j} ~= 0);
end



%% Find mean and standard deviation of all 24 PARENTS

% Find the shortest length for both conditions
min_length_lowmotion_P = min(cellfun('prodofsize', reliability_scanlength_cell_lowmotion_P(~cellfun('isempty', reliability_scanlength_cell_lowmotion_P))));
min_length_highmotion_P = min(cellfun('prodofsize', reliability_scanlength_cell_highmotion_P(~cellfun('isempty', reliability_scanlength_cell_highmotion_P))));
min_length_P = min(min_length_lowmotion_P, min_length_highmotion_P);

% Create matrices with matched lengths for both conditions
matched_matrix_lowmotion_P = nan(numel(reliability_scanlength_cell_lowmotion_P), min_length_P);
matched_matrix_highmotion_P = nan(numel(reliability_scanlength_cell_highmotion_P), min_length_P);

% Populate the matched matrices for condition lowmotion
for i = 1:numel(reliability_scanlength_cell_lowmotion_P)
    current_data = reliability_scanlength_cell_lowmotion_P{i};
    if ~isempty(current_data)
        matched_matrix_lowmotion_P(i, 1:numel(current_data)) = current_data;
    end
end

% Populate the matched matrices for condition highmotion
for i = 1:numel(reliability_scanlength_cell_highmotion_P)
    current_data = reliability_scanlength_cell_highmotion_P{i};
    if ~isempty(current_data)
        matched_matrix_highmotion_P(i, 1:numel(current_data)) = current_data;
    end
end


% Replace 0 values with NaN in matched_matrix_P
matched_matrix_lowmotion_P(matched_matrix_lowmotion_P == 0) = NaN;

% Replace 0 values with NaN in matched_matrix_P
matched_matrix_highmotion_P(matched_matrix_highmotion_P == 0) = NaN;

% Calculate the mean of each corresponding element across cells for both conditions
mean_values_lowmotion_P = mean(matched_matrix_lowmotion_P, 'omitnan');
mean_values_highmotion_P = mean(matched_matrix_highmotion_P, 'omitnan');

mean_values_highmotion_P = mean_values_highmotion_P(mean_values_highmotion_P ~= 0);

% Calculate the standard deviation of each corresponding element across cells for both conditions
std_values_highmotion_P = std(matched_matrix_highmotion_P, 'omitnan');
std_values_lowmotion_P = std(matched_matrix_lowmotion_P, 'omitnan');

std_values_highmotion_P = std_values_highmotion_P(std_values_highmotion_P ~= 0);


%% Plot and add dotted line where R=0.7 for all 4 groups 


% Find the indices where the curves first meet 0.7
index_lowmotion_C = find(mean_values_lowmotion_C >= 0.7, 1, 'first');
index_highmotion_C = find(mean_values_highmotion_C >= 0.7, 1, 'first');
index_lowmotion_P = find(mean_values_lowmotion_P >= 0.7, 1, 'first');
index_highmotion_P = find(mean_values_highmotion_P >= 0.7, 1, 'first');

% Define x-axis values based on the scan length increments
x_axis_max_lowmotion_C = max(cell2mat(scan_length_max_lowmotion_C));
x_axis_max_highmotion_C = max(cell2mat(scan_length_max_highmotion_C));
x_axis_C = (scan_length_increment * 6 / 180):(scan_length_increment * 6 / 180):(x_axis_max_lowmotion_C * 6 / 180);


% Plot the mean with standard deviation as error bars for both conditions
figure;
h1 = errorbar(x_axis_C, mean_values_highmotion_C, std_values_highmotion_C, 'LineWidth', 2, 'Color', 'blue');
hold on;
h2 = errorbar(x_axis_C, mean_values_lowmotion_C, std_values_lowmotion_C, 'LineWidth', 2, 'Color', 'magenta');
hold on;
h3 = errorbar(x_axis_C, mean_values_highmotion_P, std_values_highmotion_P, 'LineWidth', 2, 'Color', 'cyan');
hold on;
h4 = errorbar(x_axis_C, mean_values_lowmotion_P, std_values_lowmotion_P, 'LineWidth', 2, 'Color', 'red');

% Add dotted vertical lines at the points where each curve first meets 0.7
plot([x_axis_C(index_highmotion_C), x_axis_C(index_highmotion_C)], [0, mean_values_highmotion_C(index_highmotion_C)], '--', 'LineWidth', 1.5, 'Color', 'blue');
plot([x_axis_C(index_lowmotion_C), x_axis_C(index_lowmotion_C)], [0, mean_values_lowmotion_C(index_lowmotion_C)], '--', 'LineWidth', 1.5, 'Color', 'magenta');
plot([x_axis_C(index_highmotion_P), x_axis_C(index_highmotion_P)], [0, mean_values_highmotion_P(index_highmotion_P)], '--', 'LineWidth', 1.5, 'Color', 'cyan');
plot([x_axis_C(index_lowmotion_P), x_axis_C(index_lowmotion_P)], [0, mean_values_lowmotion_P(index_lowmotion_P)], '--', 'LineWidth', 1.5, 'Color', 'red');

hold off;

xlabel('Scan Length (minutes)');
ylabel('Mean FC-TRC');
xlim([1, 60])
legend({'High Motion Child', 'Low Motion Child', 'High Motion Adult', 'Low Motion Adult'}, 'FontSize', 20, 'Location', 'northwest');
set(gca, 'FontSize', 20);
% Set the font type
set(gca, 'FontName', 'Arial');
% Remove the top and right axis lines
ax = gca;
ax.Box = 'off';

