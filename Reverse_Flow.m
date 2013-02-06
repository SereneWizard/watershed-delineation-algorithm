function [flow_dir] = Reverse_Flow(flow_dir, element, direction)
cur_el_dir = flow_dir(element);
col = size(flow_dir,1);
% reverse the direction handed down (uphill cell pointing toward current
% cell) and apply that direction to current cell
if direction == 1
    flow_dir(element) = 5;
elseif direction == 2
    flow_dir(element) = 6;
elseif direction == 3
    flow_dir(element) = 7;
elseif direction == 4
    flow_dir(element) = 8;
elseif direction == 5
    flow_dir(element) = 1;
elseif direction == 6
    flow_dir(element) = 2;
elseif direction == 7
    flow_dir(element) = 3;
elseif direction == 8
    flow_dir(element) = 4;
else
end

% determine direction to call recursive function
if cur_el_dir == 5
    next_element = element - col;
elseif cur_el_dir == 6
    next_element = element - col - 1;
elseif cur_el_dir == 7
    next_element = element - 1;
elseif cur_el_dir == 8
    next_element = element + col - 1;
elseif cur_el_dir == 1
    next_element = element + col;
elseif cur_el_dir == 2
    next_element = element + col + 1;
elseif cur_el_dir == 3
    next_element = element + 1;
elseif cur_el_dir == 4
    next_element = element - col + 1;
else
end

% If the current cell is a pit, the recursion is complete
if cur_el_dir ~= 0
    [flow_dir] = Reverse_Flow(flow_dir, next_element,cur_el_dir);
end