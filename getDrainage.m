function[drainage] = getDrainage(dem_size)
% This function acquires and returns the appropriate drainage/infiltration
% information for the area of interest.  Each cell of the drainage matrix
% with drainage out of the cell contains a positive infiltration rate value
% (m/hour).
drainage = zeros(dem_size) + 0.0;
end
