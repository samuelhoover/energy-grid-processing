%% 1.1 Load data
load '../Data/Zeolites/Unprocessed Data/realZeolites.mat'
keySet = keys(M);
valueSet = values(M);

%% 1.2 Load specific dataset
zeo = 'ATN-0.h5';
zeostrsplit = strsplit(zeo, '.');
dset = M(zeostrsplit{1});

%% 2.1 Remove overlap values
% Remove overlap values
dset = removeOverlap(dset);
numData = numel(dset);
fprintf('%s: raw data \n', zeostrsplit{1})
fprintf('Mean: %.3e K \n', mean(dset, 'all'))
fprintf('Median: %.3e K \n', median(dset, 'all'))
fprintf('Min: %.3e K \n', min(dset, [], 'all'))
fprintf('Max: %.3e K \n\n', max(dset, [], 'all'))

%% 2.2 Compare raw data to removed overlap values data
dset = M('MFI-1.h5');
dsetRO = removeOverlap(dset);

figure;
subplot(2, 2, [1, 2])
histogram(dset, 100);
set(gca, 'Yscale', 'log')
title('MFI-1 [With overlap values]')
xlabel('Energy [K]')
ylabel('Frequency')
axis([-6E18, 1.05E20, 3E1, 1E6])
subplot(2, 2, [3, 4])
histogram(dsetRO, 100);
set(gca, 'Yscale', 'log')
title('MFI-1 [Without overlap values]')
xlabel('Energy [K]')
ylabel('Frequency')
print('../Data/Zeolites/Figures/MFI-1_With_Without_Overlap.png', '-dpng', '-r300')

%% 2.3 Visualize raw dataset distribution
h = histogram(dset);
set(gca, 'Yscale', 'log')
numBins = h.NumBins;
interval = (max(dset, [], 'all') - min(dset, [], 'all')) / numBins;
title(sprintf('%s [%i bins, %0.1e interval]', zeostrsplit{1}, numBins, interval))
xlabel('Energy [K]')
ylabel('Frequency')

%% 2.4 Transform the data
% Transforming data using exp(-U/T) where U is energy and T is temperature
T = 1e4;
dsetExp = exp(-dset / T);
fprintf('%s: exp(-U/T) transformation \n', char(zeostrsplit(1)))
fprintf('T: %.0f K \n', T)
fprintf('Mean: %.6f \n', mean(dsetExp, 'all'))
fprintf('Median: %.6f \n', median(dsetExp, 'all'))
fprintf('Min: %.6f \n', min(dsetExp, [], 'all'))
fprintf('Max: %.6f \n\n', max(dsetExp, [], 'all'))
spread = max(dsetExp, [], 'all') - min(dsetExp, [], 'all');

% figure;
% volshow(dsetExp);

%% 2.5 Visualize exponential transformation dataset distribution
numBinsExp = round(spread / 0.01);
intervalExp = (max(dsetExp, [], 'all') - min(dsetExp, [], 'all')) / numBinsExp;
h = histogram(dsetExp, numBinsExp);
set(gca, 'Yscale', 'log')
% h = histogram(dsetExp);
% numBinsExp = h.NumBins;
% intervalExp = (max(dsetExp, [], 'all') - min(dsetExp, [], 'all')) / numBinsExp;
title(sprintf('%s: exponential transformation [%.0f K, %i bins, %0.1e interval]', zeostrsplit{1}, T, numBinsExp, intervalExp))
xlabel('Dimensionless Energy [exp(-U/T)]')
ylabel('Frequency')


%% 2.6 Distribution of transformed data with cumulative sum
numBins = round(spread / 10);
interval = spread / numBins;
[counts, ~] = histcounts(dsetExp, numBinsExp);
cdf = cumsum(counts) / numData;

figure;
yyaxis left
bar(0:numBinsExp - 1, counts)
% h = histogram(dsetExp, numBins);
% counts = h.Values;
xlabel('Energy [exp(-U/T)]')
xticklabels({'0','500','1000', '1500', '2000', '2500', '3000'})
ylabel('Frequency')
set(gca, 'Yscale', 'log')
hold on
yyaxis right
plot(0:numBinsExp - 1, cdf, 'b-')
ylabel('cumsum')
title(sprintf('%s [%.0f K, %i bins, %0.6f interval]', zeo, T, numBinsExp, interval))

