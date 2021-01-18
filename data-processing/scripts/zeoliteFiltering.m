function [filteredZeolites, filteredInfo] = zeoliteFiltering(path)

% zeoliteFiltering reads the files in the directory path that is given
% (containing HDF5 files of real zeolites) and calls loadAttr, 
% orthogonalFilter, loadData, sizeFilter to filter out zeolites that are 
% non-orthogonal and not like-sized zeolites (relative to the orthogonal 
% zeolite unit cells).
%
% Inputs:
%   path - string array of path to directory with HDF5 files 
%
% Outputs:
%   filteredZeolites - [n x 2] string matrix of n orthogonal, like-sized 
%                      zeolites represented by integer identifiers 
%                      (column 1) and zeolite HDF5 filename (column 2)
%   filteredInfo -     [n x 11] matrix of n orthogonal, like-sized zeolites 
%                      represented by integer identifiers (column 1) with 
%                      unit cell lengths a, b, c (columns 2, 3, 4), unit 
%                      cell angles alpha, gamma, beta (columns 5, 6, 7), 
%                      dimensions of dataset size in x, y, and z dimensions 
%                      (columns 8, 9, 10), and number of data points 
%                      (column 11)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load zeolite structure information

%%%%%%%%%%%%%%%%%%%%%%
%%% ENERGY IS IN K %%%
%%%%%%%%%%%%%%%%%%%%%%

fprintf('Filtering out non-orthogonal zeolites \n')
fprintf('Filtering... \n\n')

% Load unit cell lengths and angles and zeolites
[allZeolites, allInfo] = loadAttr(path);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Separate out nonorthogonal zeolites

% Filter out nonorthogonal zeolites
[orthoZeolites, orthoInfo] = orthogonalFilter(allZeolites, allInfo);

fprintf('Completed \n\n')

fprintf('############################################ \n')
fprintf('### %i of %i zeolite structures remain ### \n', size(orthoInfo, 1), ...
                                                   size(allInfo, 1))
fprintf('############################################ \n\n')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract dataset information and keep like-sized datasets

fprintf('Filtering based on unit cell lengths \n')
fprintf('Filtering... \n\n')

datasetInfo = loadData(orthoZeolites, orthoInfo, path);

% Filter out too large datasets and datasets that are considerably long in
% one dimension compared to all of the orthogonal zeolites
[filteredZeolites, filteredInfo] = sizeFilter(orthoZeolites, datasetInfo);

fprintf('Completed \n\n')

fprintf('############################################ \n')
fprintf('### %i of %i zeolite structures remain ### \n', size(filteredInfo, 1), ...
                                                   size(orthoInfo, 1))
fprintf('############################################ \n\n')


end