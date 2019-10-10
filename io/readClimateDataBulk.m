%% Preparation
clc, clear, close all;
[file, path] = uigetfile({'*.nc', 'NetCDF2-File (*.nc)'}, 'Please select one file to read. All files will be added automatically');
% ATTENTION! Do not use different Variables!

addpath('./scripts');
addpath('../functions');
folderContents = dir(strcat(path, '*.nc'));

%% Settings
use_boundaries = true;
Bounds_lat = [20 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-90 40]; % Boundaries for longitude [in degrees]
Plev_query = 70000; % Set to zero if you wish to keep all height dimensions in data. If you only wish to keep one height, set this number to the corresponding plev value.
auto_convert_time = true; % Set to true if you wish to automatically convert time specifications to datetimes. We recommend to set this to true because it will also cope for different start dates in different parts of the data.

%% Ingestion

% reset to defaults if no boundaries wanted.
if ~use_boundaries
    Bounds_lat = false;
    Bounds_lon = false;
end

% Find out dimensions and variable
dataParts = cell(size(folderContents, 1), 1);
dataParts{1} = readNetCDF2_new(strcat(path,folderContents(1).name), 'Latitudes', Bounds_lat, 'Longitudes', Bounds_lon, 'Plev', Plev_query, 'convertTime', auto_convert_time);
varn = getVariableName(dataParts{1});
dataDimensions = size(dataParts{1}.(varn));
disp(strcat({'Read file 1/'}, num2str(size(folderContents, 1))));
dataLength = 0;
dataLength = dataLength + dataDimensions(end);
numDimensions = length(dataDimensions);
dataDimensions = dataDimensions(1:end-1);

for i = 2:size(folderContents, 1)
    dataParts{i} = readNetCDF2_new(strcat(path,folderContents(i).name), 'Latitudes', Bounds_lat, 'Longitudes', Bounds_lon, 'Plev', Plev_query, 'convertTime', auto_convert_time);
    dataLength = dataLength + size(dataParts{i}.(varn), numDimensions);
    disp(strcat('Read file', {' '},num2str(i),'/', num2str(size(folderContents, 1))));
end

% Preallocation
data = dataParts{1};
data.(varn) = zeros([dataDimensions dataLength]);
if ~auto_convert_time
    if isfield(data, 'time')
        data.time = zeros(dataLength, 1);
    end
    if isfield(data, 'time_bnds')
        data.time_bnds = zeros(2, dataLength);
    end
    if isfield(data, 'time_bounds')
        data.time_bounds = zeros(2, dataLength);
    end
else
    if isfield(data, 'time')
        data.time = NaT(dataLength, 1);
    end
    if isfield(data, 'time_bnds')
        data.time_bnds = NaT(2, dataLength);
    end
    if isfield(data, 'time_bounds')
        data.time_bounds = NaT(2, dataLength);
    end
end

% Concatenation
currentPosition = 1;
for i = 1:length(dataParts)
    currentLength = length(dataParts{i}.time);
    if numDimensions == 4
        data.(varn)(:, :, :, currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.(varn);
    else
        data.(varn)(:, :, currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.(varn);
    end
    if isfield(data, 'time')
        data.time(currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time;
    end
    if isfield(data, 'time_bnds')
        data.time_bnds(:,currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time_bnds;
    end
    if isfield(data, 'time_bounds')
        data.time_bounds(:,currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time_bounds;
    end
    currentPosition = currentPosition + currentLength;
end

% check if we need to sort and sort if necessary
if ~issorted(data.time)
    data = sort_by_time(data);
end

% data = readNetCDF2(strcat(path,folderContents(1).name));
% if size(folderContents, 1) > 1
%     for i = 2:size(folderContents, 1)
%         data = concatenate_by_time(data, readNetCDF2(strcat(path,folderContents(i).name)));
%     end
%     data = sort_by_time(data);
% end

% Save
uisave('data', strcat(path, file, '.mat'));