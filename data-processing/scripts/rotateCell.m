function dset_R = rotateCell(dset)

% rotateCell takes a 3D energy grid cell and randomly rearranges axes so
% that the cell is rotated.
%
% Inputs:
%   dset - 3D dataset
%
% Outputs:
%   dset_R - randomly rotated dataset

randPos = randi(3);

positions = [1, 2, 3;
             3, 1, 2;
             2, 3, 1];

dset_R = permute(dset, positions(randPos, :));

end