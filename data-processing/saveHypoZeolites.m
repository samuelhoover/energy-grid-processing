% Get .h5 file names from Real Zeolites directory
allFiles = dir('/Volumes/Samuel Hoover External HDD/Hypothetical Zeolites/*.h5');
fileNames = {allFiles.name};  % extract all HDF5 file names
numFiles = length(allFiles);  % number of HDF5 files
% Initialize containers.map structure
M = containers.Map('KeyType', 'char', 'ValueType', 'any');
% Save all datasets into containers.map structure
for i = 1:numFiles
    % Key is zeolite structure file name
    key = fileNames{i};
    % Value is dataset for zeolite structre
    value = h5read(strcat('/Volumes/Samuel Hoover External HDD/Hypothetical Zeolites/', key), '/CH4');
    % Add key, value pair to containers.map
    M(key) = value;
end
save('/Volumes/Samuel Hoover''s External HDD/Hypothetical Zeolites/hypotheticalZeolites.mat', 'M')  % save containers.map as .mat
