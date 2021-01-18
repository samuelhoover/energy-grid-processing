function upperLimit = getUpperLimit(dset)

% getUpperLimit takes in an energy grid dataset and returns an upper limit
% to the dataset that sufficiently retains information about the accessible
% and inaccessible spaces.
%
% Inputs:
%   dset - energy grid dataset
%
% Outputs:
%   upperLimit - single threshold energy value

kPoints = 5;  % number of points in moving average
throwaway = floor(kPoints / 2);  % discard ends of moving average
dsetLow = dset;
dsetLow(dsetLow > (min(dsetLow, [], 'all') + 1e8)) = [];  % ignore large values
spreadLow = max(dsetLow, [], 'all') - min(dsetLow, [], 'all');
numBinsLow = round(spreadLow / 100);  %

[countsLow, edgesLow] = histcounts(dsetLow, numBinsLow);

countsMovMean = movmean(countsLow, kPoints);  % compute moving average
% Discard the ends
countsMovMeanKeep = countsMovMean((1+throwaway):(length(countsMovMean)-throwaway));

cmmkMax = max(countsMovMeanKeep);
% Find where the moving average becomes 1/1000 of the max moving average
under1000 = find(countsMovMeanKeep <= (cmmkMax / 1000));
% Correlate under1000 to its energy value
upperLimit = edgesLow(under1000(1) + throwaway + 1);

end
