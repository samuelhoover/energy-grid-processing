function [finalZeolites, finalInfo] = sizeFilter(orthoZeolites, ...
                                                 datasetInfo)

% sizeFilter filters out sufficiently large orthogonal zeolites and
% zeolites that are considerably long in one dimension.
%
% Inputs:
%   rectZeolites - [n x 2] string matrix of n orthogonal zeolites 
%                  represented by integer identifiers (column 1) and 
%                  zeolite HDF5 filename (column 2)
%   datasetInfo -  [n x 11] matrix of n orthogonal zeolites represented by 
%                  integer identifiers (column 1) with unit cell lengths 
%                  a, b, c (columns 2, 3, 4), unit cell angles 
%                  alpha, gamma, beta (columns 5, 6, 7), dimensions of
%                  dataset size in x, y, and z dimensions (columns 8, 9,
%                  10), and number of data points (column 11)
%
% Outputs:
%   filteredZeolites - [n x 2] string matrix of n orthogonal, like-sized 
%                      zeolites represented by integer identifiers (column 1) 
%                      and zeolite HDF5 filename (column 2)
%   filteredInfo -     [n x 11] matrix of n orthogonal, like-sized zeolites 
%                      represented by integer identifiers (column 1) with 
%                      unit cell lengths a, b, c (columns 2, 3, 4), unit cell 
%                      angles alpha, gamma, beta (columns 5, 6, 7), dimensions 
%                      of dataset size in x, y, and z dimensions (columns 8, 
%                      9, 10), and number of data points (column 11) 

% 3D scatter plot of orthogonal datasets sizes
f = figure('visible', 'off');
sgtitle('Size of each dataset along each dimension')
subplot(2, 2, 1)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*')
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
subplot(2, 2, 2)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*')
view(0, 90)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
subplot(2, 2, 3)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*')
view(0, 0)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
subplot(2, 2, 4)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*')
view(90, 0)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
print(f, '../Data/Zeolites/Figures/Filtering/OrthogonalDatasetsScatter.png', ...
      '-dpng', '-r300');

% Plotting histogram to visualize distribution of dataset sizes
numBins = 100;
f = figure('visible', 'off');
h = histogram(datasetInfo(:, 11), numBins);
title('Distribution of dataset sizes')
xlabel('Number of data points')
ylabel('Number of datasets in bin')
print(f, '../Data/Zeolites/Figures/Filtering/OrthogonalDatasetsHistogram.png', ...
      '-dpng', '-r300');

valBins = h.Values;  % number of datasets in each bin
cumsumValBins = cumsum(valBins);  % cumulative sum of each bin
fracCumSum = cumsumValBins / cumsumValBins(end);  % fraction of cumulative

fracToKeep = 0.9;
% Keep lower (fracToKeep * 100) % of datasets sizes
numBinsToKeep = length(find(fracCumSum <= fracToKeep));
binEdges = h.BinEdges;  % extract bin edge values
% Set upper limit for dataset size to be right edge of last kept bin (+1 
% since 1st edge is left edge of first bin)
maxDataPoints = binEdges(numBinsToKeep + 1);

% Plotting histogram against cumulative sum
f = figure('visible', 'off');
yyaxis left  % set left axis to correlate to histogram scale
bar(valBins)
hold on
plot(numBinsToKeep * ones(1, 36), 0:35, 'k--')
title(['Binned dataset sizes [# of bins = ', num2str(numBins), ...
       ', min size = ', num2str(min(datasetInfo(:, 11))), ...
       ', max size = ', num2str(max(datasetInfo(:, 11))), ']'])
xlabel('Bins')
ylabel('Number of datasets in bin')
yyaxis right  % set right axis to correlate to cumulative sum scale
plot(1:numBins, fracCumSum, ...
     1:numBins, fracToKeep * ones(1, numBins), 'k-')
ylabel('Fraction of datasets within cumulative bins')
hold off
legend('Dataset distribution', ...
       'Cut off', ...
       'Cumulative sum of datasets', ...
       '90 % cumulative sum')
print(f, '../Data/Zeolites/Figures/Filtering/OrthogonalDatasetsBinsCumSum.png', ...
      '-dpng', '-r300');

% Find the total number of datasets with < maxDataPoints data points 
% (which corresponds to first two bins in which ~90% of all datasets fit 
% into)
sizeMatches = datasetInfo(:, 11) < maxDataPoints;
nonSizeMatchLoc = find(~sizeMatches);

% Remove zeolites that are too large compared to mean and median dataset
% size
filteredInfo = datasetInfo;
filteredInfo(nonSizeMatchLoc, :) = [];
filteredZeolites = orthoZeolites;
filteredZeolites(nonSizeMatchLoc, :) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performing outlier analysis to further filter unit cells that are %
% significantly long in one dimension compared to rest of zeolites  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Visually check for outliers using a box plot
f = figure('visible', 'off');
boxplot(filteredInfo(:, 8:10), 'Labels', {'a', 'b', 'c'})
title('Size of each dataset along each dimension')
xlabel('Dimensions')
ylabel('Number of data points')
print(f, '../Data/Zeolites/Figures/Filtering/OrthogonalDatasetsBoxplot.png', ...
      '-dpng', '-r300');

% Defining outliers as not within the range of lower limit (Q1 - 1.5 * IQR)
% to the upper limit (Q3 + 1.5 * IQR) [Q1 = first quartile, 
% IQR = interquartile range, Q3 = third quartile]
outliers = isoutlier(filteredInfo(:, 8:10), 'quartiles');

% Since checking for outliers over three dimensions, find(1) gives row i.e.
% zeolite while find(2) give column i.e. dimension
[outlierZeolites, ~] = find(outliers == 1);

% Remove outliers
finalInfo = filteredInfo;
finalInfo(outlierZeolites, :) = [];
finalZeolites = filteredZeolites;
finalZeolites(outlierZeolites, :) = [];

% 3D scatter plot of filtered datasets sizes
f = figure('visible', 'off');
sgtitle('Size of each dataset that survived filtering along each dimension')
subplot(2, 2, 1)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*', ...
      filteredInfo(:, 8), filteredInfo(:, 9), filteredInfo(:, 10), '*')
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
subplot(2, 2, 2)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*', ...
      filteredInfo(:, 8), filteredInfo(:, 9), filteredInfo(:, 10), '*')
view(0, 90)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
legend('Full orthogonal set', 'Filtered orthogonal set')
subplot(2, 2, 3)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*', ...
      filteredInfo(:, 8), filteredInfo(:, 9), filteredInfo(:, 10), '*')
view(0, 0)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
subplot(2, 2, 4)
plot3(datasetInfo(:, 8), datasetInfo(:, 9), datasetInfo(:, 10), '*', ...
      filteredInfo(:, 8), filteredInfo(:, 9), filteredInfo(:, 10), '*')
view(90, 0)
xlabel('a'); ylabel('b'); zlabel('c');
axis equal
grid on
print(f, '../Data/Zeolites/Figures/Filtering/FilteredDatasetsScatter.png', ...
      '-dpng', '-r300');

% Distribution of filtered datasets sizes
f = figure('visible', 'off');
histogram(filteredInfo(:, 11), 20);
title('Datasets that survived filtering')
xlabel('Number of data points')
ylabel('Number of datasets in bin')
print(f, '../Data/Zeolites/Figures/Filtering/FilteredDatasetsHistogram.png', ...
      '-dpng', '-r300');
  
fprintf('Check ../Data/Zeolites/Figures/Filtering for figures.\n\n')

end