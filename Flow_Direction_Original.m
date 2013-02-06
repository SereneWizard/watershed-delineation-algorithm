function [flow_dir,vec_field] = Flow_Direction(dem,cellsize)
neighbors = zeros(8,1);
flow_dir = zeros(size(dem));

flow_vector_x = zeros(size(dem));
flow_vector_y = zeros(size(dem));
flow_vector_u = zeros(size(dem));
flow_vector_v = zeros(size(dem));

% The dir_vec matrix specifies the relative distance vector for each
% of the 8 directions, and takes the form [delta x,delta y]
dir_vec(1,:) = [0.5, 0];
dir_vec(2,:) = [0.5, 0.5];
dir_vec(3,:) = [0,0.5];
dir_vec(4,:) = [-0.5, 0.5];
dir_vec(5,:) = [-0.5, 0];
dir_vec(6,:) = [-0.5, -0.5];
dir_vec(7,:) = [0, -0.5];
dir_vec(8,:) = [0.5, -0.5];

neighbor_dist(1) = 1;
neighbor_dist(2) = 2^.5;
neighbor_dist(3) = 1;
neighbor_dist(4) = 2^.5;
neighbor_dist(5) = 1;
neighbor_dist(6) = 2^.5;
neighbor_dist(7) = 1;
neighbor_dist(8) = 2^.5;
neighbor_dist = neighbor_dist.*cellsize;
rows = size(flow_dir,1); % number of rows (number of elements in a column)
cols = size(flow_dir,2); % number of columns


for el_flow_dir = 1:numel(flow_dir)
    [r, c] = ind2sub(size(flow_dir), el_flow_dir); %convert to row and column indices
    cur_slope = NaN;
%Force flow out along image boundaries(following 8 if/elseif statements)
    if (c == cols) && (r ~= 1) && (r ~= rows)
        flow_dir(el_flow_dir) = 1;
        flow_vector_u(r,c) = 0.5;
        flow_vector_v(r,c) = 0;
    elseif (c == cols) && (r == rows)
        flow_dir(el_flow_dir) = 2;
        flow_vector_u(r,c) = 0.5;
        flow_vector_v(r,c) = 0.5;
    elseif (r == rows) && (c ~= cols) && (c ~= 1)
        flow_dir(el_flow_dir) = 3;
        flow_vector_u(r,c) = 0;
        flow_vector_v(r,c) = 0.5;
    elseif (c == 1) && (r == rows)
        flow_dir(el_flow_dir) = 4;
        flow_vector_u(r,c) = -0.5;
        flow_vector_v(r,c) = 0.5;
    elseif (c == 1) && (r ~= rows) && (r ~= 1) 
        flow_dir(el_flow_dir) = 5;
        flow_vector_u(r,c) = -0.5;
        flow_vector_v(r,c) = 0;
    elseif (c == 1) && (r == 1)
        flow_dir(el_flow_dir) = 6;
        flow_vector_u(r,c) = -1;
        flow_vector_v(r,c) = -1;
    elseif (c ~= 1) && (c ~= cols) && (r == 1)
        flow_dir(el_flow_dir) = 7;
        flow_vector_u(r,c) = 0;
        flow_vector_v(r,c) = -0.5;
    elseif (c == cols) && (r == 1)
        flow_dir(el_flow_dir) = 8;
        flow_vector_u(r,c) = 0.5;
        flow_vector_v(r,c) = -0.5;
    else %identify neighboring cells
        neighbors(1) = (el_flow_dir+rows);
        neighbors(2) = (el_flow_dir+rows+1);
        neighbors(3) = (el_flow_dir+1);
        neighbors(4) = (el_flow_dir-rows+1);
        neighbors(5) = (el_flow_dir-rows);
        neighbors(6) = (el_flow_dir-rows-1);
        neighbors(7) = (el_flow_dir-1);
        neighbors(8) = (el_flow_dir+rows-1);

%If the computed slope is less than the cur_slope (minumum), set cur_slope as
%slope and assign current neighbor as the direction of flow.  If the
%minimum slope isn't negative (downhill), it's a pit (all neighbors are
%uphill).
        for n = 1 : 8
            slope = (dem(neighbors(n)) - dem(el_flow_dir))/neighbor_dist(n);
            if (isnan(cur_slope)) || (slope < cur_slope)
                %TODO print if slope == cur_slope and number of times
                %multiple negative slopes occurs
                cur_slope = slope;
                flow_dir(el_flow_dir) = n;
                flow_vector_u(r,c) = dir_vec(n,1);
                flow_vector_v(r,c) = dir_vec(n,2);
            end
        end
        if cur_slope >= 0 %flow may only occur downhill (negative values)
            flow_dir(el_flow_dir) = 0;
            flow_vector_u(r,c) = 0;
            flow_vector_v(r,c) = 0;
        end
    end
    flow_vector_x(r,c) = c;
    flow_vector_y(r,c) = r;
end

vec_field.X = flow_vector_x;
vec_field.Y = flow_vector_y;
vec_field.U = flow_vector_u;
vec_field.V = flow_vector_v;
end
