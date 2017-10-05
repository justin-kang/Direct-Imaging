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
    p_angles(1, i) = str2double(parang) + str2double(rotpposn) - ...
        str2double(el) - str2double(instangl);
    fits.closeFile(file);
end

% get the coordinates of the center of the star for each image
centers = circles(images, RADIUS, dirs, img_path, 0);

% register each image and produce the sum and median images
[sum_image, median_image] = imreg(images, centers);
%%{
figure(1)
%colormap gray
imagesc(sum_image);
figure(2)
%colormap gray
imagesc(median_image);
%%}

% register each image (including angle) and produce the sum and median images
%[sum_image_rot, median_image_rot] = imreg_ang(images, centers, p_angles);
%{
figure(3)
colormap gray
imagesc(sum_image_rot);
figure(4)
colormap gray
imagesc(median_image_rot);
%}