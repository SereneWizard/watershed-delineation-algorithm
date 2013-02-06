function [flow_accumulation] = flowAccumulation(flow_direction)
% This function is a wrapper function which finds the flow accumulation of
% each cell in the matrix. A recursive function is called to find the flow
% accumulation, and cells traversed during recursion are filled in as they
% go.

% Preallocate flow accumulation matrix. 
flow_accumulation = nan(size(flow_direction));

numrows = size(flow_direction, 1); % number of rows
numcols = size(flow_direction, 2); % number of columns

for cell = 1: numel(flow_direction)
    [r, c] = ind2sub(size(flow_direction), cell); 
    if r == numrows || r == 1 || c == numcols || c == 1
        flow_accumulation(r,c) = NaN;
        continue; % skip neighbors outside the matrix range
    end
    if isnan(flow_accumulation(cell))
        flow_accumulation = recursiveFlowAccumulation(flow_accumulation, flow_direction, cell);
    end
end
end