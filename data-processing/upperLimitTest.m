%% Load data
load '../Data/Zeolites/filteredZeolites.mat'
keys = keys(M);
values = values(M);

%% Get energy limits
tic
energylimit = zeros(1, length(values));
kPoints = 5;
throwaway = floor(kPoints / 2);  % discard ends
for i = 1:length(values)
    dset = values{i};
    dsetLow = dset;
    dsetLow(dsetLow > (min(dsetLow, [], 'all') + 1e8)) = [];
    spreadLow = max(dsetLow, [], 'all') - min(dsetLow, [], 'all');
    numBinsLow = round(spreadLow / 100);

    [countsLow, edgesLow] = histcounts(dsetLow, numBinsLow);

    countsMovMean = movmean(countsLow, kPoints);
    countsMovMeanKeep = countsMovMean((1+throwaway):(length(countsMovMean)-throwaway));

    cmmkMax = max(countsMovMeanKeep);
    under1000 = find(countsMovMeanKeep <= (cmmkMax / 1000));
    energylimit(i) = edgesLow(under1000(1) + throwaway);
end
toc
