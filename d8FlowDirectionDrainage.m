function [flow_direction] = d8FlowDirectionDrainage(dem, drainage, intensity)
% This function evaluates the DEM and determines the D8 flow direction for
% each cell. Instead of using the powers of two for each of the eight
% neighors or simply 1-8, an angle was used such that it may be possible in
% the future to implement D-Infinity or other multiple outflow direction
% models without as much effort.

% Initialize flow direction as a matrix of -3s. Borders will become NaNs,
% pits resulting from flow direction will be -1, pits resulting from
% excessive drainage rates will be denoted -2 in case this exception
% becomes important, and valid flow directions will range from 0 to 2pi
% (initializing a matrix full of zeros or NaNs may make tests as to whether
% a cell is part of a pit or has yet to be visited unclear if these values
% have multiple identities).
flow_direction = ones(size(dem)).*-3;
[numrows, numcols] = size(flow_direction);

equal_slopes = 0;
negative_slopes = 0;

for current_cell = 1 : numel(flow_direction)
    % convert to row (r) and column (c) indices
    [r, c] = ind2sub(size(flow_direction), current_cell);
    
    % Set border cells to NaNs
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_direction(current_cell) = NaN;
        continue;
    end
    % If the element is draining faster than accumulation then the cell is
    % a pit (given a -2 to denote this special case).
    if drainage(current_cell) >= intensity
        flow_direction(current_cell) = -2;
        continue;
    end
    min_slope = NaN;
    first_zero_slope_neighbor = NaN;
    
    % Verify the current_cell hasn't previously been set. May've been set
    % in border or drainage conditions, or by resolveFlatD8FlowDirection if
    % a flat area is located.
    if flow_direction(current_cell) == -3
        % Compute slope to each neighbor and find minimum
        for x = -1 : 1 % loop through neighboring cells
            for y = -1 : 1
                if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                    continue;
                end
                % Convert from cartesian to polar coordinates to get flow
                % direction angle (radians) and distance from center cell to
                % neighbor (1 for top,bot,left,right, and sqrt(2) for
                % diagonals).
                [angle, distance] = cart2pol(x,y);
                slope = (dem(r+y, c+x) - dem(r,c))/distance;
                
                % Keep track of interesting slopes
                if (slope == min_slope) % how often do equivalent slopes occur?
                    equal_slopes = equal_slopes + 1;
                elseif (slope < 0) % how often do negative slopes occur?
                    negative_slopes = negative_slopes + 1;
                end
                
                % Maintain current minimum slope
                if (isnan(min_slope) || slope <= min_slope) % nan on first iteration
                    min_slope = slope;
                    % Record for that cell of the flow_direction matrix the
                    % angle of the new minimum slope. Taking the modulo of the
                    % angle/2*pi results in a positive angle from 0 to 2 pi
                    % radians rather than allowing negative angles.
                    flow_direction(current_cell) = mod(angle, 2*pi);
                                        
                    % If the minimum slope is 0 (flat pit bottom), BUT the
                    % neighbor which is of the same elevation has a known
                    % non-pit flow direction (neither along a border(NaN) nor a
                    % pit or yet undetermined(-3:-1)), then allow the current
                    % cell to flow to the neighbor cell. Because the cells are
                    % not visited twice, if the cell was first identified as a
                    % pit, then it will remain a pit such that an infinite loop
                    % of two cells flowing into one another will be avoided.
                    % Record the first zero slope neighbor encountered and use
                    % that first neighbor as the direction to take if the
                    % minimum slope turns out to be 0.
                    %                 if min_slope == 0 && flow_direction(r+y, c+x) > -2 && isnan(first_zero_slope_neighbor)
                    %                     first_zero_slope_neighbor = mod(angle, 2*pi);
                    %                 end
                end
            end
        end

        % Identify flat areas that have no neighbors lower, but have
        % neighbors the same elevation.
        if min_slope == 0 %&& ~isnan(first_zero_slope_neighbor)
            %flow_direction(current_element) = first_zero_slope_neighbor;
            flow_direction(current_cell) = -4;
       elseif min_slope >= 0
            flow_direction(current_cell) = -1;
            % The following serves to group adjacent multi-cell flat
            % pit-bottoms such that numerous adjacent single-cell pits
            % are eliminated.
        end
    end
end


for idx = 1 : numel(flow_direction)
    if flow_direction(idx) == -4
        flow_direction = resolveFlatD8FlowDirection(flow_direction, dem, idx, -1);
    end
end
end