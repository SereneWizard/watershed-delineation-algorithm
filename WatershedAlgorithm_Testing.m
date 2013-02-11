%%Inputs
algorithm_tic = tic;
inputs_tic = tic;

cellsize = 3; % DEM cellsize in meters
rain_depth = 373; % in inches
rain_duration = 24; % in hours

drainage_off = 0; % Turn drainage on or off.  drainage_off = 1 means drainage IS off.

input_name = 'AaronFieldNew';

% Determine input format and create DEM.
[dem, drainage, flow_direction_key, flow_accumulation_key, pits_key, fill_dem_key, fill_flow_direction_key, fill_flow_accumulation_key, fill_pits_key, perform_error_checks, cellsize] = parseInputFormat(input_name, cellsize);
perform_error_checks = 0;
intensity = (rain_depth*0.0254)/rain_duration; % convert depth to meters, and calculate intensity in meters per hour

intputs_time = toc(inputs_tic)
%% Display DEM from data matrix of raw LiDAR Data
tic_idw = tic;
dem = idwInterpolation(dem);
idw_time = toc(tic_idw);
tic_idw_vis = tic;
disp(strcat(['Inverse distance weighting: ', num2str(idw_time),' seconds']))

figure(1);
%subplot(1,2,1);
imagesc(dem)
axis equal
xlabel('X (column)');
ylabel('Y (row)');
title ('Original DEM');
%saveas(2, strcat([file_name,' DEM.jpg']));
idw_vis_time = toc(tic_idw_vis)
%% Get Drainage Data
tic_drainage = tic;
if isempty(drainage)
    drainage = getDrainage(size(dem));
end
drainage_time = toc(tic_drainage);
disp(strcat(['Drainage: ', num2str(drainage_time),' seconds']))
tic_drain_vis= tic;
drainage = placeDrainageFeatures(drainage);

figure(2);
%subplot(1,2,1);
imagesc(drainage)
axis equal
xlabel('X (column)');
ylabel('Y (row)');
title ('Drainage');
%saveas(2, strcat([file_name,' Drainage.jpg']));
drain_vis_time = toc(tic_drain_vis)
%% Compute Flow Direction Matrix/Map
tic_flow_dir = tic;
if drainage_off == 0
    flow_direction = d8FlowDirectionDrainage(dem, drainage, intensity);
elseif drainage_off == 1
    flow_direction = d8FlowDirection(dem);
end
flow_dir_time = toc(tic_flow_dir);
disp(strcat(['Flow Direction: ', num2str(flow_dir_time), ' seconds']))

tic_flow_dir_vec = tic;
vector_field = flowDirectionVectorVisualization(flow_direction);
flow_dir_time = toc(tic_flow_dir_vec);
disp(strcat(['Flow Direction Vector Visualization: ', num2str(flow_dir_time), ' seconds']))

tic_flow_dir_vis = tic;
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

figure(3);
quiver(vector_field.X, vector_field.Y, vector_field.U, vector_field.V)
axis equal
set(gca,'YDir','reverse');
xlabel('X (column)')
ylabel('Y (row)')
title ('Original Flow Direction')
% %saveas(3, strcat(file_name,'FlowDirection.jpg'));
flow_dir_vis = toc(tic_flow_dir_vec)

%% Flow Accumulation
tic_flow_acc = tic;
flow_accumulation = flowAccumulation(flow_direction);

flow_acc_time = toc(tic_flow_acc);
disp(strcat(['Flow Accumulation: ', num2str(flow_acc_time), ' seconds']))

flow_acc_vis = tic;
if perform_error_checks
    error = numel(flow_accumulation) - sum(sum(flow_accumulation == flow_accumulation_key));
    strcat(['Number of cells different in flow_accumulation: ' num2str(error)])
    if error > 0
        flow_direction == flow_accumulation_key
    end
end

figure(5);
%subplot(1,2,2);
imagesc(flow_accumulation);
axis equal;
xlabel('X (column)');
ylabel('Y (row)');
title ('Flow Accumulation');
%saveas(3, strcat([file_name,' FlowAccummulation.jpg']));
flow_acc_vis = toc(flow_acc_vis)

