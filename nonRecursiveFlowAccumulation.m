function[flow_accumulation] = nonRecursiveFlowAccumulation(flow_direction)

flow_accumulation = nan(size(flow_direction));
indices = nan(size(flow_direction));

for cell = 1 : numel(flow_accumulation)
    if flow_direction(cell) < 0
        current_network_indices = [cell];
        indices(cell) = [cell];
        while ~isempty(current_network_indices)
            for idx = 1 : current_network_indices
                no_neighbor_check = 0;
                new_link = 0;
                for x = -1 : 1
                    for y = -1 : 1
                        neighbor_cell = sub2ind(size(flow_direction), r+y, c+x);
                        if flow_direction(neighbor_cell) == mod(cart2pol(x, y) - pi, 2*pi)
                            no_neighbor_check = 1;
                            for n = 1 : numel(current_network_indices)
                                indices(current_network_indices(n)) = [indices(current_network_indices(n)), neighbor_cell];
                            end
                            if new_link == 0
                                current_network_indices = [current_network_indices, neighbor_cell];
                            elseif new_link == 1
                                next_indices = [next_indices, neighbor_cell];
                            end
                            new_link = 1;
                        end
                    end
                end
                % If no neighbors were directed toward the current cell,
                % the current cell should be removed from the list_of_
                % indices_to_check because it is at a ridge.
                if no_neighbor_check == 0
                    current_network_indices(idx) = [];
                end
                
                % Traverse the list of indices and remove any indices that
                % have had their entire network searched already
                for i =  numel(current_network_indices) : -1 : 1
                    if sum(ismember(indices(current_network_indices(i)), current_network_indices)) == 0
                        current_network_indices(idx) = [];
                    end
                end
            end
        end
    end
end
