%%Plot AllROIs from each Network mean and std values 


directory='/Users/shefalirai/Desktop/PK_ROIs_FCTRCs';
% Define the networks
networks = {'AUD','CON', 'DAN','DMN','FP','MTL','PMN','PON','SAL', 'SMd', 'SMl', 'VAN','VIS'};

% Loop through each network
for network = networks
    % Convert cell array to string
    network = char(network);
    
    % Construct the file paths for mean and standard deviation files
    file_mean_C = fullfile(directory, sprintf('Child_FCTRC_%snetwork_allscantimes_meanvalues.csv', network));
    file_std_C = fullfile(directory, sprintf('Child_FCTRC_%snetwork_allscantimes_stdvalues.csv', network));
    file_mean_P = fullfile(directory, sprintf('Parent_FCTRC_%snetwork_allscantimes_meanvalues.csv', network));
    file_std_P = fullfile(directory, sprintf('Parent_FCTRC_%snetwork_allscantimes_stdvalues.csv', network));
    
    % Load mean and standard deviation values for children and adults
    mean_values_C.(network) = csvread(file_mean_C);
    std_values_C.(network) = csvread(file_std_C);
    mean_values_P.(network) = csvread(file_mean_P);
    std_values_P.(network) = csvread(file_std_P);
end

% Set scan length increment 
scan_length_increment = 30;

% Define x-axis values based on the scan length increments
x_axis = (scan_length_increment * 2 / 60):(scan_length_increment * 2 / 60):(709 * 2 / 60);

%% With colors and line styles

% Plot the mean with standard deviation as error bars for both conditions
% Define colors for networks
networks = {'AUD','CON', 'DAN','DMN','FP','MTL','PMN','PON','SAL', 'SMd', 'SMl', 'VAN','VIS'};
colors = {'#FF5733', '#FFD700', '#C70039', '#900C3F', '#581845', '#5DADE2', '#48C9B0', '#58D68D', '#F4D03F', '#A569BD', '#F39C12', '#3498DB', '#E74C3C'};
colors_2 = {'#FF6E7F', '#FFEC8B', '#7D1935', '#79182E', '#8B5A5A', '#6495ED', '#2E8B57', '#66CDAA', '#FFBF00', '#BC8F8F', '#FFA07A', '#4169E1', '#CD5C5C'};


% Define line styles for child and adult networks
line_styles = {'-', '--'};

for i = 1:length(networks)
    % Create a new figure for each network
    figure;

    % Plot adult networks with dotted lines
    plot(x_axis, mean_values_P.(networks{i}), 'LineWidth', 2, 'Color', colors{i}, 'LineStyle', line_styles{1});

    hold on;

    % Plot child networks with triangle markers
    plot(x_axis, mean_values_C.(networks{i}), 'LineWidth', 2, 'Color', colors_2{i}, 'LineStyle', line_styles{2}, 'Marker', 'v');

    % Set the title
    title(networks{i});

    % Set labels and adjust axes
    xlabel('Scan Length (minutes)');
    ylabel('Mean FC-TRC');
    xlim([1, 25])
    set(gca, 'FontSize', 20);
    % Set the font type
    set(gca, 'FontName', 'Arial');
    % Remove the top and right axis lines
    ax = gca;
    ax.Box = 'off';

    % Add legend for network types
    legend_entries = {'Adult', 'Child'};
    legend(legend_entries, Location="southeast");

    hold off;

    % Save the plot
    saveas(gcf, fullfile('/Users/shefalirai/Desktop/', ['FCTRC_Plot_' networks{i} '.png']));
    
    % Close the current figure to start a new one for the next network
    close(gcf);
end


