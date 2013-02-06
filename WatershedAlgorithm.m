x%%Inputs
cellsize = 3;
rain_dep = 42200; % in
rain_dur = 24; % hours
intensity = (rain_dep*0.0254)/rain_dur; % convert depth to meters, and calculate intensity in meters per hour

%%Load LiDAR 1.5m DEM
% dem = geotiffread('ault_field.tif');
% for el = 1 : numel(dem)
%     if dem(el) <= 0
%         dem(el) = NaN;
%     end
% end

%% Load Data
test_name = 'example1'; %BuckmasterRossvilleData, lidardata, pit_example_1
%image_example = imread(name,'bmp'); 
%load(name, 'data');
%clear image_example
%examples = csvread('Pit Scenarios.csv');
%dem = examples(1:11,2:12);
%dem = examples(13:23,2:12);
%dem = examples(25:35,2:12);
%dem = examples(37:47,2:12);
%dem = examples(49:59,2:12);
%dem = examples(61:71,2:12);
%example_7 = double(image_example(:,:,1));
numrows = size(dem,1);
numcols = size(dem,2);

%% Create DEM from data matrix of raw LiDAR Data
%[dem,numrows,numcols] = Make_DEM(data,cellsize);
dem = IDW_Interpolation(dem,numrows,numcols);

figure(2);
imagesc(dem)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title (strcat('Elevation DEM (',int2str(cellsize),'m Spacing)'))
%saveas(2, strcat(test_name,'DEM.jpg'));

%% Compute Flow Direction Matrix/Map
[flow_dir,vector_field] = Flow_Direction(dem, cellsize);

figure(3);
imagesc(flow_dir)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title (strcat('Flow Direction (',int2str(cellsize),'m Spacing)'))
%saveas(3, strcat(test_name,'FlowDirection.jpg'));

figure(3);
quiver(vector_field.X, vector_field.Y, vector_field.U, vector_field.V)
axis equal
set(gca,'YDir','reverse');
xlabel('X (column)')
ylabel('Y (row)')
title (strcat('Flow Direction (',int2str(cellsize),'m Spacing)'))
%saveas(3, strcat(test_name,'FlowDirection.jpg'));

%% Compute Flow Accumulation Matrix/Map
flow_accum = Flow_Accumulation(flow_dir, numrows, numcols); % only output is flow_accum matrix and it is global

figure(4);
imagesc(flow_accum)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title (strcat('Flow Accumulation (',int2str(cellsize),'m Spacing)'))
%saveas(4, strcat(test_name,'FlowAccumulation.jpg'));

% flow_accum1 = Flow_Accumulation_Alt(flow_dir, numrows, numcols); % only output is flow_accum matrix and it is global
% 
% figure(5);
% image(flow_accum1)
% colormap('default')
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title (strcat('Flow Accumulation (',int2str(cellsize),'m Spacing)'))
% saveas(5, strcat(name,'FlowAccumulation1.jpg'));
%% Identify Pits, Compute Matrix/Map with Pit ID for each cell
[pits, pit_data] = Pits(dem, flow_dir, flow_accum, cellsize, intensity, numrows, numcols);

map = 0.3 + (rand(length(pit_data),3).*(1-.3));
map(1,:) = [0,0,0];
figure(5);
imagesc(pits)
colormap(map)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title ('Pits (3m Spacing)')
%saveas(5, strcat(test_name,'PitIDs.jpg'));

%% Fill Pits
[fill_dem, fill_flow_dir, fill_flow_accum, fill_pits, sort_pit_data] = Fill_Pits(dem, flow_dir, flow_accum, pits, pit_data, rain_dur, rain_dep, intensity, cellsize,numrows,numcols); %mov_dem, mov_flow_dir, mov_flow_accum,

map = 0.3 + (rand(length(sort_pit_data),3).*(1-.3));
map(1,:) = [0,0,0];

figure(6);
imagesc(fill_dem)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat('{DEM: Pits Filled by a }', int2str(rain_dur),'{-Hour, }',int2str(rain_dep),'-Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
%saveas(6, strcat(test_name,'PitsFilledDEM',int2str(rain_dep),'in.jpg'))

figure(7);
imagesc(fill_flow_dir)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat('{Flow Direction: Pits Filled by a }', int2str(rain_dur),'{-Hour, }',int2str(rain_dep),'-Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
%saveas(7, strcat(test_name,'PitsFilledFlowDir',int2str(rain_dep),'in.jpg'))

figure(8);
imagesc(fill_flow_accum)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat('{Flow Accumulation: Pits Filled by a }', int2str(rain_dur),'{-Hour, }',int2str(rain_dep),'-Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
%saveas(8, strcat(test_name,'PitsFilledFlowAccum',int2str(rain_dep),'in.jpg'))

figure(9);
imagesc(fill_pits)
colormap(map)
axis equal
xlabel('X (column)')
ylabel('Y (row)')
title(strcat('{Pits: Pits Remaining by a }', int2str(rain_dur),'{-Hour, }',int2str(rain_dep),'-Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
%saveas(9, strcat(test_name,'PitsFilled.jpg'))

% figure(10);
% imagesc(fill_dem - dem)
% colormap(map)
% axis equal
% xlabel('X (column)')
% ylabel('Y (row)')
% title(strcat('Fill Amount by a ', int2str(rain_dur),'-Hour ',int2str(rain_dep/0.0254),'Inch Rainfall Event (',int2str(cellsize),'m Spacing)'))
% saveas(10, strcat(name,'PitsFilled.jpg'))

% save mov_dem
% save mov_flow_dir
% save mov_flow_accum
% save mov_pits
% 
% movie(mov_dem, 10, 10); % play the movie 10 times at 10 fps
% movie(mov_flow_dir, 10, 10);
% movie(mov_flow_accum, 10, 10);
% movie(mov_pits, 10, 10);