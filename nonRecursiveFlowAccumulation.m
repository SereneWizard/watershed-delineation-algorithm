function[flow_accumulation] = nonrecursiveFlowAccumulation(flow_direction, cell)

for idx = 1 : numel(flow_direction);
    listOfPoints = [cell];
    
    i = 1;
    
    while i < length(listOfPoints) + 1
        p = listOfPoints(i);
        [r, c] = ind2sub(size(flow_direction), p);
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
                    neighbor_index = sub2ind(size(flow_direction), r+y, c+x);
                    listOfPoints = [listOfPoints, neighbor_index];
                end
            end
        end
        i = i + 1;
    end
    flow_accumulation(idx) = length(listOfPoints);
end

for idx = 1 : numel(flow_direction)
    [r, c] = ind2sub(size(flow_accumulation), idx);
    if r == numrows || r == 1 || c == numcols || c == 1
        continue;
    end
    if flow_accumulation(idx) ~= check(idx)
        if isnan(flow_accumulation(idx)) && isnan(check(idx))
            continue;
        else
            flow_accumulation(idx);
        end
    end
end

end
