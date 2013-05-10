function[fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rainfall_duration, rainfall_depth, cellsize, color_map, georef_info, input_name)
% rename for clarity
SPILLOVER_TIME = 10;
PIT_ID = 12;
COLOR = 15;

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
    
    %The following code handles plotting and generating a random color for
    %each pit. It is not crucial to the algorithm's operation.
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
%     
    if sort_pit_data{1,SPILLOVER_TIME} > 0.005
        % Create .latlng text file indicated the latitude and longitude
        % bounds of the given field.
        [lower_left_lat, lower_left_long] = utm2deg(georef_info.XLimWorld(1), georef_info.YLimWorld(1), '16 N');
        [upper_right_lat, upper_right_long] = utm2deg(georef_info.XLimWorld(2), georef_info.YLimWorld(2), '16 N');
        fid = fopen('field.latlng', 'wt');
        fprintf(fid, strcat(num2str(lower_left_lat), '\n', num2str(lower_left_long),'\n', num2str(upper_right_lat), '\n', num2str(upper_right_long), '\n', num2str(min(min(fill_dem))), '\n', num2str(max(max(fill_dem)))));
        fclose(fid);
        
        % Convert the watershed ID map to an image where each ID has a
        % unique color. The watershed ID's are multiplied by 50 to create
        % some separation between ID's such that the difference in colors
        % is visible in the resultant images. Also create a grayscale DEM
        % image.
        rgb_fill_pits = fill_pits*50; 
        r = bitshift(rgb_fill_pits, -16);
        g = bitand(bitshift(rgb_fill_pits, -8), 255);
        b = bitand(rgb_fill_pits, 255);
        rgb_fill_pits = uint8(zeros(size(fill_pits,1),size(fill_pits,2), 3));
        rgb_fill_pits(:,:,1) = r;
        rgb_fill_pits(:,:,2) = g;
        rgb_fill_pits(:,:,3) = b;
        imwrite(rgb_fill_pits, 'field_catchments.png', 'png');
        imwrite(mat2gray(fill_dem), 'field.png', 'png');  
        
        figure(13);
        imagesc(fill_pits);
        colormap(color_map(1:1+max(max(fill_pits)),:));
        axis equal;
        %set(gca, 'position', [0 0 1 1], 'units', 'normalized')
        xlabel('X (column)');
        ylabel('Y (row)');
        title(strcat(['Pits: ', int2str(rainfall_duration),'-Hour, ',int2str(rainfall_depth),'-Inch Rainfall Event t=', num2str(sort_pit_data{1, SPILLOVER_TIME})]));
%        saveas(13, strcat(input_name,'PitsFilled.jpg'))
    end
    cur_merger = cur_merger + 1;
end

% Display histogram of # pits vs. time to fill that pit
figure(12);
hist(spillover_time_list,50);

disp(strcat([int2str(total_fill_count), ' total pit fills']))
end