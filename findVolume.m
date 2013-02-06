function[volume] = findVolume(cellsize, dem, indices_draining_to_desired_cell, spillover_elevation, area_to_be_filled, previously_filled_volumes)
% This function calculates the retention volume (in cubic meters) of a pit
% for usage in the pit_data variable as well as the sort_pit_data variable
% during filling operations.
pit_indices_less_than_spillover = indices_draining_to_desired_cell(dem(indices_draining_to_desired_cell) < spillover_elevation);
volume = (cellsize^2).*((area_to_be_filled.*spillover_elevation) - sum(dem(pit_indices_less_than_spillover))) + previously_filled_volumes;
end