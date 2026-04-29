% Initialize a cell array to store mean motion volumes and subject IDs
mean_motion_volumes = cell(length(subject_types), length(subject_numbers));
subject_ids = cell(length(subject_types), length(subject_numbers));

% Process each subject type and number
for type_idx = 1:length(subject_types)
    type = subject_types{type_idx};
    for sub_idx = 1:length(subject_numbers)
        sub = subject_numbers(sub_idx);
        
        % Create subject identifier with appropriate leading zeros
        subject_identifier = sprintf('19730%02d%s', sub, type);

        % Initialize a vector to store the motion volumes for this participant
        participant_motion_volumes = [];
        
        % Process each session
        for ses = 1:4
            % Adjust session ID for subject 1973024P if ses-4
            session_id = sessions{ses};
            if strcmp(subject_identifier, '1973024P') && ses == 4
                session_id = 'ses-6';
            end
            
            % Loop over each original task
            for t = 1:length(original_tasks)
                task = original_tasks{t};

                % Process each sub-task
                for st = 1:length(sub_tasks)
                    sub_task = sub_tasks{st};
                    task_with_sub = [task sub_task]; % Combine task with its sub-task

                    % Construct the CSV file path for the current session and sub-task
                    csv_file_path = sprintf('/Volumes/Prckids/sub-%s/%s/func/sub-%s_%s_task-%s_echo-2_PowerFDFlt.csv', subject_identifier, session_id, subject_identifier, session_id, task_with_sub);

                    % Load the motion parameters from the CSV file
                    try
                        fd = readtable(csv_file_path);
                    catch
                        warning('Unable to read file: %s', csv_file_path);
                        continue;
                    end

                    % Append motion volumes to participant_motion_volumes
                    participant_motion_volumes = [participant_motion_volumes; fd.FD];
                end
            end
        end
        
        % Compute the mean motion volume for this participant
        mean_motion_volumes{type_idx, sub_idx} = mean(participant_motion_volumes);
        
        % Extract the subject number from the subject identifier
        subject_number_str = extractBefore(subject_identifier, length(subject_identifier)-1);
        
        % Store the subject ID
        subject_ids{type_idx, sub_idx} = subject_number_str;
    end
end

% Combine the mean motion volumes into a single matrix
mean_motion_volumes_combined = cell2mat(mean_motion_volumes);
meanFD_volumes_final = [mean_motion_volumes_combined(1,:)'; mean_motion_volumes_combined(2,:)'];

% Combine the subject IDs into a single column
subject_ids_final = repmat(subject_numbers', 2, 1);

meanFD_volumes_final(:,2)=subject_ids_final;


