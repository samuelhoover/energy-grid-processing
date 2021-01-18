%% Load data
% Energy structure data from HDF5 files
load ../Data/Zeolites/'Unprocessed Data'/filteredRealZeolites.mat
zeos = keys(M);
datasets = values(M);

% Some IZA structures from PB screening work
table = readtable('../Data/Zeolites/PB Screening/HC-IZASC.txt', 'Delimiter', ' ');
IZA_SC = table.IZA_SC;  % structure names
kH_C18 = table.kH_C18;  % Henry's constant for C18

%% Find which structures from filtered list are in HC_IZASC.txt and extract Henry's constant data
% Find index (Locb) in zeos of structures that are in table
[Lia, Locb] = ismember(IZA_SC, zeos);  % location in a i.e. IZA_SC
Locb = nonzeros(Locb);                 % location in b i.e. zeos
similarZeos = IZA_SC(Lia);             % get similar zeolite structures
similarDatasets = datasets(Locb);      % get similar energy structures
similarkH_C18 = {kH_C18(Lia)};         % get similar Henry's constant data
m = length(Locb);                      % number of similar stuctures

%% Get upper limit
tic
upperLimits = zeros(m, 1);
for i = 1:m
    upperLimits(i) = getUpperLimit_V2(removeOverlap(similarDatasets{i}));
end
if mean(upperLimits) > median(upperLimits)
    upperLimitOverall = median(upperLimits);
else
    upperLimitOverall = mean(upperLimits);
end
toc

%% Inverse normalize data
tic
for i = 1:m
    dsetNorm = inverseNormalizeData(similarDatasets{i}, upperLimitOverall);
    similarDatasets{i} = dsetNorm;
end
toc

%% Translate data
inputs = {};
tic
for i = 1:m
    dataset = similarDatasets{i};
    transCell = translateCell(dataset);  % [8 x size(dataset)]
%     inputs{(i - 1)*8 + 1:i*8} = transCell;
end
toc
% save('../Data/Zeolites/Processed Data/input_V3-1.mat', 'inputs')

%% Downsample data
ticis
for i = 1:m
    dsetsDown = downsampleData(similarDatasets{i}, [24, 24, 24], 'linear');
    similarDatasets{i} = dsetsDown;
end
toc
inputs = similarDatasets;
% save('../Data/Zeolites/Processed Data/input_V3.mat', 'inputs')

%% Combine fields and values into data structure
field1 = 'Zeolite_structures'; value1 = similarZeos;
field2 = 'Energy_grids'; value2 = similarDatasets';
field3 = 'Henry_constant'; value3 = num2cell(similarkH_C18);
zeoStruct = struct(field1, value1, field2, value2, field3, value3);
save('../Data/Zeolites/Processed Data/data_V1.mat', 'zeoStruct')

%% Generate labels (not needed if using data structure)
tic
labels = zeros(8 * m, 1);
for i = 1:m
    labels((i - 1)*8 + 1:i*8) = similarkH_C18(i);
end
toc
save('../Data/Zeolites/Processed Data/labels_V3.mat', 'labels')
