clear, clc, close all

%% Load the dataset

%%%%%%%%%%%%%%%%%%%%%%
%%% ENERGY IS IN K %%%
%%%%%%%%%%%%%%%%%%%%%%

zeo_name = 'ATN-1.h5';
zeo_file = strcat('HDF5 Files/Real zeolites/', zeo_name);
h5disp(zeo_file)  % reading HDF5 file info
dset = h5read(zeo_file, '/CH4');  % load HDF5 'CH4' dataset
cell_length = h5readatt(zeo_file, '/CH4', 'cell_length');  % unit cell lengths
cell_angle = h5readatt(zeo_file, '/CH4', 'cell_angle');  % unit cell angles
fprintf('Cell length = \n')
disp(cell_length)
fprintf('Cell angle = \n')
disp(cell_angle * 180 / pi)

% Throw away Overlap_Value values
upperLimit = 10000;
dset(dset >= 1E20) = upperLimit;

% Capping large values (arbitrarily selected capped value)
dset_thresh = dset;
dset_thresh(dset_thresh > upperLimit) = upperLimit;

% Forcing slice data into 2-D matrix
[a, b, c] = size(dset);
slice = reshape(dset(1, :, :), [b, c]);

[X, Y] = meshgrid(0:0.2:(c - 1) / 5, 0:0.2:(b - 1) / 5);

% Capping large values (arbitrarily selected capped value)
slice_thresh = slice;
slice_thresh(slice_thresh > upperLimit) = upperLimit;

% Normalizing data
slice_norm = normalize(slice);

%% Visualize multiple slices of data

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
    contour(reshape(dset_thresh(i, :, :), [b, c]))
    colorbar
    pbaspect([c, b, 1])
    title(['Slice #', num2str(i), ''])
end

%% Visualize different representations

figure(3)
% set(gcf, 'visible', 'off')
subplot(1, 3, 1)
mesh(X, Y, slice)
title('Raw energy data')
subplot(1, 3, 2)
mesh(X, Y, slice_thresh)
title('Thresholded energy data')
subplot(1, 3, 3)
mesh(X, Y, slice_norm)
title('Normalized energy data')

%% Perform edge detection
% Performing edge detection to segment accessible space from inaccessible
% space

% Edge detection to create binary image (Sobel is default method)
BW_raw_Sobel = edge(slice);
BW_thresh_Sobel = edge(slice_thresh);
BW_norm_Sobel = edge(slice_norm);

% visualize edge detection results
figure(4)
% set(gcf, 'visible', 'off')
subplot(1, 3, 1)
imshow(BW_raw_Sobel)
title('Raw energy data')
subplot(1, 3, 2)
imshow(BW_thresh_Sobel)
title('Thresholded large energy data')
subplot(1, 3, 3)
imshow(BW_norm_Sobel)
title('Normalized energy data')
sgtitle('Sobel edge detection method')

%%% WILL USE THRESHOLDED DATA FROM NOW ON %%%

% try different edge detection methods
BW_Prewitt = edge(slice_thresh, 'Prewitt');
BW_Roberts = edge(slice_thresh, 'Roberts');
BW_log = edge(slice_thresh, 'log');
BW_zerocross = edge(slice_thresh, 'zerocross');
BW_Canny = edge(slice_thresh, 'Canny');
BW_approxcanny = edge(slice_thresh, 'approxcanny');

% visualizing different edge detection methods
figure(5)
% set(gcf, 'visible', 'off')
subplot(3, 3, 2)
imshow(BW_thresh_Sobel)
title('Sobel')
subplot(3, 3, 4)
imshow(BW_Prewitt)
title('Prewitt')
subplot(3, 3, 5)
imshow(BW_Roberts)
title('Roberts')
subplot(3, 3, 6)
imshow(BW_log)
title('log')
subplot(3, 3, 7)
imshow(BW_zerocross)
title('zerocross')
subplot(3, 3, 8)
imshow(BW_Canny)
title('Canny')
subplot(3, 3, 9)
imshow(BW_approxcanny)
title('approxcanny')

% fill Roberts edge detection image
BW_filled_Roberts = imfill(BW_Roberts, 'holes');

% filling in best (to the eye) edge detection method -- Roberts
figure(6)
% set(gcf, 'visible', 'off')
subplot(1, 2, 1)
imshow(BW_Roberts)
title('Unfilled Roberts BW image')
subplot(1, 2, 2)
imshow(BW_filled_Roberts)
title('Filled Roberts BW image')

%% Alternative method to segment data
% Threshold data and use logical results

% compare filled contour plot against binary image
figure(7)
h1 = subplot(1, 2, 1);
contourf(slice_thresh)
pbaspect([1, 1, 1])
colorbar
title('Filled contour')
subplot(1, 2, 2)
imshow(flip(BW_Roberts, 2))
pbaspect([1, 1, 1])
title('Binary image')

mask_slice = slice < upperLimit;
figure(8)
imshow(mask_slice)

mask_vol = dset < upperLimit;
figure(9)
volshow(mask_vol);

%% Create disjoint sets from segmented data
% Use bwlabeln to create disjoint sets from binarized energy data

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

% connectivity matrix with simplest connectivity
[L6, ~] = bwlabeln(mask_vol, 6);
figure(10)
h = volshow(L6);

saveVolumeGIF(h, 'gifs/ATN_1_V2.gif', 120)
% % % 
% % % vec = linspace(0, 2 * pi(), 120)';
% % % % camera position
% % % % *_V1.gif --> myPosition = 0.5*sin(vec)
% % % % *_V2.gif --> myPosition = zeros(size(vec)
% % % myPosition = 5 * [cos(vec), sin(vec), zeros(size(vec))];
% % % for idx = 1:120
% % %     % Update current view
% % %     h.CameraPosition = myPosition(idx, :);
% % %     % Use getframe to capture image
% % %     I = getframe(gcf);
% % %     [indI, cm] = rgb2ind(I.cdata, 256);
% % %     % Write frame to the GIF File
% % %     if idx == 1
% % %         imwrite(indI, cm, 'gifs/ATN_1_V2.gif', 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
% % %     else
% % %         imwrite(indI, cm, 'gifs/ATN_1_V2.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
% % %     end
% % % end

%% Create supercell

[l, h, w] = size(mask_vol);

% starting in 2D
rep_slice = repmat(mask_slice, 3);
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