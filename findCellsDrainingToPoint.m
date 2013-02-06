function[indices_draining_to_desired_cell] = findCellsDrainingToPoint(flow_direction, cell, indices_draining_to_desired_cell)
% This is a recursive function which finds and returns indices of those
% cells that flow to the cell ("cell") of interest.

[numrows, numcols] = size(flow_direction); % number of rows and columns

% convert to row (r) and column (c) indices
[r, c] = ind2sub(size(flow_direction), cell); 

% append current cell to list of indices that drain to the desired cell
indices_draining_to_desired_cell = [indices_draining_to_desired_cell, cell];

for x = -1 : 1 % loop through neighboring cells
    for y = -1 : 1
        if x == 0 && y ==0 
            continue; % skip center (target) cell of 3x3 neighborhood
        end
        if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
            continue; % skip neighbors outside the matrix range
        end
        
        % check if the flow direction of the neighbor points toward the
        % center cell (opposite the angle of center to neighbor)
        if flow_direction(r+y, c+x) == mod(cart2pol(x, y)-pi, 2*pi)
            % get linear index of neighbor
            neighbor_index = sub2ind(size(flow_direction), r+y, c+x);            
            % call function recursively
            [indices_draining_to_desired_cell] = findCellsDrainingToPoint(flow_direction, neighbor_index, indices_draining_to_desired_cell);
        end
    end
end
end

