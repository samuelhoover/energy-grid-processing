%% Load info
[filteredZeolites, filteredInfo] = zeoliteFiltering('../Data/Zeolites/HDF5 Files/Real Zeolites/*.h5');

%% Do the sorting
filteredSizes = filteredInfo(:, 8:10);
sz = size(filteredSizes);
sortedSizes = zeros(sz);

% Rearrange dimensions so that the lengths increase from left to right
for i = 1:sz(1)
    sortedRow = sort(filteredSizes(i, :));
    sortedSizes(i, :) = sortedRow;
end

%% Prepare for downsampling
minSz = min(sortedSizes);
minSzCube = [min(minSz), min(minSz), min(minSz)];

dset = h5read('../Data/Zeolites/HDF5 Files/Real Zeolites/BEC-0.h5', '/CH4');  % load HDF5 'CH4' dataset
dsetNorm = inverseNormalizeData(dset);

%% Downsample test

dsetLinear = imresize3(dsetNorm, minSz, 'antialiasing', true, 'method', 'linear');
dsetNearest = imresize3(dsetNorm, minSz, 'antialiasing', true, 'method', 'nearest');
dsetBox = imresize3(dsetNorm, minSz, 'antialiasing', true, 'method', 'box');
dsetTriangle = imresize3(dsetNorm, minSz, 'antialiasing', true, 'method', 'triangle');
dsetCube = imresize3(dsetNorm, minSzCube, 'antialiasing', true, 'method', 'linear');

figure(1)
volshow(dsetNorm)
figure(2)
volshow(dsetLinear)
figure(3)
volshow(dsetNearest)
figure(4)
volshow(dsetBox)
figure(5)
volshow(dsetTriangle)
figure(6)
volshow(dsetCube)

%% Data augmentation test
vol = dsetCube;
dims = size(vol);
numAugmentations = 5;
augmentedExamples = zeros(numAugmentations, numel(vol));

for i = 1:numAugmentations
    vol_T = translateCell(vol);
    vol_R = rotateCell(vol_T);
    augmentedExamples(i, :) = vol_R(:);
end

%% Downsample all datasets
tic
dsetDownsampled = downsampleData(filteredZeolites, minSzCube, 'linear', 1);
toc
save('../Data/Zeolites/downsampledEnergyData.mat', 'dsetDownsampled')
%% Compare results of downsampled, flattened volumes to originals
m = size(filteredZeolites, 1);

i1 = randi(m);
orig1 = h5read(strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', filteredZeolites(i1, 2)), '/CH4');  % load HDF5 'CH4' dataset
orig1 = inverseNormalizeData(orig1);
figure
volshow(orig1);
figure
volshow(imresize3(orig1, minSzCube, 'antialiasing', true, 'method', 'linear'));  % resize volume data;

i2 = randi(m);
orig2 = h5read(strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', filteredZeolites(i2, 2)), '/CH4');  % load HDF5 'CH4' dataset
orig2 = inverseNormalizeData(orig2);
figure
volshow(orig2);
figure
volshow(reshape(dsetDownsampled(i2, :), minSzCube));

i3 = randi(m);
orig3 = h5read(strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', filteredZeolites(i3, 2)), '/CH4');  % load HDF5 'CH4' dataset
orig3 = inverseNormalizeData(orig3);
figure
volshow(orig3);
figure
volshow(reshape(dsetDownsampled(i3, :), minSzCube));
