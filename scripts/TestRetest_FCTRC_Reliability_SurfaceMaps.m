%% 200 or 1000 parcel FCTRC reliability surface map for each group 
% 
% % Sub17P has the minimum volume at 709 (~24 mins split half) in ptseries_P_combined2
% % therefore find ptseries_corr at 709 scan length

% Select parcel_num for 200 parcels or 1000parcels
parcel_num=1000;
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
        file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_%dparcels_17nets.ptseries.nii', sub, subject, task, parcel_num);

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
        file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_%dparcels_17nets.ptseries.nii', sub, subject, task, parcel_num);

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


%% 200 or 1000 parcels FC-TRC reliability surface maps

% Create connectomes for C
for j = 1:numel(ptseries_C_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_C_combined1{j}) && ~isempty(ptseries_C_combined2{j})

        % Inner loop through increments for the scan length
        for i = 709
            % Ensure the loop index is within bounds for scan_length_max
            if i > 709
                break;
            end

           % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_C = ptseries_C_combined1{j}(:, 1:min(i, size(ptseries_C_combined1{j}, 2)));
            ptseries_secondthird_columns_C = ptseries_C_combined2{j}(:, 1:min(i, size(ptseries_C_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_C{j} = corr(ptseries_firstfourth_columns_C');
            ptseries_secondthird_connectome_C{j} = corr(ptseries_secondthird_columns_C');

            % Remove NaNs
            ptseries_firstfourth_connectome_C{j}(isnan(ptseries_firstfourth_connectome_C{j})) = 0;
            ptseries_secondthird_connectome_C{j}(isnan(ptseries_secondthird_connectome_C{j})) = 0;

                % Correlate
                for r = 1:size(ptseries_firstfourth_connectome_C{2}, 1)
                    ptseries_corr_allses_C_709volume{j}(r) = corr(ptseries_firstfourth_connectome_C{j}(r, :)', ptseries_secondthird_connectome_C{j}(r, :)');
                end
        end
    end
end

% Create connectomes for P
for j = 1:numel(ptseries_P_combined1)
    % Check if both first and last halves are not empty
    if ~isempty(ptseries_P_combined1{j}) && ~isempty(ptseries_P_combined2{j})

        % Inner loop through increments for the scan length
        for i = 709
            % Ensure the loop index is within bounds for scan_length_max
            if i > 709
                break;
            end

           % Extract the first i columns from the matrix for the current subject
            ptseries_firstfourth_columns_P = ptseries_P_combined1{j}(:, 1:min(i, size(ptseries_P_combined1{j}, 2)));
            ptseries_secondthird_columns_P = ptseries_P_combined2{j}(:, 1:min(i, size(ptseries_P_combined2{j}, 2)));

            % Compute correlations for the current subject
            ptseries_firstfourth_connectome_P{j} = corr(ptseries_firstfourth_columns_P');
            ptseries_secondthird_connectome_P{j} = corr(ptseries_secondthird_columns_P');

            % Remove NaNs
            ptseries_firstfourth_connectome_P{j}(isnan(ptseries_firstfourth_connectome_P{j})) = 0;
            ptseries_secondthird_connectome_P{j}(isnan(ptseries_secondthird_connectome_P{j})) = 0;

                % Correlate
                for r = 1:size(ptseries_firstfourth_connectome_P{2}, 1)
                    ptseries_corr_allses_P_709volume{j}(r) = corr(ptseries_firstfourth_connectome_P{j}(r, :)', ptseries_secondthird_connectome_P{j}(r, :)');
                end
        end
    end
end

%% Calculate the mean across all subjects

% For children
nonEmptyCells = {};

% Iterate over each cell in ptseries_corr_allses_C_709volume
for i = 1:numel(ptseries_corr_allses_C_709volume)
    % Check if the cell is not empty
    if ~isempty(ptseries_corr_allses_C_709volume{i})
        % Add the non-empty matrix to the nonEmptyCells cell array
        nonEmptyCells{end+1} = ptseries_corr_allses_C_709volume{i};
    end
end

% Calculate the overall mean across all subjects
overallMean = nanmean(cat(3, nonEmptyCells{:}), 3);

% Convert the result to a row vector
ptseries_corr_allses_C_709volume_mean = overallMean';

% For parents
nonEmptyCells2 = {};

for i = 1:numel(ptseries_corr_allses_P_709volume)
    % Check if the cell is not empty
    if ~isempty(ptseries_corr_allses_P_709volume{i})
        % Add the non-empty matrix to the nonEmptyCells cell array
        nonEmptyCells2{end+1} = ptseries_corr_allses_P_709volume{i};
    end
end

% Calculate the overall mean across all subjects
overallMean2 = nanmean(cat(3, nonEmptyCells2{:}), 3);

% Convert the result to a row vector
ptseries_corr_allses_P_709volume_mean = overallMean2';


%Open MSC averaged parcellated timseries to replace
subject_cifti=ciftiopen(sprintf('/Users/shefalirai/Desktop/MSCAveraged_Timeseries_%dparcels_17nets.ptseries.nii', parcel_num),wbcommand);

% Replace original .cdata with P&C parcelled reliability values across 200 parcels
subject_cifti.cdata=ptseries_corr_allses_C_709volume_mean;
ciftisavereset(subject_cifti, sprintf('/Users/shefalirai/Desktop/PK_FCTRCs/AvgChild_FCTRCReliability_24minsplithalf_%dparcels_17nets.pscalar.nii', parcel_num), wbcommand);
subject_cifti.cdata=ptseries_corr_allses_P_709volume_mean;
ciftisavereset(subject_cifti, sprintf('/Users/shefalirai/Desktop/PK_FCTRCs/AvgParent_FCTRCReliability_24minsplithalf_%dparcels_17nets.pscalar.nii', parcel_num), wbcommand);


