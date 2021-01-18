function label = makeLabels(X)

% makeLabels generates labels for each input example from the mean of each
% cluster of 8 examples (8 since I translated datasets 8 times).
%
% Inputs:
%   X - [m x w x h x c] matrix of m 3D examples with dimensions w, h, and c
%
% Outputs:
%   labels - label for all examples

exLabels = mean(X, [2, 3, 4]);
label = mean(exLabels);  % assign label
end