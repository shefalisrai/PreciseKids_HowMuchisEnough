%% Test-retest curves for GE scans sub-004 3 echo session 1 task-rest *TEST script*
% After running parcellator.py which parcellates voxels in 200 Schaefer parcels and applies a brain and temporal mask

%% 3 echo dataset with new version of tedana v23.0.2

%Define TR for this 3 echo dataset
sub='sub-me3mm3and5run2';
ses='ses-develpmentdevelopmentach16763';
task='task-rest_acq-hyperband3echo';
TR=1.75; %5 echo is TR2 3 echo is 1.75 vanilla is TR2.5

% Specify the file paths for each session
file_path_ses1_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s4_parcelled.csv',sub, sub, ses, task);
file_path_ses2_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s5_parcelled.csv', sub, sub, ses, task);

% Read the CSV files into tables
data_table_ses1_run1 = readtable(file_path_ses1_run1);
data_table_ses2_run1 = readtable(file_path_ses2_run1);
% data_table_ses1_run2 = readtable(file_path_ses1_run2);
% data_table_ses2_run2 = readtable(file_path_ses2_run2);

% Remove time label
data_table_ses1_run1 = removevars(data_table_ses1_run1, 'Var1');
data_table_ses2_run1 = removevars(data_table_ses2_run1, 'Var1');
% data_table_ses1_run2 = removevars(data_table_ses1_run2, 'Var1');
% data_table_ses2_run2 = removevars(data_table_ses2_run2, 'Var1');

% Convert tables to matrices
ses1_run1_data = table2array(data_table_ses1_run1);
ses2_run1_data = table2array(data_table_ses2_run1);
% ses1_run2_data = table2array(data_table_ses1_run2);
% ses2_run2_data = table2array(data_table_ses2_run2);

% Assign tables to variables
first_session = [ses1_run1_data];
second_session = [ses2_run1_data];

% Assign the halves to the new cell arrays and transform to have 200 parcel as rows and columns as time points
gescan_first = first_session';
gescan_second = second_session';

% Define the increment for the scan length, 1 minute
scan_length_increment = 30;

% Calculate scan_length_max 
scan_length_max_C = max(size(gescan_first, 2), size(gescan_second, 2));

% Initialize reliability_scanlength for the current subject
reliability_scanlength = zeros(1, ceil(scan_length_max_C / scan_length_increment));

