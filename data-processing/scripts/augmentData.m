function augmentedExamples = augmentData(vol, numAug)

% augmentData takes volume data and creates augmented examples by randomly 
% translating and rotating volume data numAugmentations times. WITH 
% CURRENT IMPLEMENTATION, ONLY WORKS WITH CUBIC VOLUMES if rotateCell is
% used.
%
% Inputs:
%   vol -    3D cubic meshgrid data
%   numAug - integer specifying the number of augmented examples
%            to generate
%
% Outputs:
%   augmentedExamples - [numAugmentations, numel(vol)] 2D matrix storing
%                       all augmented examples, each row corresponds to a
%                       different augmented example

% Preallocate the space for all examples
augmentedExamples = zeros(numAug, numel(vol));

for i = 1:numAug
    vol = translateCell(vol);  % translates volume
%     vol = rotateCell(vol);  % rotates volume
    augmentedExamples(i, :) = vol(:);  % store augmented example
end