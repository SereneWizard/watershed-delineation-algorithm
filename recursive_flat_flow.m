function[flow_dir] = recursive_flat_flow(dem, flow_dir, element, checked_list)
neighbors = zeros(8,1);
rows = size(flow_dir,1); % number of rows (in linear indexing, adding/subtracting this amount is the same as moving right/left one column)
neighbors(1) = (element+rows);
neighbors(2) = (element+rows+1);
neighbors(3) = (element+1);
neighbors(4) = (element-rows+1);
neighbors(5) = (element-rows);
neighbors(6) = (element-rows-1);
neighbors(7) = (element-1);
neighbors(8) = (element+rows-1);

for n = 1:8
    if dem(element) == dem(neighbors(n))
        if flow_dir(neighbors(n)) ~= 0
            flow_dir(element) = n;
        elseif flow_dir(neighbors(n)) == 0 && any(checked_list ~= neighbors(n))
            checked_list = [checked_list,neighbors(n)];
            flow_dir = recursive_flat_flow(dem, flow_dir, neighbors(n), checked_list);
            flow_dir(element) = n
        end
    end
end
end