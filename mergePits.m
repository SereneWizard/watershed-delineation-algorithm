function[fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data, current_max_ID, non_zeros_merge_time, zero_merge_time] = mergePits(fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data, cellsize, current_max_ID, non_zeros_merge_time, zero_merge_time)

id_case = tic; % PROFILING
merge_tic = tic;% PROFILING

PIT_BOTTOM_ELEVATION = 1;
MIN_OUTSIDE_EDGE_ELEVATION = 2;
MIN_INSIDE_EDGE_ELEVATION = 3;
SPILLOVER_ELEVATION = 4;
AREA_CELL_COUNT = 5;
CELLS_TO_BE_FILLED_COUNT = 6;
VOLUME = 7;
PIT_OUTLET_INDEX = 8;
OUTLET_SPILLOVER_FLOW_DIRECTION= 9; 
SPILLOVER_TIME = 10;
SPILLOVER_PIT_ID = 11;
PIT_ID = 12;
PIT_BOTTOM_INDEX = 13;
FILLED_VOLUME = 14;
COLOR = 15;
ALL_INDICES = 16;
BORDER_INDICES = 17;
NET_ACCUMULATION_RATE = 18;

% Identify first pit (minimum spillover time)
first_pit_ID = sort_pit_data{1, PIT_ID};
% rename for convenience and clarity
first_pit = sort_pit_data(1,:);
% Identify second pit which first pit will begin flowing into (either
% another pit or simply out of the DEM over an already pit-less, connected
% surface).
second_pit_ID = sort_pit_data{1, SPILLOVER_PIT_ID}; % ID of pit that the first pit will merge with
% If the second pit is a non-0 pit, then complete the full merge operation
% by creating and calculating the appropriate values for a new pit.
if second_pit_ID ~= 0
    non_zeros_merge_time.id_case = [non_zeros_merge_time.id_case; toc(id_case)]; % PROFILING
    prep_two_pits_tic = tic; % PROFILING
    % Identify second pit and new merged pit
    second_pit_row_idx = find(cell2mat(sort_pit_data(:, PIT_ID)) == second_pit_ID);
    % rename for convenience and clarity
    second_pit = sort_pit_data(second_pit_row_idx,:);
    
    current_max_ID = current_max_ID + 1;
    new_pit_ID = current_max_ID;
    
    % rename for convenience and clarity
    new_pit = num2cell(nan(1,18));
    
    % Calculate initial values 
    new_pit{PIT_ID} = new_pit_ID;
    new_pit{PIT_BOTTOM_ELEVATION} = second_pit{PIT_BOTTOM_ELEVATION};
    new_pit{PIT_BOTTOM_INDEX} = second_pit{PIT_BOTTOM_INDEX};
    non_zeros_merge_time.prep_two_pits = [non_zeros_merge_time.prep_two_pits; toc(prep_two_pits_tic)]; % PROFILING

    % Fill the first pit. Find those cells that drain to the first pit,
    % adjust the DEM to represent filling the first pit, and record the
    % fill volume for the new combined pit.
    puddle_dem(fill_pits == first_pit_ID & fill_dem < first_pit{SPILLOVER_ELEVATION}) = NaN;
    fill_dem_tic = tic; % PROFILING 
    fill_dem(fill_pits == first_pit_ID & fill_dem < first_pit{SPILLOVER_ELEVATION}) = first_pit{SPILLOVER_ELEVATION};
    non_zeros_merge_time.fill_dem = [non_zeros_merge_time.fill_dem; toc(fill_dem_tic)]; % PROFILING 
    
    all_indices_tic = tic; % PROFILING

    new_pit{FILLED_VOLUME} = first_pit{VOLUME} + second_pit{FILLED_VOLUME};
    
    % Add the cells draining to the second pit, adjust the pits matrix by
    % replacing the first and second pit IDs with the new pit ID, and find
    % the total area of the new merged pit.
    new_pit{ALL_INDICES} = [first_pit{ALL_INDICES}, second_pit{ALL_INDICES}];
    non_zeros_merge_time.all_indices = [non_zeros_merge_time.all_indices; toc(all_indices_tic)]; % PROFILING
    
    pits_tic = tic; % PROFILING 
    fill_pits(new_pit{ALL_INDICES}) = new_pit_ID;
    non_zeros_merge_time.pits = [non_zeros_merge_time.pits; toc(pits_tic)]; % PROFILING
    
    border_tic = tic; % PROFILING 

    new_pit{AREA_CELL_COUNT} = numel(new_pit{ALL_INDICES});

    % To reduce the time it takes to find the border cells, the border
    % indices of the two merging pits can be handed to the findBorderData
    % function rather than the full list of indices of the two pits. This
    % function will then return the border indices for the new_pit,
    % excluding those cells that are along the border between the two pits.
    potential_border_indices = [first_pit{BORDER_INDICES}, second_pit{BORDER_INDICES}];

    % Find boundary edge-related information about the pit. This
    % includes internal borders of fully-surrounded polygons.
    [ret1, ret2, ret3, ret4, ret5, ret6, ret7] = findBorderData(potential_border_indices, fill_dem, fill_pits);
    new_pit{MIN_OUTSIDE_EDGE_ELEVATION} = ret1;
    new_pit{MIN_INSIDE_EDGE_ELEVATION} = ret2;
    new_pit{SPILLOVER_ELEVATION} = ret3;
    new_pit{PIT_OUTLET_INDEX} = ret4;
    new_pit{OUTLET_SPILLOVER_FLOW_DIRECTION} = ret5;
    new_pit{SPILLOVER_PIT_ID} = ret6;
    new_pit{BORDER_INDICES} = ret7;
    non_zeros_merge_time.border = [non_zeros_merge_time.border; toc(border_tic)]; % PROFILING 

    calculations_tic = tic; % PROFILING 
    % Calculate spillover elevation-dependent pit values
    new_pit{CELLS_TO_BE_FILLED_COUNT} = nnz(fill_dem(new_pit{ALL_INDICES}) < new_pit{SPILLOVER_ELEVATION});
    new_pit{VOLUME} = findVolume(cellsize, fill_dem, new_pit{ALL_INDICES}, new_pit{SPILLOVER_ELEVATION}, new_pit{CELLS_TO_BE_FILLED_COUNT}, new_pit{FILLED_VOLUME});
    new_pit{NET_ACCUMULATION_RATE} = first_pit{NET_ACCUMULATION_RATE} + second_pit{NET_ACCUMULATION_RATE};
    new_pit{SPILLOVER_TIME} = new_pit{VOLUME}/((cellsize^2).*new_pit{NET_ACCUMULATION_RATE});
    if new_pit{NET_ACCUMULATION_RATE} == 0
        %disp(strcat(['drainage rate:', num2str(new_pit{NET_ACCUMULATION_RATE})]))
        %disp(strcat(['spillover time:', num2str(new_pit{SPILLOVER_TIME})]))
        new_pit{SPILLOVER_TIME} = Inf;
    end
    if new_pit{NET_ACCUMULATION_RATE} < 0
        %disp(strcat(['drainage rate:', num2str(new_pit{NET_ACCUMULATION_RATE})]))
        %if new_pit{SPILLOVER_TIME} < 0
            %disp(strcat(['spillover time:', num2str(new_pit{SPILLOVER_TIME})]))
        %end
        new_pit{SPILLOVER_TIME} = Inf;
    end    
    
    % Take the color of the larger pit with which the first is merging.
    new_pit{COLOR} = second_pit{COLOR};
    non_zeros_merge_time.calculations = [non_zeros_merge_time.calculations; toc(calculations_tic)];

    cleanup_tic = tic; % PROFILING 
    % Replace the first pit sort_pit_data entry with the new pit
    sort_pit_data(1, :) = new_pit;

    % Remove second pits from list.
    sort_pit_data(second_pit_row_idx,:) = [];
        
    zero_merge = 0;
