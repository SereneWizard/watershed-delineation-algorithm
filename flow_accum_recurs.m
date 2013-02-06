function[flow_accum, count] = flow_accum_recurs(flow_dir, r, c, flow_accum)
numrows = size(flow_dir, 1);
numcols = size(flow_dir, 2);
count = 0;
neighbor = zeros(8,2);
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

for n = 1:8
    if neighbor(n,1) > numrows || neighbor(n,1) < 1 || neighbor(n,2) > numcols || neighbor(n,2) < 1 %check that the neighbor is in the DEM range
    else
        if flow_dir(neighbor(n,1),neighbor(n,2)) == n
%If the neighbor is flowing to the target cell, increment count by one and
%also add the upslope area flowing to that neighbor cell.
            [flow_accum, flow_accum(neighbor(n,1),neighbor(n,2))] = flow_accum_recurs(flow_dir, neighbor(n,1), neighbor(n,2), flow_accum);
            count = flow_accum(neighbor(n,1),neighbor(n,2)) + count + 1;
        end
    end
end