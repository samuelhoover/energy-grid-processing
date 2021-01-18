function dsetTranslated = translateCell(dset)

% translateCell takes a 3D energy grid cell and translates the cell 1/2 the
% length of each of the 3 dimensions. Each example is a different
% permutation i.e. [translated in X, not translated in Y, translated in Z],
% [translated in X, not translated in Y, not translated in Z], etc. 
% (2 outcomes ^ 3 dimensions = 8 examples).
%
% Inputs:
%   dset - 3D dataset
%
% Outputs:
%   dsetTranslated - translated examples

[a, b, c] = size(dset);
transX = round(c / 2);
transY = round(b / 2);
transZ = round(a / 2);

dsetTranslated = zeros(8, a, b, c);
idx = 1;
% Naive implementation
for x = [0, transX]
    for y = [0, transY]
        for z = [0, transZ]
            % translate in X direction
            dset_T = cat(3, dset(:, :, x + 1:end), dset(:, :, 1:x));
            % translate in Y direction
            dset_T = cat(2, dset_T(:, y + 1:end, :), dset_T(:, 1:y, :));
            % translate in Z direction
            dset_T = cat(1, dset_T(z + 1:end, :, :), dset_T(1:z, :, :));
            dsetTranslated(idx, :, :, :) = reshape(dset_T, [1, a, b, c]);
            idx = idx + 1;
        end
    end
end