% Inner loop through increments for the scan length
for i = scan_length_increment:scan_length_increment:scan_length_max_C
        % Extract the first i columns from the matrix for the current subject
        gescan_first_columns = gescan_first(:, 1:min(i, size(gescan_first, 2)));
        gescan_second_columns = gescan_second(:, 1:min(i, size(gescan_second, 2)));

        % Compute correlations for the current subject
        gescan_first_connectome = corr(gescan_first_columns');
        gescan_second_connectome = corr(gescan_second_columns');

        % Initialize array to store correlations for all regions
        gescan_corr_allses = zeros(1, size(gescan_first_connectome, 1));

        % Remove NaNs
        gescan_first_connectome(isnan(gescan_first_connectome)) = 0;
        gescan_second_connectome(isnan(gescan_second_connectome)) = 0;

        % Correlate
        for r = 1:size(gescan_first_connectome, 1)
            gescan_corr_allses(r) = corr(gescan_first_connectome(r, :)', gescan_second_connectome(r, :)');
        end

        % Store the mean correlation for the current scan length
        reliability_scanlength(i / scan_length_increment) = nanmean(gescan_corr_allses);
end


% Remove trailing zeros for each subject in reliability_scanlength_cell
reliability_scanlength_3echo = reliability_scanlength(reliability_scanlength ~= 0);



%% % Plotting 3 echo data

figure;

x_axis_max_C = scan_length_max_C;

% Define x-axis
x_axis = (scan_length_increment * TR / 60):(scan_length_increment * TR / 60):(x_axis_max_C * TR / 60);

% Plot 
plot(x_axis, reliability_scanlength_3echo, 'LineStyle', '-', 'LineWidth', 2.5, 'Color', '#80387C'); 
xlabel('Scan Length (minutes)');
ylabel('Mean FC-TRC for 3echo');
ylim([0 0.9]);
xlim([0 12])
set(gca, 'FontSize', 18);
set(gca, 'FontName', 'Arial');
ax = gca;
ax.Box = 'off';





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 5 echo dataset

sub='sub-me3mm3and5run2';
ses='ses-develpmentdevelopmentach16763';
task='task-rest_acq-hyperband5echo';
TR=2; %5 echo is TR2 3 echo is 1.75 vanilla is TR2.5

% Specify the file paths for each session
file_path_ses1_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s6_parcelled.csv',sub, sub, ses, task);
file_path_ses2_run1 = sprintf('/Users/shefalirai/Downloads/bids-files/%s/%s_%s_%s7_parcelled.csv', sub, sub, ses, task);

% Read the CSV files into tables
data_table_ses1_run1 = readtable(file_path_ses1_run1);
data_table_ses2_run1 = readtable(file_path_ses2_run1);


% Remove time label
data_table_ses1_run1 = removevars(data_table_ses1_run1, 'Var1');
data_table_ses2_run1 = removevars(data_table_ses2_run1, 'Var1');

% Convert tables to matrices
ses1_data = table2array(data_table_ses1_run1);
ses2_data = table2array(data_table_ses2_run1);


% Assign tables to variables
first_session = ses1_data;
second_session = ses2_data;

% Assign the halves to the new cell arrays and transform to have 200 parcel as rows and columns as time points
gescan_first = first_session';
gescan_second = second_session';

% Define the increment for the scan length, 1 minute
scan_length_increment = 30;

% Calculate scan_length_max 
scan_length_max_C = max(size(gescan_first, 2), size(gescan_second, 2));

% Initialize reliability_scanlength for the current subject
reliability_scanlength = zeros(1, ceil(scan_length_max_C / scan_length_increment));

% Inner loop through increments for the scan length
for i = scan_length_increment:scan_length_increment:scan_length_max_C
        % Extract the first i columns from the matrix for the current subject
        gescan_first_columns = gescan_first(:, 1:min(i, size(gescan_first, 2)));
        gescan_second_columns = gescan_second(:, 1:min(i, size(gescan_second, 2)));

        % Compute correlations for the current subject
        gescan_first_connectome = corr(gescan_first_columns');
        gescan_second_connectome = corr(gescan_second_columns');

        % Initialize array to store correlations for all regions
        gescan_corr_allses = zeros(1, size(gescan_first_connectome, 1));

        % Remove NaNs
        gescan_first_connectome(isnan(gescan_first_connectome)) = 0;
        gescan_second_connectome(isnan(gescan_second_connectome)) = 0;

        % Correlate
        for r = 1:size(gescan_first_connectome, 1)
            gescan_corr_allses(r) = corr(gescan_first_connectome(r, :)', gescan_second_connectome(r, :)');
        end

        % Store the mean correlation for the current scan length
        reliability_scanlength(i / scan_length_increment) = nanmean(gescan_corr_allses);
end


% Remove trailing zeros for each subject in reliability_scanlength_cell
reliability_scanlength_5echo = reliability_scanlength(reliability_scanlength ~= 0);


%% Plot 5 echo datasets

figure;

x_axis_max_C = scan_length_max_C;

% Define x-axis
x_axis = (scan_length_increment * TR / 60):(scan_length_increment * TR / 60):(x_axis_max_C * TR / 60);

% Plot 
plot(x_axis, reliability_scanlength_5echo, 'LineStyle', '-', 'LineWidth', 2.5, 'Color', '#FFA500'); 
xlabel('Scan Length (minutes)');
ylabel('Mean FC-TRC for 5echo');
ylim([0 0.9]);
xlim([0 10])
set(gca, 'FontSize', 18);
set(gca, 'FontName', 'Arial');
ax = gca;
ax.Box = 'off';








