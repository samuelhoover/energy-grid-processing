function dsetNorm = inverseNormalizeData(dset, upperLimit)

% inverseNormalizeData normalizes and inverses data such that 
% [Lower limit, Upper limit] --> [1, 0].
%
% Inputs:
%   dset       - dataset
%   upperLimit - specified upper limit
% Outputs:
%   dsetNorm - inverse normalized data 

% Set upper limit on dataset
dset(dset >= upperLimit) = upperLimit;

% Find the miminum and maximum of the dataset and then inverse normalize
dsetMin = min(dset, [], 'all');
dsetMax = max(dset, [], 'all');
dsetNorm = 1 - ((dset - dsetMin) / (dsetMax - dsetMin));
end