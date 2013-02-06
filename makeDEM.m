function [dem,numrows,numcols] = makeDEM(data, cellsize)
% COMMENT ME: describe data format
% data = [x-coords in UTM projection (meters), y-coords in UTM 
xmax = max(data(:,1));
xmin = min(data(:,1));
ymax = max(data(:,2));
ymin = min(data(:,2));
%The number of rows or colums is max-min divided by the cellsize.  But, if
%(max-min) modulus cellsize is 0, there must be an additional row because
%of rounding.  Take the following example: The points (0,0) and (2,3) with
%a cellsize of 1 may initially appear to be griddable on a 2x3 grid.  If
%the grid is defined such that (0,0) falls within a grid cell whose range
%is x=0.0000-0.99999 and y=0.0000-0.9999, then point (2,3), by definition,
%fall within a grid cell ranging from x=2.0000-2.9999 and y=3.0000-3.9999
%(one additional row and column to place this in).
numrows = ceil((ymax - ymin)/cellsize);
if mod(ymax - ymin, cellsize) == 0
    numrows = numrows + 1;
end
numcols = ceil((xmax - xmin)/cellsize);
if mod(xmax - xmin, cellsize) == 0
    numcols = numcols + 1;
end

%preallocate matrices to be populated below
dem_sum = zeros(numrows, numcols);
dem_count = zeros(numrows, numcols);
%error_rms = zeros(size(data,1));

%Iterate through all data points, convert to linear indices taking cellsize
%into account, then convert to dem grid indices, create a running sum for
%each grid cell, and a count of points within each grid cell (for
%averaging).
for dem_i = 1:length(data(:,1))
    r = floor((ymax-data(dem_i,2))/cellsize) + 1; %get row and col indices in the DEM for each point
    c = floor((data(dem_i,1)-xmin)/cellsize) + 1; 
    dem_sum(r,c) = dem_sum(r,c) + data(dem_i, 3); %running sum for each cell
    dem_count(r,c) = dem_count(r,c) + 1; %count of points in each cell
end
dem = dem_sum./dem_count; %average for each grid cell from running sum and count
%TODO: calculate above line outside loop

%Calculate error. The loop below cannot be incorporated in the previous
%loop because the dem matrix is not complete upon each iteration. The
%mean is not correct until all points within each cell have been evaluated.
% rmse_sum = 0;
% rmse_count = 0;
% for dem_i = 1:length(data(:,1))
%     row = floor((ymax-data(dem_i,2))/cellsize) + 1; %get row and col coordinates for each point
%     col = floor((data(dem_i,1)-xmin)./cellsize) + 1; 
%     %percent_error(dem_i) = abs(dem(row, col) - data(dem_i, 3))./data(dem_i, 3);
%     rmse_sum = (dem(row,col) - data(dem_i, 3))^2 + rmse_sum; 
%     rmse_count = rmse_count + 1;
% end
% rmse = (rmse_sum/rmse_count)^0.5;

% round elevation values to nearest cm
dem = round(dem*100)/100;