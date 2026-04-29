% Mean center and parcellate dtseries data 

% For 200 parcels
wbcommand = '/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

% Assume each session contributes an equal number of columns
columns_per_session = 410;

% Define subject types and tasks
subject_types = {'C', 'P'};
tasks = {'task-DORA', 'task-YT', 'task-RX'};

for subject_idx = 1:length(subject_types)
    for task_idx = 1:length(tasks)
        subject = subject_types{subject_idx};
        task = tasks{task_idx};

        for sub = 2:26
            % Construct file path
            file_path = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_dtseries/sub-19730%02d%s_%s_allsessions.dtseries.nii', sub, subject, task);

            try
                % Load data
                dtseries = ciftiopen(file_path, wbcommand);
                dtseries_data = dtseries.cdata; % Extract cdata

                % Mean-centering
                mean_dtseries = mean(dtseries_data, 2); % Mean across time
                dtseries_data = bsxfun(@minus, dtseries_data, mean_dtseries); % Subtract mean

                % Save Mean Centered cifti
                dtseries.cdata = dtseries_data;
                ciftisavereset(dtseries, file_path, wbcommand); 

                % Parcellate
                parcelCIFTIFile = '/Users/shefalirai/Downloads/Parcellations/HCP/fslr32k/cifti/Schaefer2018_1000Parcels_17Networks_order.dlabel.nii';
                parcelFile = sprintf('/Volumes/Prckids2/newmc_matlabdir/uncensored_allses_ptseries/sub-19730%02d%s_%s_allsessions_1000parcels_17nets.ptseries.nii', sub, subject, task);
                system(['! /Applications/workbench/bin_macosx64/wb_command -cifti-parcellate ' file_path ' ' parcelCIFTIFile ' COLUMN ' parcelFile ' -method MEAN']);
                ptseries_data = ciftiopen(parcelFile, '/Applications/workbench/bin_macosx64/wb_command').cdata;
            catch
                fprintf('Error: file does not exist for subject %d, subject type %s, task %s\n', sub, subject, task)
            end
        end
    end
end