%% 2.7 Thresholding methods to try to find upper limit
[threshMulti, EMMulti] = multithresh(dsetExp);  % `threshMulti` is dimensionless energy
[threshOtsu, EMOtsu] = otsuthresh(counts);  % `threshOtsu` is scaled ([0, 1]), dimensionless energy

% Convert scaled `threshOtsu` to relative spread scale
threshOtsu = spread * threshOtsu;

% Transform threshold values back to raw format
rawThreshs = log([threshMulti, threshOtsu]) * -T;

%% 2.8 Distribution of raw data just from [-min, min + 1,000,000 K]
dsetLow = dset;
dsetLow(dsetLow > (min(dsetLow, [], 'all') + 1e8)) = [];
spreadLow = max(dsetLow, [], 'all') - min(dsetLow, [], 'all');
numBinsLow = round(spreadLow / 1000000);

% f = figure('visible', 'off');
figure;
hLow = histogram(dsetLow, numBinsLow);
set(gca, 'Yscale', 'log')
% countsLow = hLow.Values;
% edgesLow = hLow.BinEdges;
% [maxcountsLow, idx] = max(countsLow);
% modeLow = edgesLow(idx + 1);
% 
% % idxLow = find(countsLow <= (maxcountsLow / 1000));
% % energylimit = edgesLow(idxLow(1) + 1);
% % countsLow(idxLow);
% 
% kMeans = 5;
% throwaway = floor(kMeans / 2);  % discard ends
% countsMovMean = movmean(countsLow, kMeans);
% countsMovMeanKeep = countsMovMean((1+throwaway):(length(countsMovMean)-throwaway));
% 
% figure;
% plot(1:length(countsMovMeanKeep), countsMovMeanKeep)
% axis([0, 1e4, 0, Inf])
% 
% cmmkMax = max(countsMovMeanKeep);
% under1000 = find(countsMovMeanKeep <= (cmmkMax / 1000));
% energylimit = edgesLow(under1000(1) + throwaway);

%% 3.1 Look at FAU, BCT, and MFI examples
% BCT - small channel system
%   Maximum diameter of sphere that can:
%     included - 3.8 Å 
%     diffuse along - a: 2.55 Å, b: 2.55 Å, c: 2.91 Å 
% MFI - medium channel system
%   Maximum diameter of sphere that can:
%     included - 6.36 Å
%     diffuse along - a: 4.7 Å,	b: 4.46 Å, c: 4.46 Å 
% FAU - large channel system
%   Maximum diameter of sphere that can:
%     included - 11.24 Å
%     diffuse along - a: 7.35 Å, b: 7.35 Å, c: 7.35 Å 

BCTdset = removeOverlap(M('BCT-0.h5'));  % Small channel system
MFIdset = removeOverlap(M('MFI-0.h5'));  % Medium channel system
FAUdset = removeOverlap(M('FAU-0.h5'));  % Large channel system

T = 1E4;
BCTdsetExp = exp(-BCTdset / T);
BCTdsetExp = exp(-MFIdset / T);
FAUdsetExp = exp(-FAUdset / T);

numBins = 100;

%% 3.2 Compare distributions of raw and exponential forms
t = tiledlayout(2, 3);

ax1 = nexttile;
histogram(BCTdset, numBins);
set(gca, 'Yscale', 'log')
title('BCT-0')
xlabel('Energy [K]')

ax2 = nexttile;
histogram(MFIdset, numBins);
set(gca, 'Yscale', 'log')
title('MFI-0')
xlabel('Energy [K]')

ax3 = nexttile;
histogram(FAUdset, numBins);
set(gca, 'Yscale', 'log')
title('FAU-0')
xlabel('Energy [K]')

ax4 = nexttile;
histogram(BCTdsetExp, numBins);
set(gca, 'Yscale', 'log')
title('BCT-0 [T = 1000 K]')
xlabel('exp(-U/T)')

ax5 = nexttile;
histogram(BCTdsetExp, numBins);
set(gca, 'Yscale', 'log')
title('MFI-0 [T = 1000 K]')
xlabel('exp(-U/T)')

ax6 = nexttile;
histogram(FAUdsetExp, numBins);
set(gca, 'Yscale', 'log')
title('FAU-0 [T = 1000 K]')
xlabel('exp(-U/T)')

