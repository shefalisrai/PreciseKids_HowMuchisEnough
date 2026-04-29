% 143 ROI connectomes 

% Using the csv outputs from Timeseries_143DWROIs_function.m
Dir = '/Users/shefalirai/Desktop/PK_ROIs/';

% Define missing ROIs
missing_ROIs = [9, 14, 40, 41, 46, 86, 93, 116, 126, 130];
total_ROIs = 153;

% Loop through all children or parents
for subject = 1:24

    % Loop through all ROIs
    for roi = 1:total_ROIs
        % Skip if ROI number is in the list of missing ROIs
        if ismember(roi, missing_ROIs)
            continue;
        end
        
        % Construct filenames for child and parent data
        child_filename1 = sprintf('Child_Timeseries_%dROI_sessions1and4.csv', roi);
        child_filename2 = sprintf('Child_Timeseries_%dROI_sessions2and3.csv', roi);
        parent_filename1 = sprintf('Parent_Timeseries_%dROI_sessions1and4.csv', roi);
        parent_filename2 = sprintf('Parent_Timeseries_%dROI_sessions2and3.csv', roi);

        % Read child data from both sessions
        child_data1 = csvread(fullfile(Dir, child_filename1));
        child_data2 = csvread(fullfile(Dir, child_filename2));
        child_subject_data(roi, :) = [child_data1(subject, :) child_data2(subject, :)];

        % Read parent data from both sessions
        parent_data1 = csvread(fullfile(Dir, parent_filename1));
        parent_data2 = csvread(fullfile(Dir, parent_filename2));
        parent_subject_data(roi, :) = [parent_data1(subject, :)  parent_data2(subject, :)];   
    end

    % Replace zeros with NaNs for missing ROIs
    for roi = missing_ROIs
        child_subject_data(roi, :) = NaN;
        parent_subject_data(roi, :) = NaN;
    end
    
    % Store subject data in cell arrays
    child_data{subject} = child_subject_data;
    parent_data{subject} = parent_subject_data;
end




%% Create FC connectomes for children and parents 

% Initialize cell arrays to store functional connectivity connectomes
child_connectomes = cell(24, 1);
parent_connectomes = cell(24, 1);

