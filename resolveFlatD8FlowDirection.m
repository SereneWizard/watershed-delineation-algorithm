function[flow_direction] = resolveFlatD8FlowDirection(flow_direction, dem, flat_cell, outlet_direction)
% This is a general purpose function which resolves flat areas, including
% those those found in the original DEM as well as those resulting from
% filling/merging operations. In the case of flat areas resulting from
% filling/merging operations, the outlet cell index and the direction which
% the outlet will overflow toward may be specified. In the case of initial
% flat pit bottoms in the original DEM, the first cell that is found in a
% flat area is handed in and the direction of this cell should be specified
% as a -1 (pit resulting from elevation rather than drainaga) and the
% adjacent flat cells shall be directed toward this pit.

[numrows, numcols] = size(flow_direction);

% Get spillover elevation of pit_outlet_cell.
flat_spot_elevation = dem(flat_cell);

next_indices = flat_cell;
redirected_indices = flat_cell;
flow_direction(flat_cell) = outlet_direction;

% Continue until there are no more next_indices to be resolved (only
% adjacent, flat indices are located and added to the list of
% next_indices).
while ~isempty(next_indices)
    % Update current_indices to be operated on from the next_indices in
    % line and clear the next_indices so they may be populated while
    % searching the neighbors of the current_indices.
    current_indices = next_indices;
    next_indices = [];
    for idx = 1 : length(current_indices)
        % An index isn't resolved until its eight neighbors have been
        % checked. Add current_indices to the list of indices_resolved and
        % increment the index of the preallocated list. Rename index of
        % current_cell operated on for clarity, and get row and column
        % indices of that point.
        current_cell = current_indices(idx);
        [r, c] = ind2sub(size(flow_direction), current_cell);
        
        % Search the current_cell's eight neighbors for any unresolved
        % cells. This is the essence of this method in that it begins at
        % the outlet and works to the furthest cells such that complicated
        % obstructions can be navigated.
        for x = -1 : 1
            for y = -1 : 1
                if x == 0 && y == 0 % skip center (current) cell
                    continue;
                end
                
                % skip neighbors on the border edge and outside the matrix range
                if r+y >= numrows || r+y <= 1 || c+x >= numcols || c+x <= 1
                    continue; 
                end
                
                neighbor_index = sub2ind(size(flow_direction), r+y, c+x);
                % The neighbor should be the flat_spot_elevation and it
                % should be marked as a flat area without a valid (0 - 2pi)
                % flow_direction, but it shouldn't have already been
                % redirected.
                if dem(neighbor_index) == flat_spot_elevation && ~ismember(neighbor_index, redirected_indices) && flow_direction(neighbor_index) == -4
                    next_indices = [next_indices, neighbor_index];
                    [alt_angle, alt_distance] = cart2pol(-x, -y); % Get the angle for a neighbor opposite the current neighbor (same as getting the 180 degree opposite angle). This angle will be used to point the neighbor back towards current cell.
                    flow_direction(neighbor_index) = mod(alt_angle, 2*pi); % Make the angle a positive number so all angles are from 0 - 2pi
                    redirected_indices = [redirected_indices, neighbor_index];
                end
            end
        end
    end
end
end