%% Testretest Reliability code for each task

% For this code:
% A varying amount of data will be computed for test-retest reliability (up
% to 14 minutes) for each task separately
% This data was contiguous within sessions but did not necessarily include temporally adjacent sessions. 
% FC-TRC is calculated in each subset, and then FC-TRC measures from the two subsets are compared. 
% Parcel RSFC matrices are compared by correlating the upper triangles of the matrix for each person

% For wb_command filepath
wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

% Assume each session contributes an equal number of columns
columns_per_session = 410;
task='task-RX';

% Load and split the child data
subject='C';
ptseries_C_sessions = cell(26, 4); % 26 subjects x 4 sessions
for sub = 2:26
    % Construct file path
    file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_1000parcels_17nets.ptseries.nii', sub, subject,task);

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
        fprintf('Error: file does not exist for subject %d\n', sub)
    end
end

% Load and split the parent data
subject='P';
ptseries_P_sessions = cell(26, 4); % 26 subjects x 4 sessions
for sub = 2:26
    % Construct file path
    file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_1000parcels_17nets.ptseries.nii', sub, subject, task);

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
        fprintf('Error: file does not exist for subject %d\n', sub)
    end
end


%% Remove motion volumes using FD>0.15mm threshold

% Define threshold for high motion
threshold = 0.15; 

% Define your sessions and tasks
sessions = {'ses-1', 'ses-2', 'ses-3', 'ses-4'};
tasks = {'RX1', 'RX2'};

% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Assume each task has an equal number of volumes
num_volumes_per_task = 205; 

% Subject types
subject_types = {'C', 'P'};

% Process each subject type and number
for type = subject_types
    for sub = subject_numbers
        % Create subject identifier with appropriate leading zeros
        if sub < 10
            subject_identifier = sprintf('197300%d%s', sub, type{1});
        else
            subject_identifier = sprintf('19730%d%s', sub, type{1});
        end

        % Process each session
        for ses = 1:4
            % Select the appropriate session data
            if strcmp(type{1}, 'C')
                sub_data = ptseries_C_sessions{sub, ses};
            else
                sub_data = ptseries_P_sessions{sub, ses};
            end

            % Initialize the indices of columns to remove for this session
            columns_to_remove = [];

            % Loop over each task to find high motion volumes
            for j = 1:length(tasks)
                % Handle the special case for sub-1973024P and ses-6
                session_id = sessions{ses};
                if strcmp(subject_identifier, '1973024P') && ses == 4
                    session_id = 'ses-6';
                end

                % Construct the CSV file path for the current session and task
                csv_file_path = sprintf('/Volumes/Prckids/sub-%s/%s/func/sub-%s_%s_task-%s_echo-2_PowerFDFlt.csv', subject_identifier, session_id, subject_identifier, session_id, tasks{j});
                
                % Load the motion parameters from the CSV file
                try
                    fd = readtable(csv_file_path);
                catch
                    warning('Unable to read file: %s', csv_file_path);
                    continue;
                end
                
                % Find volumes with high motion
                high_motion_volumes = find(fd.FD > threshold);
                
                % Append the columns to remove for this session and task
                columns_to_remove = [columns_to_remove; high_motion_volumes];
            end

            % Remove duplicates and sort the indices
            columns_to_remove = unique(sort(columns_to_remove));

            % Remove the high motion columns for this session
            for idx = length(columns_to_remove):-1:1
                if columns_to_remove(idx) <= size(sub_data, 2)
                    sub_data(:, columns_to_remove(idx)) = [];
                else
                    warning('Attempted to remove a column that does not exist. Index: %d', columns_to_remove(idx));
                end
            end

            % Store the cleaned data back
            if strcmp(type{1}, 'C')
                ptseries_C_sessions{sub, ses} = sub_data;
            else
                ptseries_P_sessions{sub, ses} = sub_data;
            end
        end
    end
end




%% Remove SNR regions

% Open SNR mask computed from Midnight Scan Avg
snrMask = ciftiopen('/Users/shefalirai/Desktop/MSCavg_SNRmask_1000parcelled.ptseries.nii', wbcommand);
snrMask_data = snrMask.cdata;

% List of subject numbers (excluding subject 3)
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Subject types
subject_types = {'C', 'P'};

% Apply the mask to each session for each subject
for type = subject_types
    for sub = subject_numbers
        for ses = 1:4
            if strcmp(type{1}, 'C')
                % Check if data is available for this subject and session
                if size(ptseries_C_sessions, 1) >= sub && ~isempty(ptseries_C_sessions{sub, ses})
                    ptseries_C_sessions{sub, ses}(snrMask_data > 0, :) = NaN;
                end
            else
                % Check if data is available for this subject and session
                if size(ptseries_P_sessions, 1) >= sub && ~isempty(ptseries_P_sessions{sub, ses})
                    ptseries_P_sessions{sub, ses}(snrMask_data > 0, :) = NaN;
                end
            end
        end
    end
