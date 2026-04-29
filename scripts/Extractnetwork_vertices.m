function [network_DORA, network_YT, network_RX] = Extractnetwork_vertices(network_number, dtseries_sessions_DORA, dtseries_sessions_YT, dtseries_sessions_RX)
%Extract network vertices from each task variable
% we are not removing SNR regions since we want specific vertices to be extracted that may be in the SNR region

parent_networkconsensus_map=ciftiopen('/Users/shefalirai/Desktop/PK_networkassignment/Parent_alltasks_templatematching_66percent_networkconsensusmap.dscalar.nii', wbcommand);
parent_networkconsensus=parent_networkconsensus_map.cdata;

% Find the DMN vertices 
net_vertices = find(parent_networkconsensus(:,1) == network_number);

% Define the cell arrays corresponding to each variable
variables = {dtseries_sessions_DORA, dtseries_sessions_YT, dtseries_sessions_RX};

% Initialize cell arrays to store the extracted matrices for each variable
network_DORA = cell(size(dtseries_sessions_DORA));
network_YT = cell(size(dtseries_sessions_YT));
network_RX = cell(size(dtseries_sessions_RX));

% Loop through each variable
for v = 1:numel(variables)
    % Loop through each cell in the current variable
    for i = 1:numel(variables{v})
        % Check if the cell is empty
        if isempty(variables{v}{i})
            % If empty, continue to the next iteration
            continue;
        end
        
        % Get the matrix from the current cell
        current_matrix = variables{v}{i};
        
        % Extract the rows corresponding to dmn_vertices
        extracted_matrix = current_matrix(net_vertices,:);
        
        % Store the extracted matrix in the corresponding cell of the output cell array
        switch v
            case 1
                network_DORA{i} = extracted_matrix;
            case 2
                network_YT{i} = extracted_matrix;
            case 3
                network_RX{i} = extracted_matrix;
        end
    end
end

end

