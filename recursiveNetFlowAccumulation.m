function [net_flow_accumulation] = recursiveNetFlowAccumulation(net_flow_accumulation, flow_direction, drainage, intensity, cell)
% This is a recursive function which finds the volume (taking into account
% rainfall and drainage along the flow paths) flowing into the cell of
% interest, and returns this updated flow_accumulation matrix. For any
% given cell, this function should only be called on it once, altering the
% cell from the original NaN value and allowing other cells to get the flow
% accumulation of the cell without ever traversing through this cell again.

% Each cell should count itself to avoid dividing by zero in future
% calculations.
net_flow_accumulation(cell) = (1.*intensity)-drainage(cell);

numrows = size(flow_direction, 1); % number of rows
numcols = size(flow_direction, 2); % number of columns

% convert to row (r) and column (c) indices
[r, c] = ind2sub(size(flow_direction), cell); 

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
            neighbor_cell = sub2ind(size(flow_direction), r+y, c+x);            
            % If the flow accumulation for that cell hasn't yet been
            % determined, call the recursively call the flow accumulation
            % function on that cell.
            if isnan(net_flow_accumulation(neighbor_cell))
                net_flow_accumulation = recursiveNetFlowAccumulation(net_flow_accumulation, flow_direction, neighbor_cell);
            end
            % Add the flow accumulation of the neighboring cell to the
            % flow accumulation of the current cell of focus.
            net_flow_accumulation(cell) = net_flow_accumulation(cell) + net_flow_accumulation(neighbor_cell);
        end
    end
end
if net_flow_accumulation(cell) < 0
    net_flow_accumulation(cell) = 0;
end
end