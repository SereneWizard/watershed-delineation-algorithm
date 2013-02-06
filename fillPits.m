function[fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rainfall_duration, rainfall_depth, intensity, cellsize, color_map)
% rename for clarity
SPILLOVER_TIME = 10;
PIT_ID = 12;
COLOR = 15;

% Initialize the products that will change as pits are filled.
fill_dem = dem;
puddle_dem = dem;
fill_flow_dir = flow_direction;
fill_pits = pits;

% Chronologically order pits according to spillover time and initialize the
% current maximum pit ID number.
pit_data = sortrows(pit_data, SPILLOVER_TIME);
current_max_ID = max(cell2mat(pit_data(:, PIT_ID)));

% Find potential maximum pit ID and the total potential mergers, and
% preallocate matrices accordingly.
potential_max_ID = 2 * current_max_ID - 1;
potential_merges = potential_max_ID - current_max_ID;
sort_pit_data = pit_data;
color_map = [color_map; nan(potential_merges, 3)];

fill_dem_times = nan(potential_merges,1); % PROFILING 
fill_pits_times = nan(potential_merges,1); % PROFILING 
border_times = nan(potential_merges,1); % PROFILING 
find_spillover_id_times = nan(potential_merges,1); % PROFILING 
all_indices_times = nan(potential_merges, 1); % PROFILING
color_map_times = nan(potential_merges,1); % PROFILING 
merge_times = nan(potential_merges,2); % PROFILING 
merge_function_times = nan(potential_merges,1); % PROFILING 
% Begin counts of number of fills and simultaneous fills (if pits 1 & 2
% have same spillover time).
total_fill_count = 0;
simultaneous_fill_count = 0; 

% initialize time for animation of pit mergers
% time = 0;


cur_merger = 1;
color_map_idx = 1;
while sort_pit_data{1, SPILLOVER_TIME} < rainfall_duration
    total_fill_count = total_fill_count + 1;
    % check if the first two pits overflow simultaneously
    if size(sort_pit_data,1) >= 2
        if (sort_pit_data{1,SPILLOVER_TIME} == sort_pit_data{2,SPILLOVER_TIME}) && sort_pit_data{1,SPILLOVER_TIME} ~= 0
            %disp(strcat('Pit #',int2str(sort_pit_data{1,PIT_ID}),' and Pit #', int2str(sort_pit_data{2,PIT_ID}), ' overflow simultaneously at time t=', num2str(sort_pit_data{2, SPILLOVER_TIME}), 'hours.'))
            simultaneous_fill_count = simultaneous_fill_count + 1;
        end
    end
    % call pit-merging/filling function
    merge_function_tic = tic;
    pre_merger_max_ID = current_max_ID;
    removed_first_pit_color = sort_pit_data{1, COLOR};
    [fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data, current_max_ID, merge_time, fill_dem_time, fill_pits_time, border_time, find_spillover_id_time, all_indices_time] = mergePits(fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data, intensity, cellsize, current_max_ID);   
    merge_function_times(cur_merger) = toc(merge_function_tic);
    
    merge_times(cur_merger, :) = merge_time;
    fill_dem_times(cur_merger) = fill_dem_time;
    fill_pits_times(cur_merger) = fill_pits_time;
    border_times(cur_merger) = border_time;
    find_spillover_id_times(cur_merger) = find_spillover_id_time;
    all_indices_times(cur_merger) = all_indices_time;
    
    % Check to see if all pits have been merged.
    if isempty(sort_pit_data)
        break
    end
    
    % plot pits based on given time step 
    %delta_t = sort_pit_data(1,10) - time;
    %if delta_t > 0.5
        %time = sort_pit_data(1,10);
        color_map_tic = tic; % PROFILING
        if pre_merger_max_ID ~= current_max_ID
            % If the maximum ID changed (e.i. two non-0 pits merged), then
            % get the color of the new merged pit and add it to the end of
            % the colormap list. The color map is matrix with each row
            % being an array [R,G,B] for each pit ID.  The pits count up
            % sequentially and never repeat. As the next count is reached,
            % another row is added to the colormap.
            max_ID_row_idx = find(cell2mat(sort_pit_data(:, PIT_ID)) == current_max_ID);
            color_map(current_max_ID, :) = cell2mat(sort_pit_data(max_ID_row_idx, COLOR));
            color_map_idx = color_map_idx + 1;
        elseif pre_merger_max_ID ~= max(cell2mat(sort_pit_data(:,PIT_ID)))
            % Otherwise, the first pit merged with an ID 0 pit. If that
            % first pit was the current maximum ID #, that color should be
            % removed from the colormap list.
            removed_first_pit_color_idx = find(ismember(color_map, removed_first_pit_color, 'rows'));
            color_map(removed_first_pit_color_idx, :) = [];
        end
        figure(6);
        imagesc(fill_pits);
        colormap(color_map(~any(isnan(color_map),2),:));
        axis equal;
        xlabel('X (column)');
        ylabel('Y (row)');
        title(strcat(['Pits     ', int2str(rainfall_duration),'-Hour ',int2str(rainfall_depth),'Inch Rainfall Event']))
        color_map_times(cur_merger) = toc(color_map_tic); % PROFILING 
    %end
%     Stop and wait for key press or mouse click. 
%     w = waitforbuttonpress;
%     if w == 0
%         continue;
%     else
%         continue;
%     end
    % plot pits based on given time step
%     if sort_pit_data(1, 10) > time
%         time = time + 1; % set time for next frame to be plotted
%         figure(6);
%         imagesc(fill_pits)
%         colormap(color_map)
%         axis equal
%         xlabel('X (column)')
%         ylabel('Y (row)')
%         title(strcat('Pits: Pits Remaining by a ', int2str(rain_dur),'-Hour ',int2str(rain_dep/0.0254),'Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
%     end
cur_merger = cur_merger + 1;
end

disp(strcat(['Average time of mergePits function: ', num2str(nanmean(merge_function_times)), ' seconds']))
disp(strcat(['Average time to adjust fill_dem: ', num2str(nanmean(fill_dem_times)), ' seconds']))
disp(strcat(['Average time to adjust fill_pits: ', num2str(nanmean(fill_pits_times)), ' seconds']))
disp(strcat(['Average time to merge two non-zero pits: ', num2str(nanmean(merge_times(:,2))), ' seconds']))
disp(strcat(['Average time to adjust consequent spillover IDs: ', num2str(nanmean(find_spillover_id_times)), ' seconds']))
disp(strcat(['Average time to combine indices: ', num2str(nanmean(all_indices_times)), ' seconds']))
disp(strcat(['Average time to find border data: ', num2str(nanmean(border_times)), ' seconds']))

areas_list = unique(merge_times(:,1));
times_list = nan(mode(merge_times(:,1)),length(areas_list));

for i = 1:length(merge_times(:,1))
    col_idx = find(areas_list==merge_times(i,1));
    row_idx = find(isnan(times_list(:,col_idx)),1,'first');
    times_list(row_idx, col_idx) = merge_times(i,2);
end

figure(12);
boxplot(times_list)
%plot(merge_times(:,1), merge_times(:,2));
xlabel('Area of Merged Pit (cells)');
ylabel('Computation Time (s)');
title ('Area of Merged Pit vs Computation Time');

disp(strcat([int2str(total_fill_count), ' total pit fills']))
%disp(strcat(int2str(simultaneous_fill_count), ' total times the first two pits overflow simultaneously (excluding t=0)'))
end