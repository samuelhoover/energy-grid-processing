function upperLimit = getUpperLimit_V2(dset)

% getUpperLimit takes in an energy grid dataset and returns an upper limit
% to the dataset that sufficiently retains information about the accessible
% and inaccessible spaces.
%
% Inputs:
%   dset - energy grid dataset
%
% Outputs:
%   upperLimit - single threshold energy value

T = 1E5;  % weight temperature [K]
dsetExp = exp(-dset / T);

[counts, edges] = histcounts(dsetExp, 100);

kMeans = 5;
throwaway = floor(kMeans / 2);  % discard ends
countsMovMean = movmean(counts, kMeans);
countsMovMeanKeep = countsMovMean((1+throwaway):(length(countsMovMean)-throwaway));

[~, minidx] = min(countsMovMeanKeep);
expenergylimit = edges(minidx + throwaway);
upperLimit = log(expenergylimit) * -T;

end
