function[flow_accumulation] = nonRecursiveFlowAccumulationNEW(flow_direction, dem, check)

flow_accumulation = ones(size(flow_direction));
[numrows, numcols] = size(flow_direction);

% Sort all elevation data from highest elevation to lowest
[sorted_elevations, sorted_indices] = sort(reshape(dem,numel(dem),1), 'descend');

for idx = 1 : numel(sorted_indices)
    current_cell_idx = sorted_indices(idx);
    % Set border cells to NaNs
    [r, c] = ind2sub(size(flow_accumulation), current_cell_idx);
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_direction(current_cell_idx) = NaN;
        continue;
    end
    
    downslope_cell = NaN;
    % Find the neighbor to which the current cell is directed and increase
    % that cell's flow accumulation.
    for x = -1 : 1 % loop through neighboring cells
        for y = -1 : 1
            if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                continue;
            end
            
            % Convert from cartesian to polar coordinates to get flow
            % direction angle (radians) and distance from center cell to
            % neighbor (1 for top,bot,left,right, and sqrt(2) for
            % diagonals).
            [angle, ~] = cart2pol(x,y);
            if flow_direction(current_cell_idx) == mod(angle, 2*pi)
%                 if r+y == 46 && c+x == 141
%                     r,c
%                     flow_direction(current_cell_idx)
%                     flow_accumulation(current_cell_idx)
%                     check(current_cell_idx)
%                 end
                downslope_cell = sub2ind(size(flow_direction), r+y, c+x);
            end
        end
    end
    if isnan(downslope_cell)
        continue;
    else
        flow_accumulation(downslope_cell) = flow_accumulation(downslope_cell) + flow_accumulation(current_cell_idx);
    end
end

cellsoff = 0;
for idx = 1 : numel(flow_direction)
    [r, c] = ind2sub(size(flow_accumulation), idx);
    if r == numrows || r == 1 || c == numcols || c == 1
        continue;
    end
    if flow_accumulation(idx) ~= check(idx)
        if isnan(flow_accumulation(idx)) && isnan(check(idx))
            continue;
        else
            cellsoff = cellsoff+1;
        end
    end
end
'nonRecursiveFlowAccumulationNEW'
cellsoff
end