%% Identify Pits, Compute Matrix/Map with Pit ID for each cell
pits_tic = tic;
[pits, pit_data, color_map] = Pits(dem, drainage, flow_direction, cellsize, intensity);
pits_time = toc(pits_tic);
disp(strcat(['Pits function: ', num2str(pits_time), ' seconds']))

pits_vis_tic = tic;
if perform_error_checks
    error = numel(pits) - sum(sum(pits == pits_key));
    strcat(['Number of cells different in pits: ' num2str(error)])
    if error > 0
        pits == pits_key
    end
end

figure(6);
%subplot(1,3,3);
imagesc(pits);
colormap(color_map);
axis equal;
xlabel('X (column)');
ylabel('Y (row)');
title ('Original Pits');
%saveas(5, strcat(file_name,'PitIDs.jpg'));
pits_vis_time = toc(pits_vis_tic)

%% Fill Pits
fill_tic = tic;
[fill_dem, puddle_dem, fill_flow_direction, fill_pits, sort_pit_data] = fillPits(dem, flow_direction, pits, pit_data, rain_duration, rain_depth, cellsize, color_map);
fill_time = toc(fill_tic);
disp(strcat(['Fill Function: ', num2str(fill_time), ' seconds']))

fill_vec_tic = tic;
%[fill_vec_field] = flowDirectionVectorVisualization(fill_flow_direction);
fill_vec_time = toc(fill_vec_tic);
disp(strcat(['Fill Flow Direction Vector Visualization: ', num2str(fill_vec_time), ' seconds']))

fill_vis_tic = tic;

if perform_error_checks
    error = numel(fill_dem) - sum(sum(fill_dem == fill_dem_key));
    strcat(['Number of cells different in fill_dem: ' num2str(error)])
    if error > 0
        fill_dem == fill_dem_key
    end
end

if perform_error_checks
    error = numel(fill_flow_direction) - sum(sum(fill_flow_direction == fill_flow_direction_key));
    strcat(['Number of cells different in fill_flow_direction: ' num2str(error)])
    if error > 0
        fill_flow_direction == fill_flow_direction_key
    end
end

if perform_error_checks
    error = numel(fill_pits) - sum(sum(fill_pits == fill_pits_key));
    strcat(['Number of cells different in fill_pits: ' num2str(error)])
    if error > 0
        fill_pits == fill_pits_key
    end
end

figure(7);
%subplot(1,2,1);
imagesc(fill_dem)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat(['Filled DEM: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
%saveas(6, strcat(file_name,'PitsFilledDEM',int2str(rain_dep),'in.jpg'))

figure(8);
%subplot(1,2,2);
imagesc(fill_flow_direction)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat(['Filled Flow Direction: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
%saveas(7, strcat(file_name,'PitsFilledFlowDir',int2str(rain_dep),'in.jpg'))

% figure(8);
% quiver(fill_vector_field.X, fill_vector_field.Y, fill_vector_field.U, fill_vector_field.V)
% axis equal
% set(gca,'YDir','reverse');
% xlabel('X (column)')
% ylabel('Y (row)')
% title (strcat(['Filled Flow Direction']))
% %saveas(7, strcat(file_name,'FlowDirection.jpg'));

% figure(9);
% imagesc(fill_flow_accum)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Flow Accumulation: Pits Filled by a ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
% %saveas(8, strcat(file_name,'PitsFilledFlowAccum',int2str(rain_dep),'in.jpg'))

figure(6);
imagesc(fill_pits)
colormap(color_map)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat(['Pits: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
%saveas(9, strcat(file_name,'PitsFilled.jpg'))

figure(11);
%subplot(1,2,1);
imagesc(puddle_dem)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat(['Filled DEM: ', int2str(rain_duration),'-Hour, ',int2str(rain_depth),'-Inch Rainfall Event']))
%saveas(6, strcat(file_name,'PitsFilledDEM',int2str(rain_dep),'in.jpg'))

% figure(10);
% imagesc(fill_dem - dem)
% colormap(map)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat(['Fill Amount by a ', int2str(rain_dur),'-Hour ',int2str(rain_dep/0.0254),'Inch Rainfall Event']))
% saveas(10, strcat(name,'PitsFilled.jpg'))
fill_vis_time = toc(fill_vis_tic)
algorithm_time = toc(algorithm_tic);
disp(strcat(['Complete algorithm run: ', num2str(algorithm_time./60), ' minutes']))