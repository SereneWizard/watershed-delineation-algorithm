function[vector_field] = flowDirectionVectorVisualization(flow_direction)
vector_field.X = zeros(size(flow_direction)); % x-position of point
vector_field.Y = zeros(size(flow_direction)); % y-position of point
vector_field.U = zeros(size(flow_direction)); % x-direction vector
vector_field.V = zeros(size(flow_direction)); % y-direction vector


for element = 1:numel(flow_direction)
    [r, c] = ind2sub(size(flow_direction), element);
    vector_field.X(r,c) = c;
    vector_field.Y(r,c) = r;
    % handle pits
    if flow_direction(element) < 0
        vector_field.U(r,c) = 0;
        vector_field.V(r,c) = 0;
    else
        % Convert flow direction angle back to cartesian coordinates to be
        % used in the vectors. One is used as the radius rho in pol2cart
        % because D8 has no magnitude
        [u, v] = pol2cart(flow_direction(r,c), 1);
        vector_field.U(r,c) = u;
        vector_field.V(r,c) = v;
    end
end
% alter one point so that all other points are half the size, making the
% visualization more appealing
vector_field.U(2, 2) = vector_field.U(2, 2).*2;
vector_field.V(2, 2) = vector_field.V(2, 2).*2;
end
