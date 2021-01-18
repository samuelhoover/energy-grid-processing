function [allZeolites, allInfo] = loadAttr(path)

% loadAttr extracts unit cell information coded as Attributes in HDF5
% files.
%
% Inputs:
%   allFiles - [m x 1] structure of directory output of folder with HDF5
%              files
%   path -     string array of path to directory with HDF5 files 
%
% Outputs:
%   allZeolites - [m x 2] string matrix of m zeolites represented by 
%                 integer identifiers (column 1) and zeolite HDF5 
%                 filenames (column 2)
%   allInfo -     [m x 7] matrix of m zeolites represented by integer 
%                 identifiers (column 1) with unit cell lengths a, b, c 
%                 (columns 2, 3, 4) and unit cell angles  alpha, gamma, 
%                 beta (columns 5, 6, 7) 

% Get all .h5 files
allFiles = dir(strcat(path, '*.h5'));

fileNames = {allFiles.name};  % extract all HDF5 file names
m = length(allFiles);  % number of HDF5 files

% Preallocating space
allLengths = zeros(m, 3);
allAngles = zeros(m, 3);

% Extract information from HDF5 files about unit cell structures
for i = 1:m
    zeoFile = strcat(path, fileNames{i});
    % Unit cell lengths [Angstrom]
    allLengths(i, :) = h5readatt(zeoFile, '/CH4', 'cell_length');
    % Unit cell angle [Radian]
    angleRadians = h5readatt(zeoFile, '/CH4', 'cell_angle');
    % Unit cell angles [Degree]
    allAngles(i, :) = angleRadians' * 180 / pi;
end

id = (1:m)';
allNames = string(fileNames)';  % convert cell array to string array

% Assign each zeolite/HDF5 file an indentifier
allZeolites = [id, allNames];
% Save all lengths and angles into matrix 
allInfo = [id, allLengths, allAngles];

end