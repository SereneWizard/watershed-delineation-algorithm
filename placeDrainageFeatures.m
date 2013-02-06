function[drainage] = placeDrainageFeatures(drainage)
% Input addition tile drains/drainage features

more_tiles = input('Do tile drains/drainage features need to be placed? Y/N \n', 's');

while more_tiles == 'Y'
    disp('Select location of drainage tiles then input tile size.')
    [c, r] = ginput(1); % Get row and column indices from graphical input
    r = round(r); % round them to integer row and column indices
    c = round(c);
    rate = input('Input drainage rate(m/hr) for the tile at the selected location. \n', 's');
    drainage(r, c) = str2double(rate);
    more_tiles = input('Are there any additional tile drains to be placed? Y/N \n', 's');
end