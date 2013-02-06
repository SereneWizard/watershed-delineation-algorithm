function [flow_direction] = d8FlowDirection(dem, drainage, intensity)
flow_direction = zeros(size(dem));
numrows = size(flow_direction, 1);
numcols = size(flow_direction, 2);
equal_slopes = 0;
negative_slopes = 0;

for current_element = 1 : numel(flow_direction)
    % convert to row (r) and column (c) indices
    [r, c] = ind2sub(size(flow_direction), current_element);
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_direction(current_element) = NaN;
        continue;
    end
    if drainage(current_element) <= intensity
        flow_direction(current_element) = -1;
    end
    min_slope = NaN;
    %compute slope to each neighbor and find minimum
    for x = -1 : 1 % loop through neighboring cells
        for y = -1 : 1
            if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                continue;
            end
            if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
                continue; % skip neighbors outside the matrix range
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
            if (isnan(min_slope) || slope <= min_slope) % First iteration
                min_slope = slope;
                % Record for that cell of the flow_direction matrix the
                % angle of the new minimum slope. Taking the modulo of the
                % angle/2*pi results in a positive angle from 0 to 2 pi
                % radians rather than allowing negative angles.
                flow_direction(r, c) = mod(angle, 2*pi);
            end
        end
    end
    
    if min_slope >= 0 % flow may only occur downhill (negative values)
        flow_direction(current_element) = -1;
    end
end 
end
