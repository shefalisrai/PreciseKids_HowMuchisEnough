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



%% Determine connectome volumes for each participant based on their time to reach r>/0.7

%Load matched matrix from low/high motion groups (12 participants each)
load('PKdata_matchedmatrix_lowhighmotion_CP.mat');
load('PKdata_lowhighmotion_ordered.mat');

% Find the indices where the reliability first meets 0.7 for each row
[~, Timeat7_lowmotion_C_indices] = max(matched_matrix_lowmotion_C >= 0.7, [], 2);
[~, Timeat7_highmotion_C_indices] = max(matched_matrix_highmotion_C >= 0.7, [], 2);
[~, Timeat7_lowmotion_P_indices] = max(matched_matrix_lowmotion_P >= 0.7, [], 2);
[~, Timeat7_highmotion_P_indices] = max(matched_matrix_highmotion_P >= 0.7, [], 2);


%% High Motion Children 

% Combine subject and time variables
Timeat7_highmotion_C_subjects = [Timeat7_highmotion_C_indices high_motion_C'];

% Total uncensored volumes acquired for all subjects
uncensored_total = 1640;

% Initialize arrays to store results
uncensored_Timeat7_combinedtotal_highmotion_C = zeros(12, 1);

% Loop over subjects
for j = 1:12
    % Convert minutes to volumes
    i = (Timeat7_highmotion_C_subjects(j, 1)) * 60 / 2;
    
    % Total censored volumes acquired for a specific subject for both split halves
    censored_total_C_highmotion_combined1 = size(ptseries_C_highmotion_combined1{j}, 2);
    censored_total_C_highmotion_combined2 = size(ptseries_C_highmotion_combined2{j}, 2);

    % Censored volumes used to reach time at reliability >=0.7 
    censored_Timeat7 = i;

    % Calculate uncensored volumes needed to reach time at reliability >=0.7
    uncensored_Timeat7_C_highmotion_combined1 = (uncensored_total * censored_Timeat7) / censored_total_C_highmotion_combined1;
    uncensored_Timeat7_C_highmotion_combined2 = (uncensored_total * censored_Timeat7) / censored_total_C_highmotion_combined2;

    uncensored_Timeat7_combinedtotal_highmotion_C(j) = round(uncensored_Timeat7_C_highmotion_combined1 + uncensored_Timeat7_C_highmotion_combined2);
end

%% Calcualte uncensored time to reach reliability >= 0.7 for each of the 4 low and high motion groups

% Combine subject and time variables for all motion groups
Timeat7_highmotion_C_subjects = [Timeat7_highmotion_C_indices high_motion_C'];
Timeat7_highmotion_P_subjects = [Timeat7_highmotion_P_indices high_motion_P'];
Timeat7_lowmotion_C_subjects = [Timeat7_lowmotion_C_indices low_motion_C'];
Timeat7_lowmotion_P_subjects = [Timeat7_lowmotion_P_indices low_motion_P'];

% Total uncensored volumes acquired for all subjects
uncensored_total = 1640;

% Initialize arrays to store results for each motion group
uncensored_Timeat7_combinedtotal_highmotion_C = zeros(12, 1);
uncensored_Timeat7_combinedtotal_highmotion_P = zeros(12, 1);
uncensored_Timeat7_combinedtotal_lowmotion_C = zeros(12, 1);
uncensored_Timeat7_combinedtotal_lowmotion_P = zeros(12, 1);

% Loop over subjects for each motion group
for j = 1:12
    % Convert minutes to volumes for each motion group
    i_high_C = (Timeat7_highmotion_C_subjects(j, 1)) * 60 / 2;
    i_high_P = (Timeat7_highmotion_P_subjects(j, 1)) * 60 / 2;
    i_low_C = (Timeat7_lowmotion_C_subjects(j, 1)) * 60 / 2;
    i_low_P = (Timeat7_lowmotion_P_subjects(j, 1)) * 60 / 2;
    
    % Total censored volumes acquired for a specific subject for both split halves for each motion group
    censored_total_high_C_combined1 = size(ptseries_C_highmotion_combined1{j}, 2);
    censored_total_high_C_combined2 = size(ptseries_C_highmotion_combined2{j}, 2);
    censored_total_high_P_combined1 = size(ptseries_P_highmotion_combined1{j}, 2);
    censored_total_high_P_combined2 = size(ptseries_P_highmotion_combined2{j}, 2);
    censored_total_low_C_combined1 = size(ptseries_C_lowmotion_combined1{j}, 2);
    censored_total_low_C_combined2 = size(ptseries_C_lowmotion_combined2{j}, 2);
    censored_total_low_P_combined1 = size(ptseries_P_lowmotion_combined1{j}, 2);
    censored_total_low_P_combined2 = size(ptseries_P_lowmotion_combined2{j}, 2);

    % Censored volumes used to reach time at reliability >=0.7 
    censored_Timeat7_high_C = i_high_C;
    censored_Timeat7_high_P = i_high_P;
    censored_Timeat7_low_C = i_low_C;
    censored_Timeat7_low_P = i_low_P;

    % Calculate uncensored volumes needed to reach time at reliability >=0.7 for each motion group
    uncensored_Timeat7_high_C_combined1 = (uncensored_total * censored_Timeat7_high_C) / censored_total_high_C_combined1;
    uncensored_Timeat7_high_C_combined2 = (uncensored_total * censored_Timeat7_high_C) / censored_total_high_C_combined2;
    uncensored_Timeat7_high_P_combined1 = (uncensored_total * censored_Timeat7_high_P) / censored_total_high_P_combined1;
    uncensored_Timeat7_high_P_combined2 = (uncensored_total * censored_Timeat7_high_P) / censored_total_high_P_combined2;
    uncensored_Timeat7_low_C_combined1 = (uncensored_total * censored_Timeat7_low_C) / censored_total_low_C_combined1;
    uncensored_Timeat7_low_C_combined2 = (uncensored_total * censored_Timeat7_low_C) / censored_total_low_C_combined2;
    uncensored_Timeat7_low_P_combined1 = (uncensored_total * censored_Timeat7_low_P) / censored_total_low_P_combined1;
    uncensored_Timeat7_low_P_combined2 = (uncensored_total * censored_Timeat7_low_P) / censored_total_low_P_combined2;

    uncensored_Timeat7_combinedtotal_highmotion_C(j) = round(uncensored_Timeat7_high_C_combined1 + uncensored_Timeat7_high_C_combined2);
    uncensored_Timeat7_combinedtotal_highmotion_P(j) = round(uncensored_Timeat7_high_P_combined1 + uncensored_Timeat7_high_P_combined2);
    uncensored_Timeat7_combinedtotal_lowmotion_C(j) = round(uncensored_Timeat7_low_C_combined1 + uncensored_Timeat7_low_C_combined2);
    uncensored_Timeat7_combinedtotal_lowmotion_P(j) = round(uncensored_Timeat7_low_P_combined1 + uncensored_Timeat7_low_P_combined2);
end







%% Use code below to check if reliability is accurate at that volume above

% % Extract the first i columns from the matrix for the current subject
% ptseries_firstfourth_columns_highmotion_C = ptseries_C_highmotion_combined1{j}(:, 1: i);
% ptseries_secondthird_columns_highmotion_C = ptseries_C_highmotion_combined2{j}(:, 1: i);
% 
% % Compute correlations for the current subject
% ptseries_firstfourth_connectome_highmotion_C = corr(ptseries_firstfourth_columns_highmotion_C');
% ptseries_secondthird_connectome_highmotion_C = corr(ptseries_secondthird_columns_highmotion_C');
% 
% % Remove NaNs
% ptseries_firstfourth_connectome_highmotion_C(isnan(ptseries_firstfourth_connectome_highmotion_C)) = 0;
% ptseries_secondthird_connectome_highmotion_C(isnan(ptseries_secondthird_connectome_highmotion_C)) = 0;
% 
% % Correlate
% for r = 1:size(ptseries_firstfourth_connectome_highmotion_C, 1)
%       ptseries_corr_allses_highmotion_C(r) = corr(ptseries_firstfourth_connectome_highmotion_C(r, :)', ptseries_secondthird_connectome_highmotion_C(r, :)');
% end
% 
% 
% % Store the mean correlation for the current scan length
% reliability_scanlength_highmotion_C = nanmean(ptseries_corr_allses_highmotion_C);





