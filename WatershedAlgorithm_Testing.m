%Inputs
cellsize = 3; % DEM cellsize in meters
rain_depth = 3000; % in inches
rain_duration = 24; % in hours

intensity = (rain_depth*0.0254)/rain_duration; % convert depth to meters, and calculate intensity in meters per hour

drainage_off = 0; % Turn drainage on or off.  drainage_off = 1 means drainage IS off.

input_name = 'AaronFieldNew';

%Determine input format and create DEM.
[georef_info, dem, drainage, flow_direction_key, flow_accumulation_key, pits_key, fill_dem_key, fill_flow_direction_key, fill_flow_accumulation_key, fill_pits_key, perform_error_checks, cellsize] = parseInputFormat(input_name, cellsize);

%% Display DEM from data matrix of raw LiDAR Data
dem = idwInterpolation(dem);

geotiffwrite('testtiff.tif', dem, georef_info,'CoordRefSysCode', 26916);
figure(1);
%subplot(1,2,1);
imagesc(dem)
axis equal
xlabel('X (column)');
ylabel('Y (row)');
title ('Original DEM');

% figure(2);
% %subplot(1,2,1);
% geotiffimage = geotiffread('testtiff.tif');
% mapshow('testtiff.tif')
% axis equal
% xlabel('');
% ylabel('');
% title ('Original DEM in UTM Z16N Coordinates');

%saveas(2, strcat([file_name,' DEM.jpg']));
%% Get Drainage Data
if isempty(drainage)
    drainage = getDrainage(size(dem));
end
drainage = placeDrainageFeatures(drainage);

figure(2);
%subplot(1,2,1);
imagesc(drainage)
axis equal
xlabel('X (column)');
ylabel('Y (row)');
title ('Drainage');
%saveas(2, strcat([file_name,' Drainage.jpg']));

%% Compute Flow Direction Matrix/Map
if drainage_off == 0
    %flow_direction = d8FlowDirectionDrainage(dem, drainage, intensity);
    flow_direction = ArcGISFlowDirection(dem);
elseif drainage_off == 1
    flow_direction = d8FlowDirection(dem);
end

geotiffwrite('testtifflow.tif', flow_direction, georef_info,'CoordRefSysCode', 26916);
%vector_field = flowDirectionVectorVisualization(flow_direction);

if perform_error_checks
    error = numel(flow_direction) - sum(sum(flow_direction == flow_direction_key));
    strcat(['Number of cells different in flow_direction: ' num2str(error)])
    if error > 0
        flow_direction == flow_direction_key
    end
end

figure(3);
%subplot(1,2,2);
imagesc(flow_direction);
axis equal;
xlabel('X (column)');
ylabel('Y (row)');
title ('Original Flow Direction');
%saveas(3, strcat([file_name,' FlowDirection.jpg']));

% figure(3);
% quiver(vector_field.X, vector_field.Y, vector_field.U, vector_field.V)
% axis equal
% set(gca,'YDir','reverse');
% xlabel('X (column)')
% ylabel('Y (row)')
% title ('Original Flow Direction')
% %saveas(3, strcat(file_name,'FlowDirection.jpg'));

% %% Flow Accumulation
% flow_accumulation = flowAccumulation(flow_direction);
% 
% if perform_error_checks
%     error = numel(flow_accumulation) - sum(sum(flow_accumulation == flow_accumulation_key));
%     strcat(['Number of cells different in flow_accumulation: ' num2str(error)])
%     if error > 0
%         flow_direction == flow_accumulation_key
%     end
% end
% 
% figure(5);
% %subplot(1,2,2);
% imagesc(flow_accumulation);
% axis equal;
% xlabel('X (column)');
% ylabel('Y (row)');
% title ('Flow Accumulation');
% %saveas(3, strcat([file_name,' FlowAccummulation.jpg']));
% 
% %% Identify Pits, Compute Matrix/Map with Pit ID for each cell
% [pits, pit_data, color_map] = Pits(dem, drainage, flow_direction, cellsize, intensity);
% 
% if perform_error_checks
%     error = numel(pits) - sum(sum(pits == pits_key));
%     strcat(['Number of cells different in pits: ' num2str(error)])
%     if error > 0
%         pits == pits_key
%     end
% end
% 
% geotiffwrite('test_pits_tiff.tif', pits, georef_info,'CoordRefSysCode', 26916);
% figure(6);
% %subplot(1,3,3);
% imagesc(pits);
% colormap(color_map);
% axis equal;
% xlabel('X (column)');
% ylabel('Y (row)');
% title ('Original Pits');
% %saveas(5, strcat(file_name,'PitIDs.jpg'));
% 
% %% Fill Pits
% [fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rain_duration, rain_depth, cellsize, color_map);
% 
% [fill_vector_field] = flowDirectionVectorVisualization(fill_flow_direction);
% 
% if perform_error_checks
%     error = numel(fill_dem) - sum(sum(fill_dem == fill_dem_key));
%     strcat(['Number of cells different in fill_dem: ' num2str(error)])
%     if error > 0
%         fill_dem == fill_dem_key
%     end
% end
% 
% if perform_error_checks
%     error = numel(fill_flow_direction) - sum(sum(fill_flow_direction == fill_flow_direction_key));
%     strcat(['Number of cells different in fill_flow_direction: ' num2str(error)])
%     if error > 0
%         fill_flow_direction == fill_flow_direction_key
%     end
% end
% 
% if perform_error_checks
%     error = numel(fill_pits) - sum(sum(fill_pits == fill_pits_key));
%     strcat(['Number of cells different in fill_pits: ' num2str(error)])
%     if error > 0
%         fill_pits == fill_pits_key
%     end
% end
% 
% figure(7);
% %subplot(1,2,1);
% imagesc(fill_dem)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Filled DEM: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% %saveas(6, strcat(file_name,'PitsFilledDEM',int2str(rain_dep),'in.jpg'))
% 
% figure(8);
% %subplot(1,2,2);
% imagesc(fill_flow_direction)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Filled Flow Direction: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% %saveas(7, strcat(file_name,'PitsFilledFlowDir',int2str(rain_dep),'in.jpg'))
% 
% figure(8);
% quiver(fill_vector_field.X, fill_vector_field.Y, fill_vector_field.U, fill_vector_field.V)
% axis equal
% set(gca,'YDir','reverse');
% xlabel('X (column)')
% ylabel('Y (row)')
% title (strcat('Filled Flow Direction'))
% %saveas(7, strcat(file_name,'FlowDirection.jpg'));
% 
% % figure(9);
% % imagesc(fill_flow_accum)
% % axis equal
% % xlabel('X (column)')
% % ylabel('Y (row)')
% % title(strcat(['Flow Accumulation: Pits Filled by a ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% % %saveas(8, strcat(file_name,'PitsFilledFlowAccum',int2str(rain_dep),'in.jpg'))
% 
% figure(6);
% imagesc(fill_pits)
% colormap(color_map)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Pits: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% %saveas(9, strcat(file_name,'PitsFilled.jpg'))
% 
% figure(11);
% %subplot(1,2,1);
% imagesc(puddle_dem)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Filled DEM: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% %saveas(6, strcat(file_name,'PitsFilledDEM',int2str(rain_dep),'in.jpg'))
% 
% % figure(10);
% % imagesc(fill_dem - dem)
% % colormap(map)
% % axis equal
% % xlabel('X (column)')
% % ylabel('Y (row)')
% % title(strcat(['Fill Amount by a ', int2str(rain_dur),'-Hour ',int2str(rain_dep/0.0254),'Inch Rainfall Event']))
% % saveas(10, strcat(name,'PitsFilled.jpg'))