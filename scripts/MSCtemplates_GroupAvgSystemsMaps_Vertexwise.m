% Template matching script - create template/systems based on MSC data timecourses and Infomap network matching
% (See Rai et. al., HBM, 2024, How do tasks impact the reliability of fmri functional connectivity?)
% For vertex-wise timeseries 


wbcommand='/Applications/workbench/macosx64_apps/wb_command.app/Contents/MacOS/wb_command';

%Open MSC parcelled ciftis from drive
for sub = 1:10
    % Construct file path
    file_path = sprintf('/Volumes/LaCie/parcelled_subjects/sub%d_alltimeseries.dtseries.nii', sub);
    try
        % Load data
        msc_rest{sub} = ciftiopen(file_path, wbcommand);
        msc_rest{sub} = msc_rest{sub}.cdata; % Extract cdata
    catch
        fprintf('Error: file does not exist for subject %d\n', sub)
    end
end

%Open desired network labels
washu=ciftiopen('/Users/shefalirai/Documents/MATLAB/PRCKIDS_1973_Scripts/WashU120_groupNetworks.dtseries.nii', wbcommand);
washu_networks=washu.cdata;

%Extract network time courses for each subject
numNetworks = 16;
numSubjects = 10;
numVertices = 91282;

networkTimeCourses = cell(numNetworks, numSubjects);

for network = 1:numNetworks
    for subject = 1:numSubjects
        % Find rows corresponding to the current network
        networkRows = find(washu_networks == network);

        % Extract time courses for the current network and subject
        networkTimeCourses{network, subject} = mean(msc_rest{subject}(networkRows, :), 1);
    end
end

%Create network connectivity matrices
networkConnectivityMatrices = cell(numNetworks, numSubjects);

for network = 1:numNetworks
    for subject = 1:numSubjects
        % Averaged time course for the current network and subject
        networkTimeCourse = networkTimeCourses{network, subject};

        % Correlate with all other time courses
        connectivityRow = zeros(1, numVertices);
        for vertex = 1:numVertices
            vertexTimeCourse = msc_rest{subject}(vertex, :);
            connectivityRow(vertex) = corr(networkTimeCourse', vertexTimeCourse');
        end

        % Store the connectivity row in the matrix
        networkConnectivityMatrices{network, subject} = connectivityRow;
    end
end


% Fisher transform and average across all 10 MSC subjects
averagedNetworkMaps = cell(1, numNetworks);

for network = 1:numNetworks
    % Fisher z-transformation for each subject's connectivity matrix
    zTransformedMatrices = cellfun(@atanh, networkConnectivityMatrices(network, :), 'UniformOutput', false);

    % Average across subjects
    averagedNetworkMap = mean(cat(3, zTransformedMatrices{:}), 3);

    averagedNetworkMaps{network} = averagedNetworkMap;
end

% Threshold and binarize
threshold = 0.383;

binarizedNetworkMaps = cell(1, numNetworks);

for network = 1:numNetworks
    % Thresholding
    thresholdedMap = averagedNetworkMaps{network};
    thresholdedMap(thresholdedMap < threshold) = 0;

    % Binarization
    binarizedMap = thresholdedMap;
    binarizedMap(binarizedMap >= threshold) = 1;

    binarizedNetworkMaps{network} = binarizedMap';
end


%Visualize on surface and manually check connectivity maps using wb_view
for networks=1:numNetworks
    msc=ciftiopen('/Volumes/LaCie/parcelled_subjects/sub1_alltimeseries.dtseries.nii', wbcommand);
    msc.cdata=binarizedNetworkMaps{1,networks};
    ciftisavereset(msc, sprintf('/Users/shefalirai/Desktop/AvgMSC_templatemaps/AvgMSC_binarizedtemplatemaps_network%d_vertexwise.dscalar.nii', networks), wbcommand);
end




