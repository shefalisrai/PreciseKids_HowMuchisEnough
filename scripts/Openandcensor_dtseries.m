function Openandcensor_dtseries(subject)
% subject should be either 'P' or 'C'
% subject_types should be either 'P' or 'C';

wbcommand = '/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

% Assume each session contributes an equal number of columns
columns_per_session = 410;
tasks = {'task-DORA', 'task-RX', 'task-YT'};

% Loop through each task
for t = 1:length(tasks)
    task = tasks{t};
 
    % Load and split the parent data for each task
    dtseries_sessions = cell(26, 4); % 26 subjects x 4 sessions
    for sub = 2:26
        % Construct file path
        file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_dtseries/sub-19730%02d%s_%s_allsessions.dtseries.nii', sub, subject, task);

        try
            % Load data
            data = ciftiopen(file_path, wbcommand);
            data = data.cdata; % Extract cdata

            % Split data into sessions
            for ses = 1:4
                start_col = (ses - 1) * columns_per_session + 1;
                end_col = ses * columns_per_session;
                dtseries_sessions{sub, ses} = data(:, start_col:end_col);
            end
        catch
            fprintf('Error: file does not exist for subject %d\n', sub);
        end
    end
    assignin('base', sprintf('dtseries_sessions_%s', task(6:end)), dtseries_sessions);
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

% Process each subject type and number
for sub = subject_numbers
        % Create subject identifier with appropriate leading zeros
        subject_identifier = sprintf('19730%02d%s', sub, subject);

        % Process each session
        for ses = 1:4
            % Loop over each original task
            for t = 1:length(original_tasks)
                task = original_tasks{t};
                
                % Select the appropriate session data
                data_variable_name = sprintf('dtseries_sessions_%s', task);
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
