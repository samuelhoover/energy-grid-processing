function dsetDownsampled = downsampleData(dset, outputSize, interpMethod)

% downsampleData takes in volume data and downsamples/resizes data to 
% desired size. 
%
% Inputs:
%   dset -             [n x 2] string matrix of n orthogonal, like-sized 
%                      zeolites represented by integer identifiers 
%                      (column 1) and zeolite HDF5 filename (column 2)
%   outputSize -       [3 x 1] array of desired output size
%   interpMethod -     string of desired interpolation method to be used
%                      for ``imresize3`` [limited to 'nearest', 'linear',
%                      'cubic', 'box', 'triangle', 'lanczos2', and
%                      'lanczos3']
%
% Outputs:
%   dsetDownsampled - downsampled volume data  

m = size(dset, 1);  % number of examples

% Preallocate space for downsampled volume data
dsetDownsampled = zeros(m, outputSize(1), outputSize(2), outputSize(3));
for i = 1:m
    resizeData = imresize3(squeeze(dset(i, : ,: ,:)), outputSize, ...
                           'antialiasing', true, 'method', interpMethod);  % resize volume data
    dsetDownsampled(i, :, :, :) = reshape(resizeData, [1, outputSize]);
end
end
