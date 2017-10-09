% AST 381 Project 2
import matlab.io.*
% set up pathing for our images
path_12 = './img/ROXs12 calibrated/';
path_42b = './img/ROXs42b calibrated/';
DIR_12 = dir(fullfile(path_12, '*.fits'));
DIR_42b = dir(fullfile(path_42b, '*.fits'));
dirs = cell(1,length(DIR_12)+length(DIR_42b));
for i = 1:length(DIR_12)
    dirs{i} = path_12;
end
for i = length(DIR_12)+1:length(DIR_12)+1+length(DIR_42b)
    dirs{i} = path_42b;
end
img_path = [DIR_12; DIR_42b];
% radius of the coronagraphs
RADIUS = 15;
% read in all of the images
images = cell(1, length(img_path));
% position angles of the stars, obtained from FITS headers
p_angles = zeros(1, length(img_path));
for i = 1:length(img_path)
    images{i} = fitsread(fullfile(dirs{i}, img_path(i).name), 'Primary');
    file = fits.openFile(fullfile(dirs{i},img_path(i).name));
    [parang, ~] = fits.readKey(file, 'PARANG');
    [rotpposn, ~] = fits.readKey(file, 'ROTPPOSN');
    [el, ~] = fits.readKey(file, 'EL');
    [instangl, ~] = fits.readKey(file, 'INSTANGL');
    p_angles(i) = str2double(parang) + str2double(rotpposn) - ...
        str2double(el) - str2double(instangl);
    fits.closeFile(file);
end

% get the coordinates of the center of the star for each image
centers = circles(images, RADIUS, dirs, img_path, 0);

% register each image and produce the sum and median images
% show the sqrt to make the planet's presence more obvious
[sum_12, median_12] = imreg(images(1:length(DIR_12)), ...
    centers(1:length(DIR_12),:));
%{
figure('Name','Summed ROXs12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12));
figure('Name','Median ROXs12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12))
%}
[sum_42b, median_42b] = imreg(images(length(DIR_12)+1:end), ...
    centers(length(DIR_12)+1:end,:));
%{
figure('Name','Summed ROXs42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b));
figure('Name','Median ROXs42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b));
%}

% register each image (including angle) and produce the sum and median images
% show the sqrt to make the planet's presence more obvious
[sum_ang_12, median_ang_12] = imreg_ang(images(1:length(DIR_12)), ...
    RADIUS, p_angles);
%{
figure('Name','Rotated Summed ROXs12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_ang_12));
figure('Name','Rotated Median ROXs12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_ang_12))
%}
[sum_ang_42b, median_ang_42b] = imreg_ang(images(length(DIR_12)+1:end), ...
    RADIUS, p_angles);
%{
figure('Name','Rotated Summed ROXs42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_ang_42b));
figure('Name','Rotated Median ROXs42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_ang_42b));
%}

% calculate the brightness profile as a function of distance from star
% (azimuthal median) and subtract it off each image
imgs = brightness(images, centers);

