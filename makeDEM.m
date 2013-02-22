function [georef_info, dem] = makeDEM(data, cellsize)
% data is an m x 2 matrix in the form [x-coords, y-coords] where the
% coordinates are UTM Zone 16N projected coordinates (planar coordinates in
% meters).
xmax = max(data(:,1));
xmin = min(data(:,1));
ymax = max(data(:,2));
ymin = min(data(:,2));
% The number of rows or colums is max-min divided by the cellsize.  But, if
% (max-min) modulus cellsize is 0, there must be an additional row because
% of rounding.  For example: The points (0,0) and (2,3) with a cellsize of
% 1 may initially appear to be griddable on a 2x3 grid.  If the grid is
% defined such that (0,0) falls within a grid cell whose range is
% x=0.0000-0.99999 and y=0.0000-0.9999, then point (2,3), by definition,
% fall within a grid cell ranging from x=2.0000-2.9999 and y=3.0000-3.9999
% (one additional row and column would be required to place this point in
% resulting in a 3x4 grid).
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
for data_idx = 1:length(data(:,1))
    r = floor((ymax-data(data_idx,2))/cellsize) + 1; %get row and col indices in the DEM for each point
    c = floor((data(data_idx,1)-xmin)/cellsize) + 1; 
    dem_sum(r,c) = dem_sum(r,c) + data(data_idx, 3); %running sum for each cell
    dem_count(r,c) = dem_count(r,c) + 1; %count of points in each cell
end
dem = dem_sum./dem_count; %average for each grid cell from running sum and count

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

xmin = floor(xmin/3)*3;
ymin = floor(ymin/3)*3;
xmax = xmin + cellsize.*numcols;
ymax = ymin + cellsize.*numrows;

georef_info = maprasterref;
georef_info.XLimWorld = [xmin, xmax];
georef_info.YLimWorld = [ymin, ymax];
georef_info.RasterSize = size(dem);
georef_info.RasterInterpretation = 'cells';
georef_info.ColumnsStartFrom = 'north';
georef_info.RowsStartFrom = 'west';