end



%% Create first and last half session before creating connectomes

% Initialize new variables for combined sessions
ptseries_C_combined1 = cell(26, 1); % Combining sessions 1 and 4
ptseries_C_combined2 = cell(26, 1); % Combining sessions 2 and 3
ptseries_P_combined1 = cell(26, 1); % Combining sessions 1 and 4
ptseries_P_combined2 = cell(26, 1); % Combining sessions 2 and 3

% List of subject numbers (excluding subject 3)
subject_numbers = 2:26; 
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3

% Combine sessions for each subject
for sub = subject_numbers
    % Combine for Child subjects
    if ~isempty(ptseries_C_sessions{sub, 1}) && ~isempty(ptseries_C_sessions{sub, 4})
        ptseries_C_combined1{sub} = [ptseries_C_sessions{sub, 1}, ptseries_C_sessions{sub, 4}];
    end
    if ~isempty(ptseries_C_sessions{sub, 2}) && ~isempty(ptseries_C_sessions{sub, 3})
        ptseries_C_combined2{sub} = [ptseries_C_sessions{sub, 2}, ptseries_C_sessions{sub, 3}];
    end

    % Combine for Parent subjects
    if ~isempty(ptseries_P_sessions{sub, 1}) && ~isempty(ptseries_P_sessions{sub, 4})
        ptseries_P_combined1{sub} = [ptseries_P_sessions{sub, 1}, ptseries_P_sessions{sub, 4}];
    end
    if ~isempty(ptseries_P_sessions{sub, 2}) && ~isempty(ptseries_P_sessions{sub, 3})
        ptseries_P_combined2{sub} = [ptseries_P_sessions{sub, 2}, ptseries_P_sessions{sub, 3}];
    end
end

ptseries_P_combined1 = ptseries_P_combined1(~cellfun('isempty', ptseries_P_combined1));
ptseries_P_combined2 = ptseries_P_combined2(~cellfun('isempty', ptseries_P_combined2));
ptseries_C_combined1 = ptseries_C_combined1(~cellfun('isempty', ptseries_C_combined1));
ptseries_C_combined2 = ptseries_C_combined2(~cellfun('isempty', ptseries_C_combined2));



%% Find minimum scan length across both P and C

% Initialize a variable to store the minimum column size
min_column_size = inf;

% Check ptseries_C_combined1
for i = 1:numel(ptseries_C_combined1)
    if ~isempty(ptseries_C_combined1{i})
        min_column_size = min(min_column_size, size(ptseries_C_combined1{i}, 2));
    end
end

% Check ptseries_C_combined2
for i = 1:numel(ptseries_C_combined2)
    if ~isempty(ptseries_C_combined2{i})
        min_column_size = min(min_column_size, size(ptseries_C_combined2{i}, 2));
    end
end

% Check ptseries_P_combined1
for i = 1:numel(ptseries_P_combined1)
    if ~isempty(ptseries_P_combined1{i})
        min_column_size = min(min_column_size, size(ptseries_P_combined1{i}, 2));
    end
end

% Check ptseries_P_combined2
for i = 1:numel(ptseries_P_combined2)
    if ~isempty(ptseries_P_combined2{i})
        min_column_size = min(min_column_size, size(ptseries_P_combined2{i}, 2));
    end
end

% Display the minimum column size
fprintf('Minimum Column Size: %d\n', min_column_size);

%Truncate to the minimum column size calcuated above
% Function to truncate the data in each cell
truncate_data = @(data) data(:, 1:min_column_size);

% Apply the truncation to ptseries_C_combined1
ptseries_C_combined1 = cellfun(truncate_data, ptseries_C_combined1, 'UniformOutput', false);

% Apply the truncation to ptseries_C_combined2
ptseries_C_combined2 = cellfun(truncate_data, ptseries_C_combined2, 'UniformOutput', false);

% Apply the truncation to ptseries_P_combined1
ptseries_P_combined1 = cellfun(truncate_data, ptseries_P_combined1, 'UniformOutput', false);

% Apply the truncation to ptseries_P_combined2
ptseries_P_combined2 = cellfun(truncate_data, ptseries_P_combined2, 'UniformOutput', false);


%% Calculate reliability

% Define the increment for the scan length, 5 minutes
% 150 volumes is 5 mins, 30 volumes is 1 min
scan_length_increment = 30;

% Initialize the reliability_scanlength_cell arrays
reliability_scanlength_cell_C = cell(1, numel(ptseries_C_combined1));
reliability_scanlength_cell_P = cell(1, numel(ptseries_P_combined1));

