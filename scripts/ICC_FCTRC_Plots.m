%% ICC21 = Create bar plot of all networks after running the above script for each network

%Using template matched consensus networks from
%NetworkConsensus_IndividualParticipant_TemplateMatchingMaps.m file
%Using code from here: https://github.com/leotozzi88/reliability_study/tree/master
% %Assumed network order in conc file. = {'DMN-1','VIS-2','FP-3','DAN-5','VAN-7','SAL-8','CON-9','SMd-10','SMl-11'...
% cont'd...'AUD-12', 'Tpole-13', 'MTL-14','PMN-15','PON-16'};
wbcommand = ('/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command');
ICC_outputpath='/Users/shefalirai/Desktop/PK_ROIs_ICCs'; % where edges will be saved
FCTRC_outputpath='/Users/shefalirai/Desktop/PK_ROIs_FCTRCs';
scan_length=23;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% ICC Plots
% % Define the networks
networks= {'FP', 'VAN', 'DMN', 'CON', 'AUD', 'SAL', 'DAN', 'VIS', 'PON', 'Tpole', 'SMd', 'SMl', 'MTL', 'PMN'};

% Initialize arrays to store ICC data and upper bound data at time point 23 for each network
icc_data_child_at_23 = zeros(1, numel(networks));
ub_data_child_at_23 = zeros(1, numel(networks));
icc_data_parent_at_23 = zeros(1, numel(networks));
ub_data_parent_at_23 = zeros(1, numel(networks));

% Loop over each network
for net_idx = 1:numel(networks)
    % Read Child ICC and upper bound data
    icc_child_file = fullfile(ICC_outputpath, ['Child_ICC_' networks{net_idx} sprintf('_%dscantimes_icc.csv', scan_length)]);
    ub_child_file = fullfile(ICC_outputpath, ['Child_ICC_' networks{net_idx} sprintf('_%dscantimes_ub.csv', scan_length)]);
    
    % Read Parent ICC and upper bound data
    icc_parent_file = fullfile(ICC_outputpath, ['Parent_ICC_' networks{net_idx} sprintf('_%dscantimes_icc.csv', scan_length)]);
    ub_parent_file = fullfile(ICC_outputpath, ['Parent_ICC_' networks{net_idx} sprintf('_%dscantimes_ub.csv', scan_length)]);
    
    % Read data
    icc_child_data = csvread(icc_child_file);
    ub_child_data = csvread(ub_child_file);
    icc_parent_data = csvread(icc_parent_file);
    ub_parent_data = csvread(ub_parent_file);
    
    % Get Child ICC and upper bound data at time point 23
    icc_data_child_at_23(net_idx) = icc_child_data(23);
    ub_data_child_at_23(net_idx) = ub_child_data(23);
    
    % Get Parent ICC and upper bound data at time point 23
    icc_data_parent_at_23(net_idx) = icc_parent_data(23);
    ub_data_parent_at_23(net_idx) = ub_parent_data(23);
end

% Calculate errors for child and parent separately (ICC - upper bound) at time point 23
errs_child = icc_data_child_at_23 - ub_data_child_at_23;
errs_parent = icc_data_parent_at_23 - ub_data_parent_at_23;


% Define RGB values manually for the colors
child_color = [128, 56, 123] / 255; % RGB values for #80387C
parent_color = [237, 132, 100] / 255; % RGB values for #F78464

% Plotting
ctrs = 1:numel(networks);
figure(1)
bar(ctrs - 0.2, icc_data_child_at_23, 0.4, 'FaceColor', child_color, 'EdgeColor', 'none');
hold on;
errorbar(ctrs - 0.2, icc_data_child_at_23, errs_child, '.', 'Color', 'k', 'LineWidth', 1.5);

bar(ctrs + 0.2, icc_data_parent_at_23, 0.4, 'FaceColor', parent_color, 'EdgeColor', 'none');
errorbar(ctrs + 0.2, icc_data_parent_at_23, errs_parent, '.', 'Color', 'k', 'LineWidth', 1.5);
hold off;

% Add labels to x-axis
legend({'Child', 'Errors', 'Adult'}); % Specify legend labels using a cell array
xticks(ctrs);
xticklabels(networks);
xtickangle(45); % Rotate x-axis labels for better readability
xlabel('Network');
ylim([0 1]);
ylabel(sprintf('ICC Reliability at T=%dmin', scan_length));
title('ICC Data and Error (ICC - Upper Bound) for Each Network');

%% Above plot sorted by parent ascending

% Sort networks based on the parent ICC data at time point 23
[sorted_parent_icc_data, sorted_indices] = sort(icc_data_parent_at_23);

% Reorder networks and their corresponding ICC data and errors
sorted_networks = networks(sorted_indices);
sorted_icc_child_data = icc_data_child_at_23(sorted_indices);
sorted_icc_parent_data = icc_data_parent_at_23(sorted_indices);
sorted_errs_child = errs_child(sorted_indices);
sorted_errs_parent = errs_parent(sorted_indices);

% Define RGB values manually for the colors
child_color = [128, 56, 123] / 255; % RGB values for #80387C
parent_color = [237, 132, 100] / 255; % RGB values for #F78464

% Plotting horizontally
figure(1)
barh(1:numel(networks), [sorted_icc_child_data', sorted_icc_parent_data'], 'BarWidth', 0.6, 'FaceColor', 'flat');
colormap([child_color; parent_color]);
hold on;
% errorbar(sorted_icc_child_data, 1:numel(networks), sorted_errs_child, 'horizontal', '.', 'Color', 'k');
% errorbar(sorted_icc_parent_data, 1:numel(networks), sorted_errs_parent, 'horizontal', '.', 'Color', 'k');
hold off;

% Add labels to y-axis
legend({'Child', 'Adult'}, 'Location', 'northwest'); % Specify legend labels using a cell array
yticks(1:numel(networks));
yticklabels(sorted_networks);
xlabel(sprintf('ICC Reliability at T=%dmin', scan_length));
xlim([0 1]);
title('ICC(2,1) for Each Network');



%% ICC21 = Scan length plot for each network without errors
% % 

% Define the networks
networks= {'FP', 'VAN', 'DMN', 'CON', 'AUD', 'SAL', 'DAN', 'VIS', 'PON', 'Tpole', 'SMd', 'SMl', 'MTL', 'PMN'};
scan_times=1:23;

% Loop over each network
for net_idx = 1:numel(networks)
    % Initialize array to store ICC data for the current network
    icc_data_child = zeros(1, numel(scan_times));
    icc_data_parent = zeros(1, numel(scan_times));
    
    % Loop over each scan time
    for time_idx = 1:numel(scan_times)
        % Read Child ICC data
        icc_child_file = fullfile(ICC_outputpath, ['Child_ICC_' networks{net_idx} sprintf('_%dscantimes_icc.csv', scan_length)]);
        icc_child_data = csvread(icc_child_file);
        % Store ICC data at the corresponding scan time
        icc_data_child(time_idx) = icc_child_data(scan_times(time_idx));
        
        % Read Parent ICC data
        icc_parent_file = fullfile(ICC_outputpath, ['Parent_ICC_' networks{net_idx} sprintf('_%dscantimes_icc.csv', scan_length)]);
        icc_parent_data = csvread(icc_parent_file);
        % Store ICC data at the corresponding scan time
        icc_data_parent(time_idx) = icc_parent_data(scan_times(time_idx));
    end
    
    % Plot ICC data for child with shared color and dashed line style
    plot(scan_times, icc_data_child, 'LineWidth', 2, 'Color', '#80387C');
    hold on;
    
    % Plot ICC data for parent with shared color and solid line style
    plot(scan_times, icc_data_parent, 'LineWidth', 2, 'Color',  '#F78464');
    
    % Add labels and legend
    title(['ICC for ' networks{net_idx}]);
    xlabel('Scan Length (minutes)');
    ylabel('ICC Reliability');
    
    % Create legend entries for child and parent networks
    legend({'Child', 'Parent'});
    hold off;
    
    % Save the plot
    saveas(gcf, fullfile('/Users/shefalirai/Desktop/', ['ICC_Plot_' networks{net_idx} '.png']));
    
    % Close the current figure to start a new one for the next network
    close(gcf);
end


%% FCTRC Plots with SD

% Define the networks
networks = {'AUD','CON', 'DAN','DMN','FP', 'PON','SAL', 'SMd', 'SMl', 'VAN','VIS'};

% Initialize arrays to store ICC data and upper bound data at time point 23 for each network
meanvalues_data_child_at_23 = zeros(1, numel(networks));
stdvalues_data_child_at_23 = zeros(1, numel(networks));
meanvalues_data_parent_at_23 = zeros(1, numel(networks));
stdvalues_data_parent_at_23 = zeros(1, numel(networks));

% Loop through each network
for network = networks
    % Convert cell array to string
    network = char(network);
    
    % Construct the file paths for mean and standard deviation files
    file_mean_C = fullfile(FCTRC_outputpath, sprintf('Child_FCTRC_%snetwork_allscantimes_meanvalues.csv', network));
    file_std_C = fullfile(FCTRC_outputpath, sprintf('Child_FCTRC_%snetwork_allscantimes_stdvalues.csv', network));
    file_mean_P = fullfile(FCTRC_outputpath, sprintf('Parent_FCTRC_%snetwork_allscantimes_meanvalues.csv', network));
    file_std_P = fullfile(FCTRC_outputpath, sprintf('Parent_FCTRC_%snetwork_allscantimes_stdvalues.csv', network));
    
    % Load mean and standard deviation values for children and adults
    mean_values_C.(network) = csvread(file_mean_C);
    std_values_C.(network) = csvread(file_std_C);
    mean_values_P.(network) = csvread(file_mean_P);
    std_values_P.(network) = csvread(file_std_P);
end

% Define RGB values manually for the colors
child_color = [128, 56, 123] / 255; % RGB values for #80387C
parent_color = [237, 132, 100] / 255; % RGB values for #F78464

% Extract mean and standard deviation values for child and parent networks at the specific time point
child_means = zeros(1, numel(networks));
parent_means = zeros(1, numel(networks));
child_stds = zeros(1, numel(networks));
parent_stds = zeros(1, numel(networks));

for i = 1:numel(networks)
    child_means(i) = mean_values_C.(networks{i})(23);
    parent_means(i) = mean_values_P.(networks{i})(23);
    child_stds(i) = std_values_C.(networks{i})(23);
    parent_stds(i) = std_values_P.(networks{i})(23);
end

% Extract mean and standard deviation values for child and parent networks at the specific time point
child_means = zeros(1, numel(networks));
parent_means = zeros(1, numel(networks));
child_stds = zeros(1, numel(networks));
parent_stds = zeros(1, numel(networks));

for i = 1:numel(networks)
    child_means(i) = mean_values_C.(networks{i})(23);
    parent_means(i) = mean_values_P.(networks{i})(23);
    child_stds(i) = std_values_C.(networks{i})(23);
    parent_stds(i) = std_values_P.(networks{i})(23);
end

% Plotting
figure(1)

% Bar width
bar_width = 0.35;

% X-coordinate adjustments
x = 1:numel(networks);

% Plot child bars
bar(x - bar_width/2, child_means, bar_width, 'FaceColor', child_color, 'EdgeColor', 'none');
hold on;

% Plot parent bars
bar(x + bar_width/2, parent_means, bar_width, 'FaceColor', parent_color, 'EdgeColor', 'none');

% Add error bars for standard deviations
errorbar(x - bar_width/2, child_means, child_stds, 'LineStyle', 'none', 'Color', 'k');
errorbar(x + bar_width/2, parent_means, parent_stds, 'LineStyle', 'none', 'Color', 'k');

hold off;

% Add labels to x-axis
legend({'Child', 'Adult'}); % Specify legend labels using a cell array
xticks(1:numel(networks)); % Correct x-axis tick positions
xticklabels(networks); % Use network names as x-axis labels
xtickangle(45); % Rotate x-axis labels for better readability
xlabel('Network');
ylabel(sprintf('FCTRC Reliability at T=%dmin', scan_length));
title('FCTRC for Each Network');



%% Above plot sorted by parent ascending 

% Sort networks based on the parent mean values at time point 23
[parent_means_sorted, sorted_indices] = sort(parent_means, 'ascend');

% Reorder networks and their corresponding data and errors
sorted_networks = networks(sorted_indices);
sorted_child_means = child_means(sorted_indices);
sorted_parent_means = parent_means(sorted_indices);
sorted_child_stds = child_stds(sorted_indices);
sorted_parent_stds = parent_stds(sorted_indices);

% Define RGB values manually for the colors
child_color = [128, 56, 123] / 255; % RGB values for #80387C
parent_color = [237, 132, 100] / 255; % RGB values for #F78464

% Plotting horizontally
figure(1)
barh(1:numel(networks), [sorted_child_means', sorted_parent_means'], 'BarWidth', 0.6, 'FaceColor', 'flat');
colormap([child_color; parent_color]);


% Add labels to y-axis
legend({'Child', 'Adult'}, 'Location', 'southeastoutside'); % Specify legend labels using a cell array
yticks(1:numel(networks));
yticklabels(sorted_networks);
xlabel('FCTRC Reliability at T=23min');
title('FCTRC for Each Network');



%% % FCTRC Network wise vs scan length plot 

networks= {'FP', 'VAN', 'DMN', 'CON', 'AUD', 'SAL', 'DAN', 'VIS', 'PON', 'Tpole', 'SMd', 'SMl', 'MTL', 'PMN'};
scan_times=1:23;


% Loop over each network
for net_idx = 1:numel(networks)
    % Initialize array to store FCTRC data for the current network
    meanvalues_data_child = zeros(1, numel(scan_times));
    meanvalues_data_parent = zeros(1, numel(scan_times));
    
    % Loop over each scan time
    for time_idx = 1:numel(scan_times)
        % Read Child FCTRC data
        meanvalues_child_file = fullfile(FCTRC_outputpath, ['Child_FCTRC_' networks{net_idx} 'network_23scantimes_meanvalues.csv']);
        meanvalues_child_data = csvread(meanvalues_child_file);
        % Store FCTRC data at the corresponding scan time
        meanvalues_data_child(time_idx) = meanvalues_child_data(scan_times(time_idx));
        
        % Read Parent FCTRC data
        meanvalues_parent_file = fullfile(FCTRC_outputpath, ['Parent_FCTRC_' networks{net_idx} 'network_23scantimes_meanvalues.csv']);
        meanvalues_parent_data = csvread(meanvalues_parent_file);
        % Store FCTRC data at the corresponding scan time
        meanvalues_data_parent(time_idx) = meanvalues_parent_data(scan_times(time_idx));
    end
    
    % Plot FCTRC data for child with shared color and dashed line style
    plot(scan_times, meanvalues_data_child, 'LineWidth', 2, 'Color', '#80387C');
    hold on;
    
    % Plot FCTRC data for parent with shared color and solid line style
    plot(scan_times, meanvalues_data_parent, 'LineWidth', 2, 'Color',  '#F78464');
    
    % Add labels and legend
    title(['FCTRC for ' networks{net_idx}]);
    xlabel('Scan Length (minutes)');
    ylabel('FCTRC Reliability');
    ylim([0 1])
    
    % Create legend entries for child and parent networks
    legend({'Child', 'Parent'}, 'Location', 'southoutside');
    hold off;
    
    % Save the plot
    saveas(gcf, fullfile('/Users/shefalirai/Desktop/', ['FCTRC_Plot_' networks{net_idx} '.png']));
    
    % Close the current figure to start a new one for the next network
    close(gcf);
end
