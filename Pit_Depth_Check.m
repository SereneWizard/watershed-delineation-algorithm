function [pit_depth_check] = Pit_Depth_Check(pits,pit_data,precip_depth)
global cellsize;
pit_depth_check = zeros(size(pits));
for el_pits = 1 : numel(pits)
    if pits(el_pits) == 0
        pit_depth_check(el_pits) = 0;
    elseif (precip_depth*pit_data(pits(el_pits),5)*cellsize*cellsize/100) > pit_data(pits(el_pits),7)
        pit_depth_check(el_pits) = 0;
    else
        pit_depth_check(el_pits) = pits(el_pits);
    end
end

percent_pits = 100*nnz(pits)/numel(pits)
average_pit_accumulation = mean(pit_data(:,5))
average_puddle_area = mean(pit_data(:,6))
percent_filled = 100*((numel(pit_depth_check) - nnz(pit_depth_check))./numel(pit_depth_check))