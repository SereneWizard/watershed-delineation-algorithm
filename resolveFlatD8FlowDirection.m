function[flow_direction] = resolveFlatD8FlowDirection(flow_direction, dem, all_pit_indices, pit_outlet_index, outlet_direction)
% Get row and column indices of pit_outlet_cell
[outlet_r, outlet_c] = ind2sub(size(flow_direction), pit_outlet_index);
spillover_elevation = dem(pit_outlet_index);
indices_to_resolve = all_pit_indices(dem(all_pit_indices) == spillover_elevation);

indices_resolved = nan(size(indices_to_resolve));
next_indices = pit_outlet_index;
indices_resolved_index = 1;

flow_direction(pit_outlet_index) = outlet_direction;
redirected_indices = [pit_outlet_index, nan(1, length(indices_to_resolve)-1)];
redir_idx = 2;

while nnz(isnan(indices_resolved)) ~= 0
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
        indices_resolved(indices_resolved_index) = current_indices(idx);
        indices_resolved_index = indices_resolved_index + 1;
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
                neighbor_index = sub2ind(size(flow_direction), r+y, c+x);
                % The neighbor should be part of the flat area to be
                % resolved, but it shouldn't have alrady been resolved or
                % on the list of next_indices to be resolved.
                if ismember(neighbor_index, indices_to_resolve) && ~ismember(neighbor_index, indices_resolved) && ~ismember(neighbor_index, redirected_indices)
                    next_indices = [next_indices, neighbor_index];
                    % Attempt to direct this neighbor cell directly toward
                    % the outlet. Find the angle between the neighbor and
                    % the pit outlet, and round this angle to the nearest
                    % D8 angle.
                    [angle, distance] = cart2pol(outlet_c - (c+x), outlet_r - (r+y));
                    angle = mod(round(angle/(pi/4))*(pi/4), 2*pi); % Round to nearest D8 direction (45 degree)
                    flow_direction(neighbor_index) = angle;
                    % Determine if the neighbor in that direction is part
                    % of filled area. A direct line between each cell to be
                    % resolved and the pit outlet may not always be
                    % available if there is another pit in between. If not,
                    % simply direct the neighbor to the current_cell. Find
                    % the indices of the cell to which the current_cell is
                    % directed. If it is a diagonal(i.e. x and y are both
                    % 1), the distance is sqrt(2). next_x and next_y will
                    % be either -1, 0, or 1. 
                    [next_x, next_y] = pol2cart(angle, 1);
                    next_x = round(next_x); % round to correct for double precision
                    next_y = round(next_y);
                    if abs(next_x) == 1 && abs(next_y) == 1
                        [next_x, next_y] = pol2cart(angle, sqrt(2));
                    end
                    % If it is not directed toward another cell in the
                    % filled area, then simply direct it toward the
                    % current_cell.
                    if ~ismember(sub2ind(size(flow_direction), r + y + next_y, c + x + next_x), indices_to_resolve)
                        % Verify that the neighbor hasn't already been
                        % adjusted previously.
                        [alt_angle, alt_distance] = cart2pol(-x, -y);
                        flow_direction(neighbor_index) = mod(alt_angle, 2*pi);
                    end
                    redirected_indices(redir_idx) = neighbor_index;
                    redir_idx = redir_idx + 1;
                end
            end
        end
    end
end
end