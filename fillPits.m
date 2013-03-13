function[fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rainfall_duration, rainfall_depth, cellsize, color_map)
% rename for clarity
SPILLOVER_TIME = 10;
PIT_ID = 12;
COLOR = 15;
n = 6;
fa = 5;

% Initialize the products that will change as pits are filled.
fill_dem = dem;
puddle_dem = dem;
fill_flow_direction = flow_direction;
fill_pits = pits;

% Chronologically order pits according to spillover time and initialize the
% current maximum pit ID number.
sort_pit_data = sortrows(pit_data, SPILLOVER_TIME);
current_max_ID = max(cell2mat(pit_data(:, PIT_ID)));

% Find potential maximum pit ID and the total potential mergers, and
% preallocate matrices accordingly.
potential_max_ID = 2 * current_max_ID - 1;
potential_merges = potential_max_ID - current_max_ID;
color_map = [color_map; nan(potential_merges, 3)];

% Begin counts of number of fills and simultaneous fills (if pits 1 & 2
% have same spillover time).
total_fill_count = 0;
simultaneous_fill_count = 0;
cur_merger = 1;
spillover_time_list = nan(potential_merges,1);

while sort_pit_data{1, SPILLOVER_TIME} < rainfall_duration
    spillover_time_list(cur_merger) = sort_pit_data{1, SPILLOVER_TIME};
    total_fill_count = total_fill_count + 1;
    % check if the first two pits overflow simultaneously
    if size(sort_pit_data,1) >= 2
        if (sort_pit_data{1,SPILLOVER_TIME} == sort_pit_data{2,SPILLOVER_TIME}) && sort_pit_data{1,SPILLOVER_TIME} ~= 0
            %disp(strcat('Pit #',int2str(sort_pit_data{1,PIT_ID}),' and Pit #', int2str(sort_pit_data{2,PIT_ID}), ' overflow simultaneously at time t=', num2str(sort_pit_data{2, SPILLOVER_TIME}), 'hours.'))
            simultaneous_fill_count = simultaneous_fill_count + 1;
        end
    end
    
    % call pit-merging/filling function
    pre_merger_max_ID = current_max_ID;        
    [fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data, current_max_ID] = mergePits(fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data, cellsize, current_max_ID);
        
    % Check to see if all pits have been merged.
    if isempty(sort_pit_data)
        break
    end
    
    if pre_merger_max_ID ~= current_max_ID
        % If the maximum ID changed (e.i. two non-0 pits merged), then
        % get the color of the new merged pit and add it to the end of
        % the colormap list. The color map is a matrix with each row
        % being an array [R,G,B] for each pit ID.  The pits count up
        % successively and never repeat. As the next count is reached,
        % another row is added to the colormap.
        max_ID_row_idx = find(cell2mat(sort_pit_data(:, PIT_ID)) == current_max_ID);
        color_map(current_max_ID+1, :) = cell2mat(sort_pit_data(max_ID_row_idx, COLOR)); % +1 to account for Pit ID 0 which is not in the sort_pit_data list
    end
    
%     if sort_pit_data{1,SPILLOVER_TIME} > 0.02
%         if n == 4
%             n = 6;
%             fa = 5;
%         elseif n == 6
%             n = 4;
%             fa = 13;
%         end
%         
%         fill_flow_accumulation = flowAccumulation(fill_flow_direction);
%         
%         figure(fa);
%         imagesc(fill_flow_accumulation);
%         axis equal;
%         xlabel('X (column)');
%         ylabel('Y (row)');
%         title(strcat(['Flow Accumulation: ', int2str(rainfall_duration),'-Hour, ',int2str(rainfall_depth),'-Inch Rainfall Event']))
%         
%         figure(n);
%         imagesc(fill_pits);
%         colormap(color_map(1:1+max(max(fill_pits)),:));
%         axis equal;
%         xlabel('X (column)');
%         ylabel('Y (row)');
%         title(strcat(['Pits: ', int2str(rainfall_duration),'-Hour, ',int2str(rainfall_depth),'-Inch Rainfall Event']))
%     end

cur_merger = cur_merger + 1;
end

figure(12);
hist(spillover_time_list,50);

%zero_pit_count

disp(strcat([int2str(total_fill_count), ' total pit fills']))
end