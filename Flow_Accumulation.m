function [flow_accum] = Flow_Accumulation(flow_dir)
flow_accum = zeros(size(flow_dir));

for element = 1:numel(flow_accum)
%The recursive process fills in the flow_accum matrix. The following line
%checks that the value hasn't already been filled in.
    if flow_accum(element) == 0
        [r, c] = ind2sub(size(flow_accum), element); %convert to row and column indices
        [flow_accum, flow_accum(r, c)] = flow_accum_recurs(flow_dir, r, c, flow_accum);
    end
end
flow_accum = flow_accum + 1; %cells should count themselves to avoid dividing by 0 in later steps for cells that are 1-cell pits
end




% FOR WATERSHED ALGORITHM MAIN FUNCTION CALLS
% %% Compute Flow Accumulation Matrix/Map
% flow_accum = Flow_Accumulation(flow_direction); % only output is flow_accum matrix and it is global
% disp('flow_accum')
% flow_accum == flow_accum_key
% 
% figure(4);
% imagesc(flow_accum)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title (strcat('Flow Accumulation (',int2str(cellsize),'m Spacing)'))
% %saveas(4, strcat(test_name,'FlowAccumulation.jpg'));

%% Flow Accumulation
% flow_accum = zeros(size(flow_direction));
% for element = 1 : numel(flow_direction)
%     indices_draining_to_desired_cell = [];
%     flow_accum(element) = numel(findCellsDrainingToPoint(flow_direction, element, indices_draining_to_desired_cell));
% end

% error = numel(flow_accum) - sum(sum(flow_accum == flow_accum_key));
% strcat(['Number of cells different in flow_accum: ' num2str(error)])
% if error > 0
%     flow_accum == flow_accum_key
% end

% figure(4);
% imagesc(flow_accum)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title (strcat('Flow Accumulation (',int2str(cellsize),'m Spacing)'))