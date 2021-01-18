clear, clc, close all


%% Load the dataset

%%%%%%%%%%%%%%%%%%%%%%
%%% ENERGY IS IN K %%%
%%%%%%%%%%%%%%%%%%%%%%

zeo_name = 'ATN-1.h5';
zeo_file = strcat('../Data/Zeolites/HDF5 Files/Real zeolites/', zeo_name);
h5disp(zeo_file)  % reading HDF5 file info
dset = h5read(zeo_file, '/CH4');  % load HDF5 'CH4' dataset

% Set Overlap_Value instances to upper energy limit
upperLimit = 1E20;
dset(dset >= 1E20) = upperLimit;

%% Preprocess the dataset

% Capping large values (consistent to Kim et. al in ESGAN/ZeoGAN 
% pre-processing)
dset_capped = dset;
dset_capped(dset_capped >= upperLimit) = upperLimit;

% Forcing slice data into 2-D matrix
[a, b, c] = size(dset);
slice = reshape(dset(1, :, :), [b, c]);

% Capping large values (arbitrarily selected capped value)
slice_capped = reshape(dset_capped(1, :, :), [b, c]);

% Normalizing data
sliceMin = min(slice_capped, [], 'all');
sliceMax = max(slice_capped, [], 'all');
dsetMin = min(dset_capped, [], 'all');
dsetMax = max(dset_capped, [], 'all');
slice_norm = 1 - ((slice_capped - sliceMin) / (sliceMax - sliceMin));
dset_norm = 1 - ((dset_capped - dsetMin) / (dsetMax - dsetMin));

% create mesh grid in which to assign energy values to
[X, Y] = meshgrid(0:0.2:(c - 1) / 5, 0:0.2:(b - 1) / 5);


%% Visualize multiple slices of raw data

figure(1)
for i = 1:9
    subplot(3, 3, i)
    contour(reshape(dset(i, :, :), [b, c]))
    colorbar
    pbaspect([c, b, 1])
    title(['Slice #', num2str(i), ''])
end


%% Visualize multiple slices of capped data

figure(2)
for i = 1:9
    subplot(3, 3, i)
    contour(reshape(dset_capped(i, :, :), [b, c]))
    colorbar
    pbaspect([c, b, 1])
    title(['Slice #', num2str(i), ''])
end


%% Visualize multiple slices of normalized data

figure(3)
sgtitle('Normalized data, [Min, Max] \rightarrow [1, 0]')
for i = 1:9
    subplot(3, 3, i)
    contourf(reshape(dset_norm(i, :, :), [b, c]))
    colorbar
    pbaspect([c, b, 1])
    title(['Slice #', num2str(i), ''])
end


%% Visualize different representations

figure(4)
% set(gcf, 'visible', 'off')
subplot(1, 3, 1)
mesh(X, Y, slice)
title('Raw energy data')
subplot(1, 3, 2)
mesh(X, Y, slice_capped)
title('Capped energy data')
subplot(1, 3, 3)
mesh(X, Y, slice_norm)
title('Normalized energy data')


%% Translate unit cell slice

randX = randi(c);  % magnitude of translation in X direction
randY = randi(b);  % magnitude of translation in Y direction

slice_norm_T = slice_norm;
slice_norm_T = cat(2, slice_norm_T(:, randX + 1:end), slice_norm_T(:, 1:randX));  % translate in horizontal direction
slice_norm_T = cat(1, slice_norm_T(randY + 1:end, :), slice_norm_T(1:randY, :));  % translate in vertical direction

figure
contourf(slice_norm)  % original
figure
contourf(slice_norm_T)  % translated


%% Translate unit cell volume

dset_norm_T = translateCell(dset_norm);

figure
volshow(dset_norm)
figure
volshow(dset_norm_T)


%% Rotate unit cell slice

randPos = randi(2);

positions = [1, 2;
            2, 1];
        
slice_norm_R = slice_norm;
slice_norm_R = permute(slice_norm_R, positions(randPos, :));

figure
contourf(slice_norm)
figure
contourf(slice_norm_R)


%% Rotate unit cell volume

dset_norm_R = rotateCell(dset_norm);

figure
volshow(dset_norm)
figure
volshow(dset_norm_R)
         

%% Segment data using thresholding
% Threshold data and use logical results
% 1 = accessible, 0 = inaccessible

mask_slice = slice < upperLimit;
figure(8)
imshow(mask_slice)

mask_vol = dset < upperLimit;
figure(9)
volshow(mask_vol);


%% Create disjoint sets from segmented data
Use bwlabeln to create disjoint sets from binarized energy data

% bwlabeln returns label matrix 'L' and number of connnected objects 'n'
% *** will need to think further about # of connectivities specified ***
for conn = [6, 18, 26]
    [L, n] = bwlabeln(mask_vol, conn);
    
    % compare results from label matrix to thresholded data
    if isequal(mask_vol, L)
     fprintf('conn = %i --> n = %i, BW3 == L\n', conn, n)
    else
     fprintf('conn = %i --> n = %i, BW3 =/= L\n', conn, n)
    end
end

% % % % connectivity matrix with simplest connectivity
% % % [L6, ~] = bwlabeln(mask_vol, 6);
% % % figure(10)
% % % h = volshow(L6);


%% Create supercell

[l, h, w] = size(mask_vol);

% starting in 2D - perform periodic padding
% create 3x3 repeated matrix of mask_slice
rep_slice = repmat(mask_slice, 3);
% remove outer quarter of repeated matrix
super_img = rep_slice(floor(0.5 * h) + 1 : ceil(2.5 * h), ...
                      floor(0.5 * w) + 1 : ceil(2.5 * w));

% using simplest connectivity, find all objects
[L_img, n_img] = bwlabeln(super_img, 6);

% color n_img number of objects
% each color represents a different object
cmap = jet(n_img);
jetind = ind2rgb(L_img, cmap);
seg_img = jetind .* super_img;  % set background to black

figure(11)
imshow(seg_img)


% now in 3D
rep_vol = repmat(mask_vol, [3, 3, 3]);
super_vol = rep_vol(floor(0.5 * l) + 1 : ceil(2.5 * l), ...
                    floor(0.5 * h) + 1 : ceil(2.5 * h), ...
                    floor(0.5 * w) + 1 : ceil(2.5 * w));

% using simplest connectivity, find all objects
[L_vol, n_vol] = bwlabeln(super_vol, 6);

% color n_vol number of objects
% cmap = jet(n_vol);
% jetind = ind2rgb(L_vol, cmap);
% seg_vol = jetind .* super_vol;  % set background to black

figure(12)
volshow(L_vol)

