%% Load data
% Energy structure data from HDF5 files
load ../Data/Zeolites/'Unprocessed Data'/realZeolites.mat
zeos = keys(M);

% Some IZA structures from PB screening work
table = readtable('../Data/Zeolites/PB Screening/HC-IZASC.txt', 'Delimiter', ' ');
IZA_SC = table.IZA_SC;  % structure names

%% Find which structures from filtered list are in HC_IZASC.txt and extract Henry's constant data
% Find index (Locb) in zeos of structures that are in table
[Lia, Locb] = ismember(IZA_SC, zeos);  % location in a i.e. IZA_SC
Locb = nonzeros(Locb);                 % location in b i.e. zeos
similarZeos = IZA_SC(Lia);             % get similar zeolite structures
m = length(Locb);                      % number of similar stuctures

%% Get angles of structures in PB screening and find orthogonal structures
angles = zeros(m, 3);
matches = false(m, 1);
for i = 1:m
    zeoFile = strcat(similarZeos{i}, '.h5');
    angle = (180 / pi) * h5readatt(strcat('../Data/Zeolites/HDF5 Files/Real Zeolites/', zeoFile), '/CH4', 'cell_angle')';
    matches(i) = ismembertol([90, 90, 90], angle, 0.0333, 'ByRows', true);
    angles(i, :) = angle;
end
orthoZeos = similarZeos(matches);

%% Visualize non-orthogonal zeolite structures in PB screening
nonOrthoZeos = similarZeos(~matches);
idx = randi(length(nonOrthoZeos));
nonOrthoZeos{idx}
dataset = inverseNormalizeData(M(nonOrthoZeos{idx}), 8E4);
figure;
volshow(dataset);

%% Save non-orthogonal zeolite structures in PB screening for viewing
for i = 1:length(nonOrthoZeos)
    dset = inverseNormalizeData(M(nonOrthoZeos{i}), 8E4);
    path = strcat('../Data/Zeolites/Gifs/Non-orthogonal/', nonOrthoZeos{i}, '.gif');
    vol = volshow(dset);
    saveVolumeGIF(vol, path, 180)
    close gcf
end
    