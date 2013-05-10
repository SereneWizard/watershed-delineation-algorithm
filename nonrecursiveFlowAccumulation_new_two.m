function[flow_accum_list] = nonrecursiveFlowAccumulation_new_two(flow_direction, check)
flow_accum_list = cell(size(flow_direction));

for idx = 1 : numel(flow_accum_list)
    flow_accum_list{idx} = zeros(numel(flow_accum_list),1);
end

flow_accum_list_pointer = ones(size(flow_accum_list));

[numrows, numcols] = size(flow_accum_list);
% Loop through all cells in the DEM
for original_cell = 1 : numel(flow_accum_list)    
    % If the cell has been visited previously (when finding the upslope
    % cells of a prior cell), it's list of indices will no longer be empty.
    % By definition, no additional upslope cell can be identified so
    % there is no need to process this cell again.
    if nnz(flow_accum_list{original_cell}) == 0
        flow_accum_list{original_cell}(flow_accum_list_pointer(original_cell)) = original_cell;
        flow_accum_list_pointer(original_cell) = flow_accum_list_pointer(original_cell) + 1;        
        
        i = 1;
        
        % Begin finding the upslope cells. Indices of additional cells to
        % trace upslope will be added to the original_cell's list while i
        % will count each time an additional cell has been checked.
        % Continue until there are no upslope cells to check .
        while i < nnz(flow_accum_list{original_cell}) + 1
            current_cell = flow_accum_list{original_cell}(i);
            if nnz(flow_accum_list{current_cell}) <= 1
                [r, c] = ind2sub(size(flow_direction), current_cell);
                for x = -1 : 1 % loop through neighboring cells
                    for y = -1 : 1
                        if x == 0 && y ==0
                            continue; % skip center (target) cell of 3x3 neighborhood
                        end
                        if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
                            continue; % skip neighbors outside the matrix range
                        end
                        neighbor_cell = sub2ind(size(flow_direction), r+y, c+x);
                        
                        % check if the flow direction of the neighbor points
                        % toward the center cell (opposite the angle of center
                        % to neighbor). If so, add that neighbor index to the
                        % list of indices draining to the idx cell.
                        if flow_direction(r+y, c+x) == mod(cart2pol(x, y)-pi, 2*pi)
                            
                            % If the neighbor is empty, then it hasn't been
                            % processed previously. Add the neighboring cell to
                            % the appropriate lists.
                            if nnz(flow_accum_list{neighbor_cell}) == 0
                                flow_accum_list{neighbor_cell}(flow_accum_list_pointer(neighbor_cell)) = neighbor_cell;
                                flow_accum_list_pointer(neighbor_cell) = flow_accum_list_pointer(neighbor_cell) + 1;
                                % This section of the function serves to update
                                % the list of upslope cells for all cells
                                % traversed as the function processes the
                                % original_cell index.
                                for ix = 1 : numel(flow_accum_list{original_cell})
                                    if flow_accum_list{original_cell}(ix) ~= 0
                                        if ismember(current_cell, flow_accum_list{flow_accum_list{original_cell}(ix)})
                                            flow_accum_list{flow_accum_list{original_cell}(ix)}(flow_accum_list_pointer(flow_accum_list{original_cell}(ix))) = neighbor_cell;
                                            flow_accum_list_pointer(flow_accum_list{original_cell}(ix)) = flow_accum_list_pointer(flow_accum_list{original_cell}(ix)) + 1;
                                        end
                                    end
                                end
                                % If the cell isn't empty, it has been previously
                                % visited. Add the list of indices found previously
                                % to all lists containing the current_cell index.
                            else
                                for inx = 1 : numel(flow_accum_list{original_cell})
                                    if flow_accum_list{original_cell}(inx) ~= 0
                                        if ismember(current_cell, flow_accum_list{flow_accum_list{original_cell}(inx)})
                                            flow_accum_list{flow_accum_list{original_cell}(inx)}(flow_accum_list_pointer(flow_accum_list{original_cell}(inx))) = neighbor_cell;
                                            flow_accum_list_pointer(flow_accum_list{original_cell}(inx)) = flow_accum_list_pointer(flow_accum_list{original_cell}(inx)) + 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            i = i + 1;            
        end
    end
end

for idx = 1 : numel(flow_accum_list)
    flow_accumulation(idx) = nnz(flow_accum_list{idx});
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
'nonrecursiveFlowAccumulation_new'
cellsoff
end
