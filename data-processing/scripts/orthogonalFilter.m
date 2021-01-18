function [orthoZeolites, orthoInfo] = orthogonalFilter(allZeolites, ...
                                                       allInfo)

% orthogonalFilter filters out all non-orthogonal zeolite unit cells.
%
% Inputs:
%   allZeolites - [m x 2] string matrix of m zeolites represented by 
%                 integer identifiers (column 1) and zeolite HDF5 filename
%                 (column 2)
%   allInfo -     [m x 7] matrix of m zeolites represented by integer 
%                 identifiers (column 1) with unit cell lengths a, b, c 
%                 (columns 2, 3, 4) and unit cell angles alpha, gamma, beta 
%                 (columns 5, 6, 7)
%
% Outputs:
%   orthoZeolites - [n x 2] string matrix of n orthogonal zeolites
%                   represented by integer identifiers (column 1) and 
%                   zeolite HDF5 filename (column 2)
%   orthoInfo -     [n x 7] matrix of n orthogonal zeolites represented by 
%                   integer identifiers (column 1) with unit cell lengths 
%                   a, b, c (columns 2, 3, 4) and unit cell angles 
%                   alpha, gamma, beta (columns 5, 6, 7) 

m = size(allInfo, 1);  % number of zeolites
angleMatch = [90, 90, 90];  % angle filter [Degree]
matches = zeros(m, 1);

% Finding matches within tolerance 0.0333 (3/90), which translates to a 3
% degree deviation in any of the angles. After looking at all angles in
% allAngles, some tetragonal or orthorhombic structures aren't exactly [90,
% 90, 90]
% """
% Two values, u and v, are within tolerance if 
% abs(u-v) <= tol*max(abs([A(:);B(:)])).
% """
for i = 1:m
    matches(i) = ismembertol(angleMatch, allInfo(i, 5:7), 0.0333, 'ByRows', true);
end

nonMatchLoc = find(~matches);  % find the zeolites that did not match

% Remove zeolites that do not have 90 degree angles
orthoInfo = allInfo;
orthoInfo(nonMatchLoc, :) = [];
orthoZeolites = allZeolites;
orthoZeolites(nonMatchLoc, :) = [];

end