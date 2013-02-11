function[min_outside_border, min_inside_border, spillover_elevation, pit_outlet_idx, outlet_spillover_flow_direction, spill_into_pit_id, border_indices] = findBorderData(indices_draining_to_desired_cell, dem, pits)
% This function loops through each of the indices that are part of the pit
% of interest, and finds the critical pieces of information regarding the
% boundaries and how the pit will overflow during rainfall.

% When this function is called during the mergePits function,
% indices_draining_to_desired_cell is actually a list of potential border
% indices (the list of border indices of the two merging pits) where the
% cells that connect the two pits are no longer along the border of the new
% pit. This should be faster than passing the entire list of new pit
% indices to this function as was done in the Pits function.

[numrows, numcols] = size(pits);

min_outside_border = NaN;
min_inside_border = NaN;
spillover_elevation = NaN;
pit_outlet_idx = NaN;
outlet_spillover_flow_direction = NaN;
spill_into_pit_id = NaN;
border_indices = indices_draining_to_desired_cell;

% Look through each of the indices passed to the function. The list of
% indices is traversed in reverse order because the cell will be removed
% from the list of border indices if it is not along the border of the pit.
for idx = numel(indices_draining_to_desired_cell):-1:1
    % linear and subscript indices of current cell
    current_cell = indices_draining_to_desired_cell(idx);
    [r, c] = ind2sub(size(pits), current_cell);
    on_border = 0;
    for x = -1 : 1 % loop through neighboring cells
        for y = -1 : 1
            if x == 0 && y ==0 
                continue; % skip center cell of 3x3 neighborhood
            end
            if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
                continue; % skip neighbors outside the matrix range
            end
            
            % If the neighbor is outside the pit, the border has been
            % reached.
            if pits(r+y, c+x) ~= pits(indices_draining_to_desired_cell(idx))
                 % if minimum ridge elevation value is still NaN from
                 % initialization or if the ridge elevations (in and the
                 % neighbor just out of the pit) are BOTH less than the current
                 % minimum ridge elevation in the pit
                 on_border = 1;
                 cur_cell_elev = dem(r, c);
                 neighbor_elev = dem(r+y, c+x);
                 if isnan(spillover_elevation) || (cur_cell_elev <= spillover_elevation && neighbor_elev <= spillover_elevation)
                     min_outside_border = neighbor_elev;
                     min_inside_border = cur_cell_elev;
                     spillover_elevation = max([min_inside_border, min_outside_border]);
                     pit_outlet_idx = current_cell;
                     outlet_spillover_flow_direction = mod(cart2pol(x, y), 2*pi);
                     spill_into_pit_id = pits(r+y, c+x);
                 end
            end
        end
    end
    % Else, if the neighbor is not outside the pit it is along
    % the shared border when two pits merge and should be
    % removed from the list of border_indices.
    if on_border == 0
        border_indices(idx) = [];
    end
end
end