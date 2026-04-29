function [network_combined1, network_combined2] = Createnetwork_connectomes()

% Create first and last half session before creating connectomes

% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Initialize new variables for combined sessions across all tasks
network_combined1 = cell(26, 1); % Combining sessions 1 and 4 across all tasks
network_combined2 = cell(26, 1); % Combining sessions 2 and 3 across all tasks

% List of tasks
tasks = {'DORA', 'RX', 'YT'};

% Combine sessions for each subject across all tasks
for sub = subject_numbers
    % Initialize temporary variables to store combined data for this subject
    temp_combined1 = [];
    temp_combined2 = [];

    for task = tasks
        % Construct the variable name for the task-specific cell array
        data_variable_name = sprintf('network_%s', task{1});
        
        % Combine 
        temp_combined1 = [temp_combined1, eval(sprintf('cat(2, %s{sub, [1, 4]})', data_variable_name))];
        temp_combined2 = [temp_combined2, eval(sprintf('cat(2, %s{sub, [2, 3]})', data_variable_name))];
    end

    % Assign the temporary combined data to the final combined variables
    network_combined1{sub} = temp_combined1;
    network_combined2{sub} = temp_combined2;
end


