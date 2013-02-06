function[min_outside_border, min_inside_border, spillover_elevation, pit_outlet_idx, outlet_spillover_flow_direction, spill_into_pit_id, border_indices] = findBorderData(indices_draining_to_desired_cell, dem, pits)
% This function loops through each of the indices that are part of the pit
% of interest, and finds the critical pieces of information regarding the
% boundaries and how the pit will overflow during rainfall.

[numrows, numcols] = size(pits);

min_outside_border = NaN;
min_inside_border = NaN;
spillover_elevation = NaN;
pit_outlet_idx = NaN;
outlet_spillover_flow_direction = NaN;
spill_into_pit_id = NaN;
border_indices = [];

for idx = 1:numel(indices_draining_to_desired_cell)
    % linear and subscript indices of current cell
    current_cell = indices_draining_to_desired_cell(idx);
    [r, c] = ind2sub(size(pits), current_cell);
    for x = -1 : 1 % loop through neighboring cells
        for y = -1 : 1
            if x == 0 && y ==0 
                continue; % skip center cell of 3x3 neighborhood
            end
            if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
                continue; % skip neighbors outside the matrix range
            end
            
            neighbor_cell = sub2ind(size(pits), r+y, c+x);
            % If the neighbor is outside the pit, the border has been
            % reached.
            if pits(neighbor_cell) ~= pits(indices_draining_to_desired_cell(idx))
                 % if minimum ridge elevation value is still NaN from
                 % initialization or if the ridge elevations (in and the
                 % neighbor just out of the pit) are BOTH less than the current
                 % minimum ridge elevation in the pit
                 cur_cell_elev = dem(r, c);
                 if ~ismember(current_cell, border_indices)
                     border_indices = [border_indices, current_cell];
                 end
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
end
end