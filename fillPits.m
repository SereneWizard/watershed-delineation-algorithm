function[fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rainfall_duration, rainfall_depth, cellsize, color_map)
set_vars_tic = tic;
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
sort_pit_data = sortrows(pit_data, SPILLOVER_TIME);
current_max_ID = max(cell2mat(pit_data(:, PIT_ID)));

% Find potential maximum pit ID and the total potential mergers, and
% preallocate matrices accordingly.
potential_max_ID = 2 * current_max_ID - 1;
potential_merges = potential_max_ID - current_max_ID;
color_map = [color_map; nan(potential_merges, 3)];
fill_begin_time = nan(potential_merges,1); % PROFILING 
filling_vis_time = nan(potential_merges,1); % PROFILING 

% fill_dem_times = nan(potential_merges,1); % PROFILING 
% fill_pits_times = nan(potential_merges,1); % PROFILING 
% border_times = nan(potential_merges,1); % PROFILING 
% find_spillover_id_times = nan(potential_merges,1); % PROFILING 
% all_indices_times = nan(potential_merges, 1); % PROFILING
% merge_times = nan(potential_merges,2); % PROFILING 
merge_function_times = nan(potential_merges,1); % PROFILING

% Begin counts of number of fills and simultaneous fills (if pits 1 & 2
% have same spillover time).
total_fill_count = 0;
simultaneous_fill_count = 0; 

non_zeros_merge_time.id_case = [];
non_zeros_merge_time.prep_two_pits = [];
non_zeros_merge_time.fill_dem = [];
non_zeros_merge_time.all_indices = [];
non_zeros_merge_time.pits = [];
non_zeros_merge_time.border = [];
non_zeros_merge_time.calculations = [];
non_zeros_merge_time.cleanup = [];
non_zeros_merge_time.totals = [];

zero_merge_time.id_case = [];
zero_merge_time.fill_dem = [];
zero_merge_time.pits = [];
zero_merge_time.cleanup = [];
zero_merge_time.totals = [];

% initialize time for animation of pit mergers
% time = 0;

cur_merger = 1;
color_map_idx = 1;
set_vars_time = toc(set_vars_tic);

looping_tic = tic;
while sort_pit_data{1, SPILLOVER_TIME} < rainfall_duration
    fill_begin_tic = tic;
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
    removed_first_pit_color = sort_pit_data{1, COLOR};
    fill_begin_time(cur_merger) = toc(fill_begin_tic); % PROFILING
    merge_function_tic = tic; % PROFILING
    [fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data, current_max_ID, non_zeros_merge_time, zero_merge_time] = mergePits(fill_dem, puddle_dem, fill_flow_dir, fill_pits, sort_pit_data, cellsize, current_max_ID, non_zeros_merge_time, zero_merge_time);
    merge_function_times(cur_merger) = toc(merge_function_tic); % PROFILING
%     merge_times(cur_merger, :) = merge_time;
%     fill_dem_times(cur_merger) = fill_dem_time;
%     fill_pits_times(cur_merger) = fill_pits_time;
%     border_times(cur_merger) = border_time;
%     find_spillover_id_times(cur_merger) = find_spillover_id_time;
%     all_indices_times(cur_merger) = all_indices_time;
    filling_vis = tic; % PROFILING
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
        color_map(current_max_ID, :) = cell2mat(sort_pit_data(max_ID_row_idx, COLOR));
        color_map_idx = color_map_idx + 1;
    end
    
    figure(6);
    imagesc(fill_pits);
    colormap(color_map(1:1+max(max(fill_pits)),:));
    axis equal;
    xlabel('X (column)');
    ylabel('Y (row)');
    title(strcat(['Pits: ', int2str(rainfall_duration),'-Hour, ',int2str(rainfall_depth),'-Inch Rainfall Event']))

filling_vis_time(cur_merger) = toc(filling_vis); % PROFILING
cur_merger = cur_merger + 1;
end
looping_time = toc(looping_tic); % PROFILING

