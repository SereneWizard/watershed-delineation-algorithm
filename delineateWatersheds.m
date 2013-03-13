function[] = delineateWatersheds(dem, flow_direction, flow_accumulation)
% Prompt the user if they wish to delineate a watershed and display the
% upslope area.

more_watersheds = input('Do you want to delineate a watershed? Y/N \n', 's');

while more_watersheds == 'Y'
    disp('Select the outlet location of the watershed desired.')
    [c, r] = ginput(1); % Get row and column indices from graphical input
    r = round(r); % round them to integer row and column indices
    c = round(c);
    cell = sub2ind(size(dem), r, c);
    
    snap = input('Do you want to snap to local high flow areas (10x10 area)? Y/N \n', 's');
    current_max_flow_accumulation = 0;
    if snap == 'Y'
        for x = -5 : 5
            for y = -5 : 5
                if flow_accumulation(r+y, c+x) > current_max_flow_accumulation
                    current_max_flow_accumulation = flow_accumulation(r+y, c+x);
                    cell = sub2ind(size(dem), r+y, c+x);
                end
            end
        end
    end
    
    [flow_accumulation, ws_dem] = recursiveFlowAccumulationWS(flow_accumulation, flow_direction, dem, cell);
    figure(14);
    imagesc(ws_dem)
    axis equal
    xlabel('X (column)')
    ylabel('Y (row)')
    title(strcat(['Watershed Delineation: ']))

    more_watersheds = input('Are there any additional tile drains to be placed? Y/N \n', 's');
end