
% Define a function to find connected components within each network
function [ROIs] = find_ROIs(network_data)
    % Initialize cell array to store ROIs
    ROIs = cell(max(network_data), 1);
    
    for i = 1:max(network_data)
        % Find indices of vertices belonging to the current network
        network_indices = find(network_data == i);
        
        % Store connected components as ROIs
        ROIs{i} = network_indices;
    end
end