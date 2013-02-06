function[idw_dem_return_value] = idw(dem, r, c)
numrows = size(dem,1);
numcols = size(dem,2);
neighbor_weight = zeros(8,1);
sum = 0;
sum_weights = 0;

% In this instance, distance is in units of cells rather than multiplying
% by cellsize to get distance in meters.  Distance is just used for
% weighting the elevation of adjacent cells.

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
        % neighbor.
        [angle, distance] = cart2pol(x,y);
        if ~isnan(dem(r+y, c+x))
            sum = sum + (dem(r+y, c+x).*(1/distance));
            sum_weights = sum_weights + (1/distance);
        end
    end
end
if sum_weights < 3
    idw_dem_return_value = NaN;    
else
    idw_dem_return_value = sum/sum_weights;
end
end