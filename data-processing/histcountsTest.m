%% Load BCT-1 data
zeo_name = 'BCT-1.h5';
zeo_file = strcat('../Data/Zeolites/HDF5 Files/Real zeolites/', zeo_name);
dset = h5read(zeo_file, '/CH4');  % load HDF5 'CH4' dataset

% Set Overlap_Value [1E20] instances to average energy value
dsetMean = mean(dset, 'all');
dset(dset >= 1E20) = dsetMean;   % 6.8695e+16
numData = numel(dset);           % 50336
dsetMin = min(dset, [], 'all');  % 1.0055e+04
dsetMax = max(dset, [], 'all');  % 5.8931e+18
spread = dsetMax - dsetMin;      % 5.8931e+18

%% Histograms
% 65,536 bins is the maximum number of bins allowed (2^16) if using
% histcounts

numBins = 1E6;
% figure;
% h = histogram(dset, numBins);
% counts = h.Values;
% edges = h.BinEdges;
% interval = edges(2) - edges(1);
% xlabel('Energy [K]')
% title(sprintf('%i bins, %0.3e interval', numBins, interval))
[counts, edges] = histcounts(dset, numBins);

% Using `multithresh` to automatically determine where the split point
% exists for tresholding accessible/inaccessible space
[thresh, EM] = multithresh(dset);  % thresh = 3.2932e+18

% Testing time required to bin data into increasing number of bins, it is
% exponential.
% i = 1;
% bins = [1E3, 1E4, 1E5, 1E6, 1E7];
% elapsedTime = zeros(size(bins));
% for bin = bins
%     figure;
%     tic;
%     h = histogram(dset, bin);
%     xlabel('Energy [K]')
%     title(sprintf('%.0e bins, %0.3e interval', h.NumBins, (h.BinEdges(2) - h.BinEdges(1))))
%     elapsedTime(i) = toc;
%     i = i + 1;
% end
% 
% figure;
% semilogx(bins, elapsedTime, '*')
% xlabel('Number of bins')
% ylabel('Time to bin data [s]')

%% Using `thresh` value, setting limit to energy values
dsetCapped = dset;
dsetCapped(dsetCapped >= thresh) = thresh;
% figure;
% volshow(dsetCapped);  % not good enough

%% I think I'm going about this the wrong way, next approach
% Going to try to "keep" data from first few bins i.e. the majority and
% then transform whatever falls outside of those bins. Only now will I
% threshold the data.

cumsumCount = cumsum(counts);  % cumulative sum of each bin
fracCumSum = cumsumCount / cumsumCount(end);  % fraction of cumulative sum
% figure;
% plot(1:length(counts), fracCumSum, 'LineWidth', 2)
% title('Energy data from previous histogram')
% xlabel('Bins')
% ylabel('Fraction of data points within cumulative sum') 
% axes('Position', [0.53, 0.22, 0.3, 0.3])
% box on
% plot(1:length(counts), fracCumSum, 'LineWidth', 2)
% axis([0, (numBins / 5), 0.996, 1.0])

isgreaterthan_80 = find(fracCumSum >= 0.8);
where_80 = edges(isgreaterthan_80(1) + 1);  % 5.8931e+12
dsetNew = dset;
dsetNew(dsetNew >= where_80) = where_80;

% figure;
% volshow(dsetNew);  % still not good enough

%% Binning data again

numBins = 1E6;
% figure;
% h = histogram(dsetNew, numBins);
% counts = h.Values;
% edges = h.BinEdges;
% interval = edges(2) - edges(1);
% xlabel('Energy [K]')
% title(sprintf('%i bins, %0.3e interval', numBins, interval))
[counts, edges] = histcounts(dsetNew, numBins);

cumsumCount = cumsum(counts);  % cumulative sum of each bin
fracCumSum = cumsumCount / cumsumCount(end);  % fraction of cumulative sum
% figure;
% plot(1:numBins, fracCumSum, 'LineWidth', 2)
% title('Energy data from previous histogram')
% xlabel('Bins')
% ylabel('Fraction of data points within cumulative sum') 
% axes('Position', [0.53, 0.22, 0.3, 0.3])
% box on
% plot(1:length(counts), fracCumSum, 'LineWidth', 2)
% axis([0, (numBins / 1000), 0, 1.0])

isgreaterthan_80 = find(fracCumSum >= 0.8);
where_80 = edges(isgreaterthan_80(1) + 1);  % 1.3201e+09
dsetNewNew = dsetNew;
dsetNewNew(dsetNewNew >= where_80) = where_80;

% figure;
% volshow(dsetNewNew);  % maybe good enough
