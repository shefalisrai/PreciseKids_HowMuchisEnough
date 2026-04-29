function TestretestReliability_FullCurves_AllROIsforNetwork_Child(network_number, network_name, dtseries_C_sessions_DORA, dtseries_C_sessions_RX, dtseries_C_sessions_YT)
%TestretestReliability_FCTRC_ROIwise_AllTasks for Children
% PK ROI-wise FCTRC reliability vs. scan length
% For child up to 36 minutes split-half is where we retain all 24 participants 


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Using template matched consensus networks from
%ROIConsensus_IndividualParticipant_TemplateMatchingMaps.m file
%Using code from here: https://github.com/leotozzi88/reliability_study/tree/master
% %Assumed network order in conc file. = {'ROI-1','VIS-2','FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11'...
% cont'd...'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
ROIs_FCTRCs_outputpath='/Users/shefalirai/Desktop/PK_ROIs_FCTRCs'; % where edges will be saved
 %Note: ROI 4 and 6 are missing, therefore the DAN network is network 5 and VAN network is network 7
subject='C';
subject_types = {'C'};
% List of subject numbers
subject_numbers = 2:26; % From 2 to 26
subject_numbers = subject_numbers(subject_numbers ~= 3); % Exclude subject 3
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%% Must uncomment this code below if you are switching from parent/adult to
% %child, otherwise can leave commented and run for all 14 networks 
% 
% %%Code below for opening and censoring dtseries
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
%     dtseries_C_sessions = cell(26, 4); % 26 subjects x 4 sessions
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
%                 dtseries_C_sessions{sub, ses} = data(:, start_col:end_col);
%             end
%         catch
%             fprintf('Error: file does not exist for subject %d\n', sub);
%         end
%     end
%     assignin('base', sprintf('dtseries_C_sessions_%s', task(6:end)), dtseries_C_sessions);
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

%% If needed, can save dtseries for each task

% % % % save('dtseries_C_sessions_DORA', 'dtseries_C_sessions_DORA', '-v7.3');
% % % % save('dtseries_C_sessions_RX', 'dtseries_C_sessions_RX', '-v7.3');
% % % % save('dtseries_C_sessions_YT', 'dtseries_C_sessions_YT', '-v7.3');
% % % % %takes about 5 minutes each task variable


%% Calculate ROI connectomes for each scan length increment manually for lower computational load

% Load network data
load('EachNetwork_AveragedROI_Timeseries_Child_Session1and4.mat')
load('EachNetwork_AveragedROI_Timeseries_Child_Session2and3.mat')

% For the specified network, open corresponding ROIs for that network from 1/4 and 2/3 sessions
ROI_C_combined1 = network_data_1and4{1, network_number};
ROI_C_combined2 = network_data_2and3{1, network_number};

% Specify the scan length increment
scan_length_increment = 30;

% Specify the maximum scan length
scan_length_max_C = size(ROI_C_combined2{1}, 2);

% Iterate over each subject
for j = 1:size(ROI_C_combined1{1}, 1)
    % Inner loop through increments for the scan length
    for i = scan_length_increment:scan_length_increment:scan_length_max_C
        % Ensure the loop index is within bounds for scan_length_max
        if i > scan_length_max_C
            break;
        end

        % Combine all ROIs into one for each session
        combined_ROI_session1 = [];
        combined_ROI_session2 = [];
        for roi = 1:numel(ROI_C_combined1)
            combined_ROI_session1 = [combined_ROI_session1; ROI_C_combined1{roi}(j, 1:i)];
            combined_ROI_session2 = [combined_ROI_session2; ROI_C_combined2{roi}(j, 1:i)];
        end

        % Compute correlation matrices
        ROI_C_combined1_connectome{(i/scan_length_increment), j} = corr(combined_ROI_session1');
        ROI_C_combined2_connectome{(i/scan_length_increment), j} = corr(combined_ROI_session2');

        % Correlate
        for r = 1:size(combined_ROI_session1, 1)
            ROI_corr_allses_C{(i/scan_length_increment), j}(r) = corr(ROI_C_combined1_connectome{(i/scan_length_increment), j}(r, :)', ROI_C_combined2_connectome{(i/scan_length_increment), j}(r, :)');
        end
    end
end

% Compute mean and standard deviation of correlations across subjects
mean_values_C = nanmean(cell2mat(ROI_corr_allses_C), 2);
std_values_C = std(cell2mat(ROI_corr_allses_C), [], 2);


%% Save FCTRC values for ROI
csvwrite(strcat(ROIs_FCTRCs_outputpath, sprintf('/Child_FCTRC_%snetwork_allscantimes_meanvalues.csv', network_name)), mean_values_C)
csvwrite(strcat(ROIs_FCTRCs_outputpath, sprintf('/Child_FCTRC_%snetwork_allscantimes_stdvalues.csv', network_name)), std_values_C)


end