% Outer loop for each subject in C
for j = 1:numel(ptseries_C_combined1)
    if ~isempty(ptseries_C_combined1{j}) && ~isempty(ptseries_C_combined2{j})
        scan_length_max_C_subject = min(size(ptseries_C_combined1{j}, 2), size(ptseries_C_combined2{j}, 2));
        reliability_scanlength_C = zeros(1, ceil(scan_length_max_C_subject / scan_length_increment));

        for i = scan_length_increment:scan_length_increment:scan_length_max_C_subject
            % Extract the first i columns for the combined1 and combined2 datasets
            combined1_columns_C = ptseries_C_combined1{j}(:, 1:min(i, size(ptseries_C_combined1{j}, 2)));
            combined2_columns_C = ptseries_C_combined2{j}(:, 1:min(i, size(ptseries_C_combined2{j}, 2)));

            % Compute correlations for the current subject
            combined1_connectome_C = corr(combined1_columns_C');
            combined2_connectome_C = corr(combined2_columns_C');

            % Remove NaNs
            combined1_connectome_C(isnan(combined1_connectome_C)) = 0;
            combined2_connectome_C(isnan(combined2_connectome_C)) = 0;

            % Correlate and store the mean correlation for the current scan length
            ptseries_corr_allses_C = zeros(1, size(combined1_connectome_C, 1));
            for r = 1:size(combined1_connectome_C, 1)
                ptseries_corr_allses_C(r) = corr(combined1_connectome_C(r, :)', combined2_connectome_C(r, :)');
            end
            reliability_scanlength_C(i/scan_length_increment) = nanmean(ptseries_corr_allses_C);
        end
        reliability_scanlength_cell_C{j} = reliability_scanlength_C;
    end
end

% Outer loop for each subject in P
for j = 1:numel(ptseries_P_combined1)
    if ~isempty(ptseries_P_combined1{j}) && ~isempty(ptseries_P_combined2{j})
        scan_length_max_P_subject = min(size(ptseries_P_combined1{j}, 2), size(ptseries_P_combined2{j}, 2));
        reliability_scanlength_P = zeros(1, ceil(scan_length_max_P_subject / scan_length_increment));

        for i = scan_length_increment:scan_length_increment:scan_length_max_P_subject
            % Extract the first i columns for the combined1 and combined2 datasets
            combined1_columns_P = ptseries_P_combined1{j}(:, 1:min(i, size(ptseries_P_combined1{j}, 2)));
            combined2_columns_P = ptseries_P_combined2{j}(:, 1:min(i, size(ptseries_P_combined2{j}, 2)));

            % Compute correlations for the current subject
            combined1_connectome_P = corr(combined1_columns_P');
            combined2_connectome_P = corr(combined2_columns_P');

            % Remove NaNs
            combined1_connectome_P(isnan(combined1_connectome_P)) = 0;
            combined2_connectome_P(isnan(combined2_connectome_P)) = 0;

            % Correlate and store the mean correlation for the current scan length
            ptseries_corr_allses_P = zeros(1, size(combined1_connectome_P, 1));
            for r = 1:size(combined1_connectome_P, 1)
                ptseries_corr_allses_P(r) = corr(combined1_connectome_P(r, :)', combined2_connectome_P(r, :)');
            end
            reliability_scanlength_P(i/scan_length_increment) = nanmean(ptseries_corr_allses_P);
        end
        reliability_scanlength_cell_P{j} = reliability_scanlength_P;
    end
end

% Remove trailing zeros for each subject in reliability_scanlength_cell
for j = 1:numel(reliability_scanlength_cell_C)
    reliability_scanlength_cell_C{j} = reliability_scanlength_cell_C{j}(reliability_scanlength_cell_C{j} ~= 0);
end

for j = 1:numel(reliability_scanlength_cell_P)
    reliability_scanlength_cell_P{j} = reliability_scanlength_cell_P{j}(reliability_scanlength_cell_P{j} ~= 0);
end



%% Find mean and standard deviation of all subjects

% Find the shortest length for both conditions
min_length_C = min(cellfun(@numel, reliability_scanlength_cell_C(~cellfun('isempty', reliability_scanlength_cell_C))));
min_length_P = min(cellfun(@numel, reliability_scanlength_cell_P(~cellfun('isempty', reliability_scanlength_cell_P))));
min_length = min(min_length_C, min_length_P);

% Create matrices with matched lengths for both conditions
matched_matrix_C = nan(numel(reliability_scanlength_cell_C), min_length);
matched_matrix_P = nan(numel(reliability_scanlength_cell_P), min_length);

% Populate the matched matrices for condition C
for i = 1:numel(reliability_scanlength_cell_C)
    current_data = reliability_scanlength_cell_C{i};
    if ~isempty(current_data)
        matched_matrix_C(i, 1:min(numel(current_data), min_length)) = current_data(1:min(numel(current_data), min_length));
    end
end

% Populate the matched matrices for condition P
for i = 1:numel(reliability_scanlength_cell_P)
    current_data = reliability_scanlength_cell_P{i};
    if ~isempty(current_data)
        matched_matrix_P(i, 1:min(numel(current_data), min_length)) = current_data(1:min(numel(current_data), min_length));
    end
end

% Replace 0 values with NaN in matched_matrix_C
matched_matrix_C(matched_matrix_C == 0) = NaN;

% Replace 0 values with NaN in matched_matrix_P
matched_matrix_P(matched_matrix_P == 0) = NaN;

% Calculate the mean of each corresponding element across cells for both conditions
mean_values_C = mean(matched_matrix_C, 'omitnan');
mean_values_P = mean(matched_matrix_P, 'omitnan');

% Calculate the standard deviation of each corresponding element across cells for both conditions
std_values_C = std(matched_matrix_C, 'omitnan');
std_values_P = std(matched_matrix_P, 'omitnan');

% Combine mean and std values for plotting
mean_values_combined = [mean_values_C; mean_values_P];
std_values_combined = [std_values_C; std_values_P];

save('matched_meanFCTRCvalues_parentsandchildren_task-RX_1000parcels.mat', "mean_values_combined");
save('matched_stdFCTRCvalues_parentsandchildren_task-RX_1000parcels.mat', "std_values_combined");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uncomment and run the plotting code below once the code above has been run 3 times for each task


 %% Plot all 3 tasks together

load('matched_meanFCTRCvalues_parentsandchildren_task-DORA_1000parcels.mat')
mean_values_C_DORA=mean_values_combined(1,1:14);
mean_values_P_DORA=mean_values_combined(2,1:14);

load('matched_meanFCTRCvalues_parentsandchildren_task-YT_1000parcels.mat')
mean_values_C_YT=mean_values_combined(1,1:14);
mean_values_P_YT=mean_values_combined(2,1:14);

load('matched_meanFCTRCvalues_parentsandchildren_task-RX_1000parcels.mat')
mean_values_C_RX=mean_values_combined(1,1:14);
mean_values_P_RX=mean_values_combined(2,1:14);

% Calculate the standard deviation of each corresponding element across cells for both conditions
load('matched_stdFCTRCvalues_parentsandchildren_task-DORA_1000parcels.mat')
std_values_C_DORA=std_values_combined(1,1:14);
std_values_P_DORA=std_values_combined(2,1:14);

load('matched_stdFCTRCvalues_parentsandchildren_task-YT_1000parcels.mat')
std_values_C_YT=std_values_combined(1,1:14);
std_values_P_YT=std_values_combined(2,1:14);

load('matched_stdFCTRCvalues_parentsandchildren_task-RX_1000parcels.mat')
std_values_C_RX=std_values_combined(1,1:14);
std_values_P_RX=std_values_combined(2,1:14);


x_axis=(30*6/180):(30*6/180):(421*6/180);

% Plot the mean with standard deviation as error bars for both conditions
figure;

% Plot Dora for Adults and Children
errorbar(x_axis, mean_values_P_DORA, std_values_P_DORA, 'LineStyle', '--', 'LineWidth', 3, 'Marker', 'o', 'Color', '#F5BC00');
hold on;
errorbar(x_axis, mean_values_C_DORA, std_values_C_DORA, 'LineStyle', '--', 'LineWidth', 3, 'Marker', 'o', 'Color', '#C0C0FF');
hold on;

% Plot YT for Adults and Children
errorbar(x_axis, mean_values_P_YT, std_values_P_YT, 'LineStyle', '-.', 'LineWidth', 3, 'Marker', '*', 'Color', '#FF8000');
hold on;
errorbar(x_axis, mean_values_C_YT, std_values_C_YT, 'LineStyle', '-.', 'LineWidth', 3, 'Marker', '*', 'Color', '#A46592');
hold on;

% Plot RX for Adults and Children
errorbar(x_axis, mean_values_P_RX, std_values_P_RX, 'LineStyle', ':', 'LineWidth', 3, 'Marker', 's', 'Color', '#B86800');
hold on;
errorbar(x_axis, mean_values_C_RX, std_values_C_RX, 'LineStyle', ':', 'LineWidth', 3, 'Marker', 's', 'Color', '#673ACF');
hold off;

xlabel('Scan Length (minutes)');
ylabel('Mean FC-TRC');

% Reverse the order of legend entries (switch "Children" and "Adults")
legend({'Adults Dora', 'Children Dora', 'Adults YT', 'Children YT', 'Adults RX', 'Children RX'}, 'FontSize', 18, 'Location', 'northwest');

set(gca, 'FontSize', 18);
% Set the font type
set(gca, 'FontName', 'Arial');
% Remove the top and right axis lines
ylim([0.1 0.9])
ax = gca;
ax.Box = 'off';

