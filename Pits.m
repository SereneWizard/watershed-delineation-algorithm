function[pits, pit_data, color_map] = Pits(dem, drainage, flow_direction, cellsize, intensity)
%This function identifies each unique pit with an ID number, creates a map
%so each pit may be displayed with a different color, and generates a
%matrix of pit data. Each pit is in a different row, and each row contains
%the following information about the pit:
%  1) minimum elevation at pit bottom,
%  2) minimum elevation just outside pit edges (cells adjacent pit edges)
%  3) minimum elevation at pit edges
%  4) spillover elevation. maximum of 2 & 3 (this handles a special case)
%  5) flow accumulation
%  6) number of cells that will be inundated at overflow,
%  7) retention volume (in cubic meters),
%  8) index of the outlet element, 
%  9) flow direction of the cell to which the pit outlets to
% 10) time until the pit overflows in hours,
% 11) ID of the pit that it will overflow into, and 
% 12) the pit ID (pits will be sorted later, and so the pit ID cannot be
%     associated to the row 
% 13) pit bottom index 
% 14) volume of the pit which has been filled in previous pit
%     filling/merging operations
% 15) colormap for display purposes
% 16) list of indices that are part of the pit
% 17) list of indices along the borders of the pit
% 18) net accumulation rate

PIT_BOTTOM_ELEVATION = 1;
MIN_OUTSIDE_EDGE_ELEVATION = 2;
MIN_INSIDE_EDGE_ELEVATION = 3;
SPILLOVER_ELEVATION = 4;
AREA_CELL_COUNT = 5;
CELLS_TO_BE_FILLED_COUNT = 6; % at spillover, the area of inundated cells (# of cells)
VOLUME = 7;
PIT_OUTLET_INDEX = 8; % in the pit (corresponds to point where #3 occurs)
OUTLET_SPILLOVER_FLOW_DIRECTION = 9; 
SPILLOVER_TIME = 10;
SPILLOVER_PIT_ID = 11;
PIT_ID = 12;
PIT_BOTTOM_INDEX = 13;
FILLED_VOLUME = 14;
COLOR = 15;
ALL_INDICES = 16;
BORDER_INDICES = 17;
NET_ACCUMULATION_RATE = 18;

% Preallocate variables
pits = zeros(size(flow_direction)); % matrix identifying pits (pit map)
pit_data = num2cell(nan(sum(sum(flow_direction < 0)), 18)); % matrix of data for each pit
list_of_pit_indices = nan(sum(sum(flow_direction < 0)), 1);

cur_pit_id = 1; % initialize pit numbering

% Pits must first be identified in the pit matrix in order to return the
% correct pit ID that each pit flows into (if not, many of these pits will
% flow into yet unidentified pits that have ID 0).
for cell = 1 : numel(pits)
    if flow_direction(cell) < 0 % check to see that it is pit
        % add current cell to list of pit indices
        list_of_pit_indices(cur_pit_id) = cell;
        
        % Identify those cells which flow into the pit
        current_pit = pit_data(cur_pit_id, :);
        current_pit{ALL_INDICES} = [];
        [current_pit{ALL_INDICES}] = findCellsDrainingToPoint(flow_direction, cell, current_pit{ALL_INDICES});
        pits(current_pit{ALL_INDICES}) = cur_pit_id;
        
        % place current_pit back into pit_data matrix
        pit_data(cur_pit_id, :) = current_pit;
        % Update pit id to a new one for the next time
        cur_pit_id = cur_pit_id + 1;
    elseif isnan(flow_direction(cell))
        % Edge nan cells should be identified as pit ID 0
        pits(cell) = 0;
    end
end

cur_pit_id = 1;% re-initialize pit numbering for the pit_data matrix
% Gather pit_data for each pit
for list_idx = 1 : numel(list_of_pit_indices)
    % rename for convenience and clarity
    cur_pit_cell = list_of_pit_indices(list_idx);
    current_pit = pit_data(cur_pit_id, :);
    
    current_pit{PIT_ID} = cur_pit_id;
    current_pit{PIT_BOTTOM_ELEVATION} = dem(cur_pit_cell);
    current_pit{PIT_BOTTOM_INDEX} = cur_pit_cell;
    
    % Get the count of cells for that pit using the list of indices found
    % identification loop above.
    current_pit{AREA_CELL_COUNT} = numel(current_pit{ALL_INDICES});
    current_pit{NET_ACCUMULATION_RATE} = intensity.*current_pit{AREA_CELL_COUNT} - sum(drainage(current_pit{ALL_INDICES}));
    
    % Find boundary edge-related information about the pit. This
    % includes internal borders of fully-surrounded polygons.
    [ret1, ret2, ret3, ret4, ret5, ret6, ret7] = findBorderData(current_pit{ALL_INDICES}, dem, pits);
    current_pit{MIN_OUTSIDE_EDGE_ELEVATION} = ret1;
    current_pit{MIN_INSIDE_EDGE_ELEVATION} = ret2;
    current_pit{SPILLOVER_ELEVATION} = ret3;
    current_pit{PIT_OUTLET_INDEX} = ret4;
    current_pit{OUTLET_SPILLOVER_FLOW_DIRECTION} = ret5;
    current_pit{SPILLOVER_PIT_ID} = ret6;
    current_pit{BORDER_INDICES} = ret7;
    
    % Calculate spillover-dependant values
    current_pit{CELLS_TO_BE_FILLED_COUNT} = nnz(dem(current_pit{ALL_INDICES}) < current_pit{SPILLOVER_ELEVATION});
    current_pit{VOLUME} = findVolume(cellsize, dem, current_pit{ALL_INDICES}, current_pit{SPILLOVER_ELEVATION}, current_pit{CELLS_TO_BE_FILLED_COUNT}, 0);
    current_pit{SPILLOVER_TIME} = current_pit{VOLUME}/((cellsize^2).*current_pit{NET_ACCUMULATION_RATE});
    % If the pit is not accumulating flow, set time equal to Inf rather
    % than allowing negative values. Negative values will be minima when
    % sorting the pits based on spillover time. Instead, these pits will
    % not be the first to overflow, but rather will only enguage in a
    % merging operation when another pit overflows into them.
    if current_pit{NET_ACCUMULATION_RATE} <= 0
        current_pit{SPILLOVER_TIME} = Inf;
    end
    
    % Filling has not begun
    current_pit{FILLED_VOLUME} = 0;
    
    % Assign a random colormap value to this pit (avoiding dark colors with
    % RGB <.3).
    current_pit{COLOR} = 0.3 + (rand(1,3).*(1-.3));
    
    % place current_pit back into pit_data matrix
    pit_data(cur_pit_id, :) = current_pit;
    % Increment pit id for the any additional pits
    cur_pit_id = cur_pit_id + 1;
end
% Set up original pits colormap
color_map = [0 0 0; cell2mat(pit_data(:, COLOR))];
end