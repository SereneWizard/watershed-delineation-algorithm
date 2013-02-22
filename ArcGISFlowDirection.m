function[flow_direction] = ArcGISFlowDirection(dem)
% Find flat areas and pit bottom cells

flow_direction = zeros(size(dem));
slopes = zeros(size(dem));
[numrows, numcols] = size(dem);
flow_dir_neighborhood = [32 64  128;
                         16 0   1;
                         8  4   2;];
                     
% Flag all pit bottom cells
for current_element = 1 : numel(flow_direction)
    % Convert to row (r) and column (c) indices.
    [r, c] = ind2sub(size(flow_direction), current_element);
    
    % Make border cells NaN because the full neighborhood isn't available
    % for calculations.
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_direction(current_element) = NaN;
        continue;
    end
    min_slope = NaN;
    % Loop through each neighbor and find minimum slope
    for x = -1 : 1
        for y = -1 : 1
            if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                continue;
            end
            
            %Calculate slope to current neighbor
            [angle, distance] = cart2pol(x, y);
            slope = (dem(r+y, c+x) - dem(r, c))/distance;
            
            % Maintain current minimum slope
            if (isnan(min_slope) || slope < min_slope) % check isnan for 1st iteration
                min_slope = slope;
                slopes(current_element) = slope;
            end
        end
    end
%     if min_slope > 0 % one-cell pit
%         slopes(current_element) = -999;
%     elseif min_slope == 0
%         slopes(current_element) = -9999;
%     end
end

for current_element = 1 : numel(flow_direction)
    % Convert to row (r) and column (c) indices.
    [r, c] = ind2sub(size(flow_direction), current_element);
    
    % Make border cells NaN because the full neighborhood isn't available
    % for calculations.
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_direction(current_element) = NaN;
        continue;
    end
    pit_flag = 0;
    min_slope = NaN;
    slope_neighborhood = nan(3, 3);
    % Loop through each neighbor and find minimum slope
    for x = -1 : 1
        for y = -1 : 1
            if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                continue;
            end
            
            %Calculate slope to current neighbor
            [angle, distance] = cart2pol(x, y);
            slope_neighborhood(y+2, x+2) = (dem(r+y, c+x) - dem(r,c))/distance;
            
            if slopes(r+y,c+x) > 0
                pit_flag = 1;
                pit_element = [r+y, c+x];
            end
            
            % Maintain current minimum slope
            if (isnan(min_slope) || slope_neighborhood(y+2, x+2) < min_slope) % check isnan for 1st iteration
                min_slope = slope_neighborhood(y+2, x+2);
                flow_direction(current_element) = flow_dir_neighborhood(y+2, x+2);
            end
        end
    end
    if r == 91 && c == 108
        disp('got here')
        slope_neighborhood
        min_slope == 0
        sum(sum(slope_neighborhood == 0)) > 1
        pit_flag == 1
        slopes(pit_element(1),pit_element(2))== -1* min_slope
        min_slope == 0
        min_slope > 0
        flow_direction(current_element)
    end
    if min_slope > 0 % single pit cell with only upslope neighbors
        flow_direction(current_element) = sum(sum(flow_dir_neighborhood(slope_neighborhood == min_slope)));
    elseif pit_flag == 1 && slopes(pit_element(1),pit_element(2))== -1* min_slope % if adjacent to a pit and that pit's min_slope is the slope to the current cell, then part of a flat spot
        flow_direction(current_element) = sum(sum(flow_dir_neighborhood(slope_neighborhood <= 0)));
    elseif min_slope == 0 && sum(sum(slope_neighborhood==0)) > 1 % flat spot with more than one flat neighbor (only one flat neighbor gets handled automatically)
        flow_direction(current_element) = sum(sum(flow_dir_neighborhood(slope_neighborhood == min_slope)));
    end
end
end