% Calculate functional connectivity connectomes for children
for subject = 1:24
    % Compute correlation matrix for child subject's ROI time series data
    child_connectome = corr(child_data{subject}');
    
    % Set diagonal elements to NaN
    child_connectome(logical(eye(size(child_connectome)))) = NaN;
    
    % Store correlation matrix in cell array
    child_connectomes{subject} = child_connectome;
end

% Calculate functional connectivity connectomes for parents
for subject = 1:24
    % Compute correlation matrix for parent subject's ROI time series data
    parent_connectome = corr(parent_data{subject}');
    
    % Set diagonal elements to NaN
    parent_connectome(logical(eye(size(parent_connectome)))) = NaN;
    
    % Store correlation matrix in cell array
    parent_connectomes{subject} = parent_connectome;
end

imagesc(child_connectome)


%% Ordered by Network rather than by ROI number

load('143ROI_Orderedby_NetworkGroup.mat');

% Define the new order of ROIs based on matched_networks_final
new_order = cell2mat(matched_networks_final(:, 2));

% Reorder rows in child_data
for subject = 1:numel(child_data)
    % Reorder rows based on new_order
    child_data_reordered{subject} = child_data{subject}(new_order, :);
end

% Reorder rows in parent_data
for subject = 1:numel(parent_data)
    % Reorder rows based on new_order
    parent_data_reordered{subject} = parent_data{subject}(new_order, :);
end

% Initialize cell arrays to store functional connectivity connectomes
child_connectomes_reordered = cell(24, 1);
parent_connectomes_reordered = cell(24, 1);

% Calculate functional connectivity connectomes for children
for subject = 1:24
    % Compute correlation matrix for child subject's ROI time series data
    child_connectome_reordered = corr(child_data_reordered{subject}');
    
    % Set diagonal elements to NaN
    child_connectome_reordered(logical(eye(size(child_connectome_reordered)))) = NaN;
    
    % Store correlation matrix in cell array
    child_connectomes_reordered{subject} = child_connectome_reordered;
end

% Calculate functional connectivity connectomes for parents
for subject = 1:24
    % Compute correlation matrix for parent subject's ROI time series data
    parent_connectome_reordered = corr(parent_data_reordered{subject}');
    
    % Set diagonal elements to NaN
    parent_connectome_reordered(logical(eye(size(parent_connectome_reordered)))) = NaN;
    
    % Store correlation matrix in cell array
    parent_connectomes_reordered{subject} = parent_connectome_reordered;
end

imagesc(parent_connectome_reordered)

%% Extract average of each Network upper traingular FC 

% Define column ranges
aud_columns = 1:8;
con_columns = 9:20;
dan_columns = 21:27;
dmn_columns = 28:57;
fp_columns = 58:66;
mtl_columns = 67:68;
pon_columns = 70:74;
sal_columns = 75:77;
smd_columns = 78:102;
sml_columns = 103:106;
van_columns = 107:109;
vis_columns = 110:143;

% Define all network columns
network_columns = {aud_columns, con_columns, dan_columns, dmn_columns, fp_columns, ...
                   mtl_columns, pon_columns, sal_columns, smd_columns, ...
                   sml_columns, van_columns, vis_columns};

% Loop through child connectomes
for i = 1:24
    % Get the current child and parent connectome matrices
    child_matrix = child_connectomes_reordered{i};
    parent_matrix = parent_connectomes_reordered{i};
    
    % Initialize arrays to store average values
    network_means_child = zeros(1, numel(network_columns));
    network_means_parent = zeros(1, numel(network_columns));

    % Loop through each network column
    for j = 1:numel(network_columns)
        % Extract upper triangular parts of specific columns
        network_values_child = child_matrix(triu(true(143), 1) & ismember(1:143, network_columns{j}));
        network_values_parent = parent_matrix(triu(true(143), 1) & ismember(1:143, network_columns{j}));

        % Compute average values for child and parent connectomes
        network_means_child(j) = mean(network_values_child, 'all');
        network_means_parent(j) = mean(network_values_parent, 'all');
    end
    
    % Store the average values for each network
    child_network_means{i} = network_means_child;
    parent_network_means{i} = network_means_parent;
end

% Convert cell arrays to matrices
child_network_means_matrix = cell2mat(child_network_means');
parent_network_means_matrix = cell2mat(parent_network_means');

childparent_networkmeans=[child_network_means_matrix; parent_network_means_matrix];

% Write matrices to CSV
writematrix(childparent_networkmeans, '/Users/shefalirai/Desktop/PK_decision_tree_inputs/childadult_avgnetworks_withoutpmn_reordered_23mins.csv');


%% Create parent and child vectorize upper traingular FC matrices variables
% 
% % Loop through child connectomes
% for i = 1:24
%     % Get the current child connectome matrix
%     child_matrix = child_connectomes_reordered{i};
%     
%     % Extract upper triangular part and convert to vector
%     child_vectors_reordered{i} = child_matrix(triu(true(143), 1))';
% end
% 
% % Loop through parent connectomes
% for i = 1:24
%     % Get the current parent connectome matrix
%     parent_matrix = parent_connectomes_reordered{i};
%     
%     % Extract upper triangular part and convert to vector
%     parent_vectors_reordered{i} = parent_matrix(triu(true(143), 1))';
% end
% 
% allparticipants_vectors_reordered=[child_vectors_reordered'; parent_vectors_reordered'];
% childadult_vectors_reordered=cell2mat(allparticipants_vectors_reordered); %this is the X matrix for google colab code
% 
% group_label = [zeros(size(childadult_vectors_reordered,1)/2, 1); ones(size(childadult_vectors_reordered,1)/2, 1)]; %this is the Y array for google colab code
% 

%% Write to CSV file

% writematrix(childadult_vectors_reordered, '/Users/shefalirai/Desktop/PK_decision_tree_inputs/childadult_vectors_reordered.csv');
writematrix(group_label, '/Users/shefalirai/Desktop/PK_decision_tree_inputs/group_label.csv');

 
%From here use google colab code titled "PK_ROIFCconnectomes_DecisionTree.ipynb"

