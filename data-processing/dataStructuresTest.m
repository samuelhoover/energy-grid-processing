% Trying to store names, kHs, and datasets into a single object
zeos = {'MFI-1', 'ATN-0', 'FAU-2'};
datasets = {zeros(10, 10, 10), ones(34, 12, 23), zeros(2, 3, 4)};
kHs = {1000, 234, 34234234};

%% containers.Map object
keys = zeos;
values = {datasets, kHs};
M5 = containers.Map(keys, values);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error using containers.Map
% The number of keys and values must be the same.
% 
% Error in dataStructuresTest (line 9)
% M5 = containers.Map(keys, values);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Can't map kH and datasets to multiple names 
% OR
% Can't map names and datasets to multiple kHs

% `values` becomes a 1x2 cell array (even though `datasets` and `kH` are 
% 3x1 objects) while `keys` are a 3x1 cell array

%% data structure using dot notation
structureDot.zeos = zeos;
structureDot.datasets = datasets;
structureDot.kH = kHs;
structureDot.title = 'Zeolite structures with energy grid files and Henry''s constant';

structureDot(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ans = 
% 
%   struct with fields:
% 
%         zeos: {'MFI-1'  'ATN-0'  'FAU-2'}
%     datasets: {[10×10×10 double]  [34×12×23 double]  [2×3×4 double]}
%           kH: {[1000]  [234]  [34234234]}
%        title: 'Zeolite structures with energy grid files and Henry's constant'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This works but can't not directly able to call zeolite structure name,
% dataset, and kH are simultaneously in MATLAB

save('../Data/Zeolites/structDotTest.mat', 'structureDot');

%% data structure using prespecified fields and values
field1 = 'Zeolite_structures'; value1 = zeos;
field2 = 'Energy_grids'; value2 = datasets;
field3 = 'Henrys_constant'; value3 = kHs;
structurePre = struct(field1, value1, field2, value2, field3, value3);

structurePre(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ans = 
% 
%   struct with fields:
% 
%     Zeolite_structures: 'MFI-1'
%           Energy_grids: [10×10×10 double]
%        Henrys_constant: 1000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Works AND can call zeolite structure name, dataset, and kH simultaneously
% BUT all values need to be in cell arrays

zeo = structurePre(1).Zeolite_structures;  % zeo = 'MFI-1'
dataset = structurePre(1).Energy_grids;  % dataset = zeros(10, 10 , 10)
kH = structurePre(1).Henrys_constant;  % kH = 1000

save('../Data/Zeolites/structPreTest.mat', 'structurePre');

% Can be unpacked in Python using scipy.io.loadmat and should use
% squeeze_me option to clean up import (removes datatype flag)
