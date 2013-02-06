function[pits, pit_data] = pit_data_recurs(dem, flow_dir, pits, pit_data, pit_id, r, c)
neighbor = zeros(8,2);
numrows = size(flow_dir, 1);
numcols = size(flow_dir, 2);

%The neighbor numbering below has been redefined from the previous flow
%direction function such that position 5 is now position 1. Because it is
%desired to determine whether the neighbor is pointing toward the target
%cell (rather than 180 degrees away), neighboring cell of index n can be
%checked if it contains a value == n in the loop below.
neighbor(5,:) = [r, c + 1];
neighbor(6,:) = [r + 1, c + 1];
neighbor(7,:) = [r + 1, c];
neighbor(8,:) = [r + 1, c - 1];
neighbor(1,:) = [r, c - 1];
neighbor(2,:) = [r - 1, c - 1];
neighbor(3,:) = [r - 1, c];
neighbor(4,:) = [r - 1, c + 1];

%Loop through the neighbors (starting with 1 directly to left and moving
%clockwise), and if the neighbor is pointing toward the current cell, call
%recursive function to continue to try and find the pit boundaries.
for n = 1:8
    if neighbor(n,1) > numrows || neighbor(n,1) < 1 || neighbor(n,2) > numcols || neighbor(n,2) < 1 %check that the neighbor is in the DEM range
    else
        if flow_dir(neighbor(n,1),neighbor(n,2)) == n % || flow_dir(neighbor(n_pit_el)) == 0 %if the neighbor is pointing to the target cell or it is 0(indicating a flat pit bottom several cells wide)
            [pits, pit_data] = pit_data_recurs(dem, flow_dir, pits, pit_data, pit_id, neighbor(n,1), neighbor(n,2), numrows, numcols); % call recursive IDing function
        elseif pits(neighbor(n,1),neighbor(n,2)) ~= pit_id % if the neighbor is not part of currrent pit (and, then, it must be along a basin/pit edge)
            if isnan(pit_data(pit_id,4)) || ((dem(neighbor(n,1),neighbor(n,2)) <= pit_data(pit_id,4)) && (dem(r, c) <= pit_data(pit_id,4))) % if minimum ridge elevation value is still NaN from initialization or if the ridge elevations (in and the neighbor just out of the pit) are less than the current minimum ridge elevation in the pit
                pit_data(pit_id,2) = dem(neighbor(n,1),neighbor(n,2)); % set minimum ridge elevation(outside pit) to current ridge elevation(outside pit)
                pit_data(pit_id,3) = dem(r, c); % set minimum ridge elevation to current ridge elevation
                pit_data(pit_id,4) = max(pit_data(pit_id,2:3)); % both 2 and 3 must be less than current spillover elevation (from the above if statement), but maximum of these two will be the new minimum elevation for spillover
                pit_data(pit_id,8) = sub2ind(size(pits), r, c); % index of outlet cell at pit boundary
                pit_data(pit_id,9) = n; % direction of outlet cell just outside the pit boundary to be reversed
                pit_data(pit_id,11) = pits(neighbor(n,1),neighbor(n,2)); % ID of pit that current pit flows into
            end
        end
    end
end