function [flow_direction] = reverseFlowOutOfPit(flow_direction, current_cell, direction_to_previous_cell)
% This function is called on the outlet cell of a pit, and recursively
% traces back toward the pit bottom, reversing flow such that all cells
% pointing toward the pit cell will be redirected toward the pit outlet.
% current_cell is the index of the current cell while
% direction_to_previous_cell is the direction from the current cell to
% where it needs to be reversed to.

% record current cell's current flow direction (overwritten in next step)
current_cell_flow_direction = flow_direction(current_cell);

% Redirect flow direction of the current cell in the flow_direction matrix
% toward the previous cell (this direction is passed in as an input).
flow_direction(current_cell) = direction_to_previous_cell;


% Check if the current cell was the pit bottom. Otherwise continue
% recursive function calls.
if current_cell_flow_direction >= 0
    % Reverse flow direction of current cell to determine the direction from
    % the next cell to the current cell.  This direction is passed to the next
    % cell so it may point back to this current cell.
    direction_from_next_cell_to_current_cell = mod(current_cell_flow_direction - pi, 2*pi);
    
    % Get current_cell indices and current direction. Then, find the
    % indices of the cell to which the current cell is directed. If it is
    % a diagonal(i.e. x and y are both 1), the distance is sqrt(2).
    [r, c] = ind2sub(size(flow_direction), current_cell);
    [next_x, next_y] = pol2cart(current_cell_flow_direction, 1);
    next_x = round(next_x); % correct for double precision representation of the angle by rounding to nearest integer
    next_y = round(next_y);
    if abs(next_x) == 1 && abs(next_y) == 1
        [next_x, next_y] = pol2cart(current_cell_flow_direction, sqrt(2));
    end
    
    % Get linear index of next cell given subscript indices next_x, next_y
    next_cell = sub2ind(size(flow_direction), r+next_y, c+next_x);
    [flow_direction] = reverseFlowOutOfPit(flow_direction, next_cell, direction_from_next_cell_to_current_cell);
end
end