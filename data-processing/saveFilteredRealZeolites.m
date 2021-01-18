%% Filter real zeolites
[filteredZeolites, filteredInfo] = zeoliteFiltering('../Data/Zeolites/HDF5 Files/Real Zeolites/');

%% Load datasets and save to containers.map
m = size(filteredZeolites, 1);
M = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:m
   key = filteredZeolites(i, 2);
   zeo = strsplit(key, '.');
   path = strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', key);
   dset = h5read(path, '/CH4');
   M(zeo{1}) = dset;
end
save('../Data/Zeolites/filteredRealZeolites.mat', 'M')
