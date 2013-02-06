function[dem] = idwInterpolation(dem)
%Perform inverse distance weighting to smooth over all NaN cells (cells
%with no data occur along matrix edges where lidar data didn't exist due to
%non-square projection or in patches of forest or buildings where ground
%class points did not exist).

% while nnz(isnan(dem)) > 0
%     for cell = 1 : numel(dem)
%         [r, c] = ind2sub(size(dem), cell); %convert to row and column indices
%         if isnan(dem(cell))
%             dem(cell) = idw(dem, r, c);
%         end
%     end
% end

numrows = size(dem, 1);
numcols = size(dem, 2);

dem_copy = dem;
nan_count = 0;
for cell = 1: numel(dem)
    if isnan(dem(cell)) % find NaN cells
        nan_count = nan_count + 1;
        [r, c] = ind2sub(size(dem), cell); %convert to row and column indices
        
        elevations_sum = 0;
        sum_weights = 0;
        for x = -10 : 10 % loop through neighboring cells
            for y = -10 : 10
                if x == 0 && y ==0 % skip center (target) cell of 3x3 neighborhood
                    continue;
                end
                if r+y > numrows || r+y < 1 || c+x > numcols || c+x < 1
                    continue; % skip neighbors outside the matrix range
                end
                [~, distance] = cart2pol(x,y);
                if ~isnan(dem_copy(r+y, c+x))
                    elevations_sum = elevations_sum + (dem_copy(r+y, c+x).*(1/distance));
                    sum_weights = sum_weights + (1/distance);
                end
            end
        end
        if sum_weights < 3
            dem(cell) = NaN;
        else
            dem(cell) = elevations_sum/sum_weights;
        end
    end
end
%strcat('The total number of cells interpolated: ',num2str(nan_count))
end
