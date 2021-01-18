function datasetInfo = loadData(orthoZeolites, orthoInfo, path)

% loadData loads HDF5 zeolite files and extracts dataset size information
% including the number of data points in each dataset.
%
% Inputs:
%   orthoZeolites - [n x 2] string matrix of n orthogonal zeolites
%                   represented by integer identifiers (column 1) and 
%                   zeolite HDF5 filename (column 2)
%   orthoInfo -     [n x 7] matrix of n orthogonal zeolites represented by 
%                   integer identifiers (column 1) with unit cell lengths 
%                   a, b, c (columns 2, 3, 4) and unit cell angles 
%                   alpha, gamma, beta (columns 5, 6, 7)
%   path -          string array of path to directory with HDF5 files 
%
% Outputs:
%   datasetInfo - [n x 11] matrix of n orthogonal zeolites represented by 
%                 integer identifiers (column 1) with unit cell lengths 
%                 a, b, c (columns 2, 3, 4), unit cell angles 
%                 alpha, gamma, beta (columns 5, 6, 7), dimensions of
%                 dataset size in x, y, and z dimensions (columns 8, 9,
%                 10), and number of data points (column 11) 

[n, ~] = size(orthoInfo);
datasetInfo = zeros(n, 4);

% Open remaining zeolites' datasets and extract dataset size info
for i = 1:n
    filename = strcat(path, orthoZeolites(i, 2));
    dset = h5read(filename, '/CH4');  % load 'CH4' dataset
    datasetInfo(i, 1) = size(dset, 1);
    datasetInfo(i, 2) = size(dset, 2);
    datasetInfo(i, 3) = size(dset, 3);
    datasetInfo(i, 4) = numel(dset);  % number of data points in dataset
end

% Assigning identifier to remaining zeolites and dataset information
datasetInfo = [orthoInfo, datasetInfo];

end