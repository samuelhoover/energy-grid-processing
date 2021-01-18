dset = h5read('../Data/Zeolites/HDF5 Files/Real Zeolites/ATN-1.h5', '/CH4');  % load HDF5 'CH4' dataset

% Set Overlap_Value instances to upper energy limit
upperLimit = 5000;
dset(dset >= 1E20) = upperLimit;

% Capping large values (consistent with Kim et. al in ESGAN/ZeoGAN 
% pre-processing)
dset_capped = dset;
dset_capped(dset_capped >= upperLimit) = upperLimit;

dsetMin = min(dset_capped, [], 'all');
dsetMax = max(dset_capped, [], 'all');
dsetNorm = 1 - ((dset_capped - dsetMin) / (dsetMax - dsetMin));

vol = dsetNorm;
dims = size(vol);
numAugmentations = 1;
augmentedExamples = zeros(numAugmentations, numel(vol));

for i = 1:numAugmentations
    vol_T = translateCell(vol);
    vol_R = rotateCell(vol_T);
%     augmentedExamples(i, :) = vol_R(:);
end

% The below line may not actually reshape the flattened array back to vol_R
% because rotation can cause a matrix with dimensions [a, b, c] to have the
% dimensions [c, b, a]. Therefore reshaping it back to `dims` could result
% in a improper reconstruction.

% ex1 = reshape(augmentedExamples(1, :), dims);

figure
volshow(vol_R)