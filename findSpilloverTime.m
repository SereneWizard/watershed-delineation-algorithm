function[spillover_time] = findSpilloverTime(cellsize, intensity, area, volume, drainage_rate)
% This function calculates the time it takes for a given pit to spill over.
% Volume is given in cubic meters, area in number of cells to be multiplied
% by the cellsize in meters and intensity is to be given in meters per
% hour.
spillover_time = volume./(area.*cellsize.^2)/intensity;
end