% Otherwise, the first pit is merging with pit 0: it is flowing out of the
% map.
else
    zero_merge_time.id_case = [zero_merge_time.id_case; toc(id_case)]; % PROFILING 
    % Find those cells that drain to the first pit and adjust the DEM to
    % represent filling the first pit.
    puddle_dem(fill_pits == first_pit_ID & fill_dem < first_pit{SPILLOVER_ELEVATION}) = NaN;
    fill_dem_tic = tic;% PROFILING
    fill_dem(fill_pits == first_pit_ID & fill_dem < first_pit{SPILLOVER_ELEVATION}) = first_pit{SPILLOVER_ELEVATION};
    zero_merge_time.fill_dem = [zero_merge_time.fill_dem; toc(fill_dem_tic)];% PROFILING 
    
    % Replace first pit ID in the pits matrix with pit ID 0.
    new_pit_ID = 0;
    pits_tic = tic; % PROFILING 
    fill_pits(first_pit{ALL_INDICES}) = new_pit_ID;
    zero_merge_time. pits = [zero_merge_time.pits; toc(pits_tic)]; % PROFILING

    cleanup_tic = tic;
    % Remove first pit from list.
    sort_pit_data(1, :) = [];
    
    zero_merge = 1;
end
if zero_merge == 1
    % Reverse flow out of the overflowing pit so that flow_direction now
    % correctly shows flow
    %fill_flow_direction = reverseFlowOutOfPit(fill_flow_direction, first_pit{PIT_OUTLET_INDEX}, first_pit{OUTLET_SPILLOVER_FLOW_DIRECTION});
    
    % All pits that spill over into the first or second pit now spill over
    % into the new pit (be it pit 0 or the new, merged pit)
    indices = cell2mat(sort_pit_data(:, SPILLOVER_PIT_ID)) == first_pit_ID | cell2mat(sort_pit_data(:,SPILLOVER_PIT_ID)) == second_pit_ID;
    sort_pit_data(indices, SPILLOVER_PIT_ID) = {new_pit_ID};
    
    % Resort the sort_pit_data matrix after the pit merger changes
    sort_pit_data = sortrows(sort_pit_data, SPILLOVER_TIME);
    zero_merge_time.cleanup = [zero_merge_time.cleanup; toc(cleanup_tic)]; % PROFILING
    zero_merge_time.totals = [zero_merge_time.totals; toc(merge_tic)]; % PROFILING
elseif zero_merge == 0
    % Reverse flow out of the overflowing pit so that flow_direction now
    % correctly shows flow
    %fill_flow_direction = reverseFlowOutOfPit(fill_flow_direction, first_pit{PIT_OUTLET_INDEX}, first_pit{OUTLET_SPILLOVER_FLOW_DIRECTION});
    
    % All pits that spill over into the first or second pit now spill over
    % into the new pit (be it pit 0 or the new, merged pit)
    indices = cell2mat(sort_pit_data(:, SPILLOVER_PIT_ID)) == first_pit_ID | cell2mat(sort_pit_data(:,SPILLOVER_PIT_ID)) == second_pit_ID;
    sort_pit_data(indices, SPILLOVER_PIT_ID) = {new_pit_ID};
    
    % Resort the sort_pit_data matrix after the pit merger changes
    sort_pit_data = sortrows(sort_pit_data, SPILLOVER_TIME);
    non_zeros_merge_time.cleanup = [non_zeros_merge_time.cleanup; toc(cleanup_tic)]; % PROFILING
    non_zeros_merge_time.totals = [non_zeros_merge_time.totals; new_pit{AREA_CELL_COUNT}, toc(merge_tic)]; % PROFILING
end
end