disp(strcat(['Non-Zero Pits Merger - Average time to identify case: ', num2str(nanmean(non_zeros_merge_time.id_case)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to prep the merging pits: ', num2str(nanmean(non_zeros_merge_time.prep_two_pits)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to adjust fill_dem: ', num2str(nanmean(non_zeros_merge_time.fill_dem)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to adjust fill_pits: ', num2str(nanmean(non_zeros_merge_time.pits)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time combine pit indices: ', num2str(nanmean(non_zeros_merge_time.all_indices)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to find border info: ', num2str(nanmean(non_zeros_merge_time.border)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to perform final calculations(volume,etc): ', num2str(nanmean(non_zeros_merge_time.calculations)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to cleanup and finish the merger: ', num2str(nanmean(non_zeros_merge_time.cleanup)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Average time to perform full merger: ', num2str(nanmean(non_zeros_merge_time.totals(:,2))), ' seconds']))

disp(strcat(['Non-Zero Pits Merger - Total time to identify case: ', num2str(nansum(non_zeros_merge_time.id_case)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to prep the merging pits: ', num2str(nansum(non_zeros_merge_time.prep_two_pits)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to adjust fill_dem: ', num2str(nansum(non_zeros_merge_time.fill_dem)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to adjust fill_pits: ', num2str(nansum(non_zeros_merge_time.pits)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time combine pit indices: ', num2str(nansum(non_zeros_merge_time.all_indices)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to find border info: ', num2str(nansum(non_zeros_merge_time.border)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to perform final calculations(volume,etc): ', num2str(nansum(non_zeros_merge_time.calculations)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to cleanup and finish the merger: ', num2str(nansum(non_zeros_merge_time.cleanup)), ' seconds']))
disp(strcat(['Non-Zero Pits Merger - Total time to perform full merger: ', num2str(nansum(non_zeros_merge_time.totals(:,2))), ' seconds']))

disp(strcat(['ID Zero Merger - Average time to identify case: ', num2str(nanmean(zero_merge_time.id_case)), ' seconds']))
disp(strcat(['ID Zero Merger - Average time to adjust fill_dem: ', num2str(nanmean(zero_merge_time.fill_dem)), ' seconds']))
disp(strcat(['ID Zero Merger - Average time to adjust fill_pits: ', num2str(nanmean(zero_merge_time.pits)), ' seconds']))
disp(strcat(['ID Zero Merger - Average time to cleanup and finish the merger: ', num2str(nanmean(zero_merge_time.cleanup)), ' seconds']))
disp(strcat(['ID Zero Merger - Average time to perform full merger: ', num2str(nanmean(zero_merge_time.totals)), ' seconds']))

disp(strcat(['ID Zero Merger - Total time to identify case: ', num2str(nansum(zero_merge_time.id_case)), ' seconds']))
disp(strcat(['ID Zero Merger - Total time to adjust fill_dem: ', num2str(nansum(zero_merge_time.fill_dem)), ' seconds']))
disp(strcat(['ID Zero Merger - Total time to adjust fill_pits: ', num2str(nansum(zero_merge_time.pits)), ' seconds']))
disp(strcat(['ID Zero Merger - Total time to cleanup and finish the merger: ', num2str(nansum(zero_merge_time.cleanup)), ' seconds']))
disp(strcat(['ID Zero Merger - Total time to perform full merger: ', num2str(nansum(zero_merge_time.totals)), ' seconds']))

disp(strcat(['Average time to setup variables: ', num2str(set_vars_time), ' seconds']))
disp(strcat(['Average time fill function loop beginning: ', num2str(nanmean(fill_begin_time)), ' seconds']))
disp(strcat(['Average time of mergePits function: ', num2str(nanmean(merge_function_times)), ' seconds']))
disp(strcat(['Average time to perform colormap/visuals: ', num2str(nanmean(filling_vis_time)), ' seconds']))

disp(strcat(['Total time to setup variables: ', num2str(set_vars_time), ' seconds']))
disp(strcat(['Total time of fill function loop beginning: ', num2str(nansum(fill_begin_time)), ' seconds']))
disp(strcat(['Total time of mergePits function: ', num2str(nansum(merge_function_times)), ' seconds']))
disp(strcat(['Total time of colormap/visuals: ', num2str(nansum(filling_vis_time)), ' seconds']))
disp(strcat(['Time in while loop: ', num2str(looping_time), ' seconds']))

boxplot_tic = tic;

areas_list = unique(non_zeros_merge_time.totals(:,1));
times_list = nan(mode(non_zeros_merge_time.totals(:,1)),length(areas_list));

for i = 1:length(non_zeros_merge_time.totals(:,1))
    col_idx = find(areas_list==non_zeros_merge_time.totals(i,1));
    row_idx = find(isnan(times_list(:,col_idx)),1,'first');
    times_list(row_idx, col_idx) = non_zeros_merge_time.totals(i,2);
end

figure(12);
boxplot(times_list)
xlabel('Area of Merged Pit (cells)');
ylabel('Computation Time (s)');
title ('Area of Merged Pit vs Computation Time');
boxplot_time = toc(boxplot_tic);
disp(strcat(['Time to perform boxplot: ', num2str(nansum(boxplot_time)), ' seconds']))
disp(strcat([int2str(total_fill_count), ' total pit fills']))
%disp(strcat(int2str(simultaneous_fill_count), ' total times the first two pits overflow simultaneously (excluding t=0)'))
end