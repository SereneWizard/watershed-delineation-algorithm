function[dem, drainage, flow_direction_key, flow_accumulation_key, pits_key, fill_dem_key, fill_flow_direction_key, fill_flow_accumulation_key, fill_pits_key, perform_error_checks, cellsize] = parseInputFormat(input_name, cellsize)
% Identify the format of the input file/name and parse it appropriately.

drainage = [];
flow_direction_key = [];
flow_accumulation_key = [];
pits_key = [];
fill_dem_key = [];
fill_flow_direction_key = [];
fill_flow_accumulation_key = [];
fill_pits_key = [];
perform_error_checks = 0;
    
% handle geotiff DEMs
if ~isempty(regexpi(input_name, '.tif'))  % non-case-sensitive matching
    cellsize = 1.5;
    dem = geotiffread(input_name);
    for el = 1 : numel(dem)
        if dem(el) <= 0 % these DEMS have NoData values = -999
            dem(el) = NaN;
        end
    end
    return;
end

% handle example csv DEMs
if ~isempty(regexpi(input_name, 'example|.csv')) % non-case-sensitive matching
    examples = csvread(input_name);
    [r, c] = size(examples);
    for i = 1 : r
        if (examples(i,1) == 0)
            break;
        else
            for j = 1 : c
                dem(i,j) = examples(i,j);
            end
        end
    end
    [numrows,numcols] = size(dem);
    
    drainage = examples((numrows+1)*1+1:(numrows+1)*1+numrows, 1:numcols);
    flow_direction_key = examples((numrows+1)*2+1:(numrows+1)*2+numrows, 1:numcols);
    flow_accumulation_key = examples((numrows+1)*3+1:(numrows+1)*3+numrows, 1:numcols);
    pits_key = examples((numrows+1)*4+1:(numrows+1)*4+numrows, 1:numcols);
    fill_dem_key = examples((numrows+1)*5+1:(numrows+1)*5+numrows, 1:numcols);
    fill_flow_direction_key = examples((numrows+1)*6+1:(numrows+1)*6+numrows, 1:numcols);
    fill_flow_accumulation_key = examples((numrows+1)*7+1:(numrows+1)*7+numrows, 1:numcols);
    fill_pits_key = examples((numrows+1)*8+1:(numrows+1)*8+numrows, 1:numcols);
    perform_error_checks = 1;
    return;
end

% handle image examples made in PS
if ~isempty(regexpi(input_name, 'image_example|.bmp')) % non-case-sensitive matching
    input_name = imread(name,'bmp');
    throw NotImplemented
    return;
end

% handle raw LiDAR data/stored data variable
if ~isempty(regexpi(input_name, '.las')) % non-case-sensitive matching   
    data = readLASFile(input_name);
    input_name(1:length(input_name)-4)
    save(input_name(1:length(input_name)-4), 'data');
    dem_tic = tic;
    dem = makeDEM(data, cellsize);
    dem_time = toc(dem_tic);
    disp(strcat(['Make DEM: ', num2str(dem_time), ' seconds']))
    return;
end

% Otherwise, the input name is to be taken as the name of a lidar data
% variable.
load(input_name, 'data');
dem_tic = tic;
dem = makeDEM(data, cellsize);
dem_time = toc(dem_tic);
disp(strcat(['Make DEM: ', num2str(dem_time), ' seconds']))
return;

end