linkaxes([ax1, ax2, ax3], 'x')
linkaxes([ax4, ax5, ax6], 'x')
linkaxes([ax1, ax2, ax3, ax4, ax5, ax6], 'y')
ylabel(t, 'Frequency')
print(gcf, '../Data/Zeolites/Figures/Compare_Transformations.png', '-dpng', '-r300')

% Closer look at BCT-0 distribution
figure;
subplot(2, 1, 1)
histogram(BCTdset, numBins);
set(gca, 'Yscale', 'log')
title('BCT-0')
xlabel('Energy [K]')
ylabel('Frequency')
subplot(2, 1, 2)
histogram(BCTdsetExp, numBins);
set(gca, 'Yscale', 'log')
title('BCT-0 [T = 1000 K]')
xlabel('Dimensionless Energy [exp(-U/T)]')
ylabel('Frequency')
print(gcf, '../Data/Zeolites/Figures/BCT-0_Compare_Transformations.png', '-dpng', '-r300')

%% 3.3 Compare different weighting temperatures
i = 1;
dset = {BCTdset, MFIdset, FAUdset};
dsetName = ["BCT", "MFI", "FAU"];
figure;
for T = [1E3, 1E4, 1E5]
    for j = 1:3
        dsetExp = exp(-dset{j} ./ T);
        subplot(3, 3, i)
        histogram(dsetExp, 100)
        set(gca, 'Yscale', 'log')
        title(sprintf('%s [T = %.0e K]', dsetName(j), T))
        xlabel('exp(-U/T)')
        if j == 1
            ylabel('Frequency')
        end
        i = i + 1;
    end
end
print(gcf, '../Data/Zeolites/Figures/BCT_MFI_FAU_Different_T.png', '-dpng', '-r300')

%% 3.4 Use moving average method described in 2.8
T = 1E6;
BCTdsetExp = exp(-BCTdset / T);

f = figure('visible', 'off');
h = histogram(BCTdsetExp, 100);
set(gca, 'Yscale', 'log')

kMeans = 5;
throwaway = floor(kMeans / 2);  % discard ends
countsMovMean = movmean(counts, kMeans);
countsMovMeanKeep = countsMovMean((1+throwaway):(length(countsMovMean)-throwaway));

figure;
plot(throwaway + (1:length(countsMovMeanKeep)), countsMovMeanKeep)
set(gca, 'Yscale', 'log')
hold on
bar(counts)

[cmmkMax, maxidx] = max(countsMovMeanKeep);
[cmmkMin, minidx] = min(countsMovMeanKeep);
under1000 = find(countsMovMeanKeep <= (cmmkMax / 1000));
expenergylimit = edges(minidx + throwaway);
energylimit = log(expenergylimit) * -T;

%% 4.1 Load filtered zeolite data
load '../Data/Zeolites/filteredZeolites.mat'
keySet = keys(M);
valueSet = values(M);

%% 4.2 Generate comparison plots of filterez zeolites
m = length(M);
tic
for i = 1:m
    dset = removeOverlap(valueSet{i});
    zeo = strsplit(keySet{i}, '.');
    f = figure('Position', [0, 0, 1200, 600], 'Visible', 'off');
    t = tiledlayout(2, 2);

    ax1 = nexttile;
    histogram(dset, 100);
    set(gca, 'Yscale', 'log')
    title(sprintf('%s', zeo{1}))
    xlabel('Energy [K]')

    ax2 = nexttile;
    histogram(exp(-dset / 1000), 100);
    set(gca, 'Yscale', 'log')
    title(sprintf('%s [T = 1,000 K]', zeo{1}))
    xlabel('Dimensionless energy [exp(-U/T)]')

    ax3 = nexttile;
    histogram(exp(-dset / 10000), 100);
    set(gca, 'Yscale', 'log')
    title(sprintf('%s [T = 10,000 K]', zeo{1}))
    xlabel('Dimensionless energy [exp(-U/T)]')

    ax4 = nexttile;
    histogram(exp(-dset / 100000), 100);
    set(gca, 'Yscale', 'log')
    title(sprintf('%s [T = 100,000 K]', zeo{1}))
    xlabel('Dimensionless energy [exp(-U/T)]')

    linkaxes([ax1, ax2, ax3, ax4], 'y')
    ylabel(t, 'Frequency')
    print(gcf, sprintf('../Data/Zeolites/Figures/Format Comparisons/1E3-1E5 K/%s.png', zeo{1}), '-dpng', '-r300')
end
toc
