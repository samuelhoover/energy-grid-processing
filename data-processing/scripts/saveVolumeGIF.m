function [] = saveVolumeGIF(volume, path, numViewPoints)

% saveVoluemGIF creates a .gif file of a volume visualization.
%
% Inputs:
%   volume        - `volshow` output
%   path          - string array for path and filename to save GIF
%   numViewPoints - number of viewing points

% Assuming 360 degree viewing is wanted
vec = linspace(0, 2 * pi(), numViewPoints)';  % number of view points
myPosition = 5 * [cos(vec), sin(vec), zeros(size(vec))];  % camera position
for idx = 1:numViewPoints
    % Update current view
    volume.CameraPosition = myPosition(idx, :);
    % Use getframe to capture image
    I = getframe(gcf);
    [indI, cm] = rgb2ind(I.cdata, 256);
    % Write frame to the GIF File
    if idx == 1
        imwrite(indI, cm, path, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(indI, cm, path, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end