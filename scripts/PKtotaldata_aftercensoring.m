%Code to calculate how much data is left after censoring FD 0.15mm or
%whatever threshold was used in the script to obtain dtseries variables

%% Children
% Assuming dtseries_C_sessions_DORA, dtseries_C_sessions_YT, and dtseries_C_sessions_RX are already in the workspaces loaded as variables

% Initialize a matrix to store the total time for each subject and task
total_time = zeros(26, 4);

% Loop through subjects
for subject = 1:26
    % Initialize total time for the current subject
    subject_total_time = zeros(1, 3);
    
    % Loop through sessions
    for session = 1:4
        % Skip empty subjects (subject 1 and 3)
        if isempty(dtseries_C_sessions_DORA{subject, session})
            continue;
        end
        
        % Calculate time for each task and sum up
        for task = 1:3
            % Extract time matrix for the current task, session, and subject
            current_time = size(dtseries_C_sessions_DORA{subject, session}, 2);
            if task == 2
                current_time = size(dtseries_C_sessions_YT{subject, session}, 2);
            elseif task == 3
                current_time = size(dtseries_C_sessions_RX{subject, session}, 2);
            end
            
            % Add the current time to the total time for the current subject and task
            subject_total_time(task) = subject_total_time(task) + current_time;
        end
    end
    
    % Calculate total time across all tasks
    total_time(subject, :) = [subject_total_time, sum(subject_total_time)];
end

% Create a table with the total time for each subject and task
subject_ids = (1:26)';
task_names = {'DORA', 'YT', 'RX', 'Total'};
total_time_table_C = array2table(total_time, 'VariableNames', task_names);
total_time_table_C.Subject = subject_ids;

% Display the table
disp(total_time_table_C);

%% Parents

% Assuming dtseries_P_sessions_DORA, dtseries_P_sessions_YT, and dtseries_P_sessions_RX are in your workspace already

% Initialize a matrix to store the total time for each subject and task for the P sessions
total_time_P = zeros(26, 4);

% Loop through subjects
for subject = 1:26
    % Initialize total time for the current subject
    subject_total_time_P = zeros(1, 3);
    
    % Loop through sessions
    for session = 1:4
        % Skip empty subjects (subject 1 and 3)
        if isempty(dtseries_P_sessions_DORA{subject, session})
            continue;
        end
        
        % Calculate time for each task and sum up
        for task = 1:3
            % Extract time matrix for the current task, session, and subject for P sessions
            current_time_P = size(dtseries_P_sessions_DORA{subject, session}, 2);
            if task == 2
                current_time_P = size(dtseries_P_sessions_YT{subject, session}, 2);
            elseif task == 3
                current_time_P = size(dtseries_P_sessions_RX{subject, session}, 2);
            end
            
            % Add the current time to the total time for the current subject and task for P sessions
            subject_total_time_P(task) = subject_total_time_P(task) + current_time_P;
        end
    end
    
    % Calculate total time across all tasks for P sessions
    total_time_P(subject, :) = [subject_total_time_P, sum(subject_total_time_P)];
end

% Create a table with the total time for each subject and task for P sessions
subject_ids = (1:26)';
task_names = {'DORA', 'YT', 'RX', 'Total'};
total_time_table_P = array2table(total_time_P, 'VariableNames', task_names);
total_time_table_P.Subject = subject_ids;

% Display the table for P sessions
disp(total_time_table_P);

%% Bar plot to visualize data after censoring for each subject in each group 

% Extract total time for each subject from both C and P sessions
total_time_C = total_time_table_C.Total;
total_time_P = total_time_table_P.Total;

% Define custom colors for C and P bars using hexadecimal values
color_C = [128, 56, 124] / 255; % Convert from hexadecimal to RGB
color_P = [247, 132, 100] / 255; % Convert from hexadecimal to RGB

% Create a bar plot comparing total time for each subject across C and P sessions with custom colors
figure;
bar(1:26, [total_time_C, total_time_P], 'grouped');
xlabel('Subject');
ylabel('Total Time');
title('Comparison of Total Data kept for all tasks across all sessions (FD>0.15mm)');
set(gca, 'XTick', 1:26); % Set x-axis tick labels
set(gca, 'XTickLabel', 1:26); % Set x-axis tick labels
colormap([color_C; color_P]); % Set custom colors for bars

% Add a horizontal dotted line at y = 4920 max scan length uncensored
hold on;
line([0, 26], [4920*2/60, 4920*2/60], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
hold off;

legend({'Children', 'Adults'}); % Specify legend labels using a cell array

%% Mean Median Range

% Calculate mean, median, and range for Children (C)
mean_C = mean(total_time_C(:));  % Mean for each task
median_C = median(total_time_C(:));  % Median for each task
range_C = range(total_time_C(:));  % Range for each task

% Calculate mean, median, and range for Parents (P)
mean_P = mean(total_time_P(:));  % Mean for each task
median_P = median(total_time_P(:));  % Median for each task
range_P = range(total_time_P(:));  % Range for each task

% Display results
disp("Children (C):");
disp("Mean:");
disp(mean_C);
disp("Median:");
disp(median_C);
disp("Range:");
disp(range_C);

disp("Parents (P):");
disp("Mean:");
disp(mean_P);
disp("Median:");
disp(median_P);
disp("Range:");
disp(range_P);

%% Group mean plot

% Calculate group average for both C and P
group_mean_C = mean(total_time_C)*2/60;
group_mean_P = mean(total_time_P)*2/60;

% Define custom colors for C and P bars using RGB triplets between 0 and 1
color_C = [128, 56, 124] / 255; % Convert from RGB to values between 0 and 1
color_P = [247, 132, 100] / 255; % Convert from RGB to values between 0 and 1

% Create a bar plot comparing group average total time for C and P sessions with custom colors
figure;
bar([group_mean_C, group_mean_P]);
colormap([color_C; color_P]); % Set custom colors for bars
xticklabels({'Children', 'Adults'}); % Set x-axis tick labels
ylabel('Mean Total Time');
title('Comparison of Total Data Kept (FD>0.15mm)');


%% Split data in 4 groups of low and high motion for each C and P

% Extract total time for each subject from both C and P sessions
total_time_C(:,1) = total_time_table_C.Subject;
total_time_P(:,1) = total_time_table_P.Subject;
total_time_C(:,2) = total_time_table_C.Total;
total_time_P(:,2) = total_time_table_P.Total;

% Remove subjects 1 and 3
total_time_C(1,:) = [];
total_time_P(1,:) = [];
total_time_C(2,:) = [];
total_time_P(2,:) = [];

% Sort the matrices in ascending order
sorted_C = sortrows(total_time_C, 2);
sorted_P = sortrows(total_time_P, 2);

% Calculate the split index for C session
split_index_C = ceil(length(sorted_C) / 2);

% Split the matrices for C session
high_motion_C = sorted_C(1:split_index_C);
low_motion_C = sorted_C(split_index_C+1:24);

% Calculate the split index for P session
split_index_P = ceil(length(sorted_P) / 2);

% Split the matrices for P session
high_motion_P = sorted_P(1:split_index_P);
low_motion_P = sorted_P(split_index_P+1:24);


