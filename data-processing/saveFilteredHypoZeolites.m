%% Filter hypothetical zeolites
[filteredHypoZeolites, filteredHypoInfo] = zeoliteFiltering('/Volumes/Samuel Hoover External HDD/Hypothetical Zeolites/');

%% Load datasets and save to containers.map
m = size(filteredHypoZeolites, 1);
M = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:m
   key = filteredHypoZeolites(i, 2);
   zeo = strsplit(key, '.');
   path = strcat('Volumes/Hypothetical Zeolites/', key);
   dset = h5read(path, '/CH4');
   M(zeo{1}) = dset;
end
save('../Data/Zeolites/filteredHypoZeolites.mat', 'M')
