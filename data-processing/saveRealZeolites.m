% Get .h5 file names from Real Zeolites directory
allFiles = dir('../Data/Zeolites/HDF5 Files/Real Zeolites/*.h5');
fileNames = {allFiles.name};  % extract all HDF5 file names
numFiles = length(allFiles);  % number of HDF5 files

% Initialize containers.map structure
M = containers.Map('KeyType', 'char', 'ValueType', 'any');

% Save all datasets into containers.map structure
for i = 1:numFiles
    % Key is zeolite structure file name
    key = fileNames{i};
    zeo = strsplit(key, '.');
    
    % Value is dataset for zeolite structre
    dset = h5read(strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', key), '/CH4');
    
    % Add key, value pair to containers.map
    M(zeo{1}) = dset;
    
end
save('../Data/Zeolites/Unprocessed Data/realZeolites.mat', 'M')  % save containers.map as .mat
