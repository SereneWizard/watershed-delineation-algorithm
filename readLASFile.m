function[data] = readLASFile(las_file)
% This function reads an LAS file and returns a matrix "data" of x,y,z
% values for an area.  Because a DEM will be made with this data, only
% points classified as ground points are taken.

xmax = 1000000000;
xmin = 0;
ymax = 1000000000;
ymin = 0;

file = fopen(las_file, 'r');

fseek(file,0, 'bof');
header.fileSignature = fread(file,4,'schar=>char','ieee-le')';

fseek(file,4,'bof');
header.fileSourceID = fread(file,2,'ushort','ieee-le')';

fseek(file,6,'bof');
header.globalEncoding = fread(file,2,'ushort','ieee-le')';

fseek(file,8,'bof');
header.projectIDGUIDData1 = fread(file,4,'ulong','ieee-le')';
header.projectIDGUIDData2 = fread(file,2,'ushort','ieee-le')';
header.projectIDGUIDData3 = fread(file,2,'ushort','ieee-le')';
header.projectIDGUIDData4 = fread(file,8,'uchar','ieee-le')';

fseek(file,24,'bof');
header.versionMajor = fread(file,1,'uchar=>double','ieee-le')';
header.versionMinor = fread(file,1,'uchar=>double','ieee-le')';
version = header.versionMajor+header.versionMinor/10;
clear versionMajor versionMinor;


fseek(file,26,'bof');
header.systemIdentifier = fread(file,32,'char','ieee-le')';

fseek(file,58,'bof');
header.generatingSoftware = fread(file,32,'char','ieee-le')';

fseek(file,90,'bof');
header.fileCreationDayOfYear = fread(file,1,'ushort','ieee-le')';
header.fileCreationYear = fread(file,1,'ushort','ieee-le')';

fseek(file,94,'bof');
header.headerSize = fread(file,1,'ushort','ieee-le')';

fseek(file,96,'bof');
header.offsetToPointData = fread(file,1,'uint32=>double','ieee-le')';

fseek(file,100,'bof');
header.numberOfVariableLengthRecords = fread(file,1,'ulong=>double','ieee-le')';

fseek(file,104,'bof');
header.pointDataFormatID = fread(file,1,'uchar=>double','ieee-le')';
header.pointDataRecordLength = fread(file,1,'ushort=>double','ieee-le')';

fseek(file,107,'bof');
header.numberOfPointRecords = fread(file,1,'ulong=>double','ieee-le')';
header.numberOfPointsByReturn = fread(file,5,'ulong=>double','ieee-le')';

fseek(file,131,'bof');
header.scaleX = fread(file,1,'double','ieee-le')';
header.scaleY = fread(file,1,'double','ieee-le')';
header.scaleZ = fread(file,1,'double','ieee-le')';

fseek(file,155,'bof');
header.offsetX = fread(file,1,'double','ieee-le')';
header.offsetY = fread(file,1,'double','ieee-le')';
header.offsetZ = fread(file,1,'double','ieee-le')';

fseek(file,179,'bof');
header.maxX = fread(file,1,'double','ieee-le')';
header.minX = fread(file,1,'double','ieee-le')';
header.maxY = fread(file,1,'double','ieee-le')';
header.minY = fread(file,1,'double','ieee-le')';
header.maxZ = fread(file,1,'double','ieee-le')';
header.minZ = fread(file,1,'double','ieee-le')';

%Variable Length Records
fseek(file,227,'bof');

switch header.pointDataFormatID
   case 0
     formatLength = 20;
   case 1
     formatLength = 28;
   case 2
     formatLength = 26;
   case 3
     formatLength = 34;
   otherwise
     error('Data format not supported.');
end

%Point Data Record
dataRecordsOffset = 281;
fseek(file, header.offsetToPointData, 'bof');
n = 1;
classes = zeros(20,1);
data = zeros(header.numberOfPointsByReturn(3),3);

for i = 1:header.numberOfPointRecords
    x = fread(file,1,'int32','ieee-le');
    x = (x * header.scaleX) + header.offsetX;
    y = fread(file,1,'int32', 'ieee-le');
    y = (y * header.scaleY) + header.offsetY;
    z = fread(file,1,'int32', 3,'ieee-le');
    z = (z * header.scaleZ) + header.offsetZ;
    class = fread(file,1,'int8=>double', 12,'ieee-le');
    classes(class,1) = classes(class,1) + 1;
    if x <= xmax && x >= xmin
        if y <= ymax && y >= ymin
            if class == 2   %get ground points
                data(n,1) = x;
                data(n,2) = y;
                data(n,3) = z;
                n = n+1;
            end
        end
    end
    clear x;
    clear y;
    clear z;
    clear class;
end
% figure(1);
% hold on;
% scatter3(datamatrix(:,1), datamatrix(:,2), datamatrix(:,3), 5, datamatrix(:,3), '.')
% axis equal                      % equal scale both axes
% xlabel('X (meters, UTM Z16N)')                     % caption for x-axis
% ylabel('Y (meters, UTM Z16N)')                     % caption for y-axis
% zlabel('Z (meters)')                     % caption for z-axis
% title ('LiDAR Point Data')
% orient landscape                % print graph in landscape mode

% This file was produced with the assistance of source code from Thomas J.
% Pingel, Department of Geography, University of California Santa Barbara
% (pingel@geog.ucsb.edu).  For other Matlab functions by this author, see
% http://www.geog.ucsb.edu/~pingel/code/index.html
