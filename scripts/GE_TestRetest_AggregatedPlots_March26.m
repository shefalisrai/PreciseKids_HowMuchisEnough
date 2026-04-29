
% Define the directory containing the CSV files
directory_path = '/Users/shefalirai/Desktop/GE_outputs/';

% List all files in the directory
file_list = dir(fullfile(directory_path, '*.csv'));

% Loop through all files in the directory
for file_idx = 1:length(file_list)
    % Extract the file name
    file_name = file_list(file_idx).name;
    folder = file_list(file_idx).folder;
    data_table = readtable(sprintf('%s/%s', folder, file_name));
    data_table_updated = removevars(data_table, 'Var1');
    matrix_table{file_idx} = table2array(data_table_updated);
end


%% Run this bottom script for all 35 files manually
first_session=[];
second_session=[];
% Assign tables to variables
first_session = [matrix_table{17}];
second_session = [matrix_table{18} ];

gescan_first =[];
gescan_second=[];
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
subdev_abcd = reliability_scanlength(reliability_scanlength ~= 0);


%% Aggregated plot

% Define x-values for each data series
x_values = 1:max([length(sub_DEVME_3echo), ...
                  length(sub_eplus1_3echo), ...
                  length(sub_eplus1_5echo), ...
                  length(sub_neta_3echo), ...
                  length(sub_neta_5echo), ...
                  length(subdev_vanilla), ...
                  length(subdev_abcd), ...
                  length(sub_shef_3echo), ...
                  length(sub_shef_5echo), ...
                  length(sub_testfMRIMarch19_regvsrpe_3echo), ...
                  length(sub_testfMRIMarch19_regvsrpe_5echo)]);

% Plot each data series with distinct colors and line styles
hold on; % Keep all plots on the same graph
plot(x_values(1:length(sub_DEVME_3echo)), sub_DEVME_3echo, '-gs', 'LineWidth', 1.5); % magenta, solid line, square markers
plot(x_values(1:length(sub_eplus1_3echo)), sub_eplus1_3echo, '-cx', 'LineWidth', 1.5); % green, solid line, x markers
plot(x_values(1:length(sub_eplus1_5echo)), sub_eplus1_5echo, '-kd', 'LineWidth', 1.5); % cyan, solid line, diamond markers
plot(x_values(1:length(sub_neta_3echo)), sub_neta_3echo, '-go', 'LineWidth', 1.5); % black, solid line, circle markers
plot(x_values(1:length(sub_neta_5echo)), sub_neta_5echo, '-bs', 'LineWidth', 1.5); % magenta, solid line, square markers
plot(x_values(1:length(subdev_vanilla)), subdev_vanilla, '-mv', 'LineWidth', 1.5); % red, solid line, inverted triangle markers
plot(x_values(1:length(subdev_abcd)), subdev_abcd, '-rv', 'LineWidth', 1.5); % green, solid line, inverted triangle markers
plot(x_values(1:length(sub_shef_3echo)), sub_shef_3echo, '-c<', 'LineWidth', 1.5); % blue, solid line, less-than markers
plot(x_values(1:length(sub_shef_5echo)), sub_shef_5echo, '-k>', 'LineWidth', 1.5); % magenta, solid line, greater-than markers
plot(x_values(1:length(sub_testfMRIMarch19_regvsrpe_3echo)), sub_testfMRIMarch19_regvsrpe_3echo, '-cs', 'LineWidth', 1.5); % green, solid line, square markers
plot(x_values(1:length(sub_testfMRIMarch19_regvsrpe_5echo)), sub_testfMRIMarch19_regvsrpe_5echo, '-kd', 'LineWidth', 1.5); % black, solid line, diamond markers

% Add legend
legend('ME 2.5mm 3echo', ...
       'ME 3.4mm 3echo', ...
       'ME 3.4mm 5echo', ...
       'ME 2.5mm 3echo', ...
       'ME 2.5mm 5echo ', ...
       'SE 3.4mm Vanilla', ...
       'SE ABCD TE MinFull ', ...
       'ME 3.4mm 3echo', ...
       'ME 3.4mm 5echo', ...
       'ME 3.4mm 3echo', ...
       'ME 3.4mm 5echo');

% Label axes
xlabel('Scan Length Increments (30 volume increments)');
ylabel('FC Reliability');

% Title
title('Test Retest FC Reliability');
ylim([0 1])

% Display grid
grid on;

% Release hold on the plot
hold off;


%% Connectome

% gescan_first_connectome(1:201:end) = NaN;
% imagesc(gescan_first_connectome)
% 









