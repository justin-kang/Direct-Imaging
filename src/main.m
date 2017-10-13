% AST 381 Project 2
import matlab.io.*
% set up pathing for our images
path_12 = 'img/ROXs12 calibrated/';
path_42b = 'img/ROXs42b calibrated/';
DIR_12 = dir(fullfile(path_12, '*.fits'));
DIR_42b = dir(fullfile(path_42b, '*.fits'));
dirs_12 = cell(1,length(DIR_12));
dirs_42b = cell(1, length(DIR_42b));
% radius of the coronagraphs
RADIUS = 15;
% all of the images
imgs_12 = cell(1, length(DIR_12));
imgs_42b = cell(1, length(DIR_42b));
% position angles of the stars, obtained from FITS headers
pangles_12 = zeros(1, length(DIR_12));
pangles_42b = zeros(1, length(DIR_42b));
% the gain TODO: should be obtained from FITS header
GAIN = 4;
% read in the images and metadata
for i = 1:length(DIR_12)
    img = GAIN * fitsread(fullfile(path_12, DIR_12(i).name), 'Primary');
    img(img<0) = 0;
    imgs_12{i} = img;
    file = fits.openFile(fullfile(path_12, DIR_12(i).name));
    [parang, ~] = fits.readKey(file, 'PARANG');
    [rotpposn, ~] = fits.readKey(file, 'ROTPPOSN');
    [el, ~] = fits.readKey(file, 'EL');
    [instangl, ~] = fits.readKey(file, 'INSTANGL');
    pangles_12(i) = str2double(parang) + str2double(rotpposn) - ...
        str2double(el) - str2double(instangl);
    fits.closeFile(file);
end
for i = 1:length(DIR_42b)
    img = GAIN * fitsread(fullfile(path_42b, DIR_42b(i).name), 'Primary');
    img(img<0) = 0;
    imgs_42b{i} = img;
    file = fits.openFile(fullfile(path_42b, DIR_42b(i).name));
    [parang, ~] = fits.readKey(file, 'PARANG');
    [rotpposn, ~] = fits.readKey(file, 'ROTPPOSN');
    [el, ~] = fits.readKey(file, 'EL');
    [instangl, ~] = fits.readKey(file, 'INSTANGL');
    pangles_42b(i) = str2double(parang) + str2double(rotpposn) - ...
        str2double(el) - str2double(instangl);
    fits.closeFile(file);
end

% get the coordinates of the center of the star for each image
centers_12 = circles(imgs_12, RADIUS, 1);%, path_12, DIR_12, 'w');
centers_42b = circles(imgs_42b, RADIUS, 1);%, path_42b, DIR_42b, 'a');

% register each image and produce the sum and median images
% show the sqrt to make the planet's presence more obvious
%%{
[reg_12, ~] = imRegister(imgs_12, centers_12);
[sum_12, median_12] = combineImgs(reg_12);
%{
figure('Name','Summed ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12));
figure('Name','Median ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12));
%}
[reg_42b, ~] = imRegister(imgs_42b, centers_42b);
[sum_42b, median_42b] = combineImgs(reg_42b);
%{
figure('Name','Summed ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b));
figure('Name','Median ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b));
%}
%%}

% register each image (including angle) and produce the sum and median images
% show the sqrt to make the planet's presence more obvious
%%{
[reg_12_rot, centers_12_ang] = imRegisterAng(imgs_12, RADIUS, pangles_12);
[sum_12_ang, median_12_ang] = combineImgs(reg_12_rot);
%{
figure('Name','Rotated Summed ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12_ang));
figure('Name','Rotated Median ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12_ang));
%}
[reg_42b_rot, centers_42b_ang] = imRegisterAng(imgs_42b, RADIUS, pangles_42b);
[sum_42b_ang, median_42b_ang] = combineImgs(regs_42b_rot);
%{
figure('Name','Summed Rotated ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b_ang));
figure('Name','Median Rotated ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b_ang));
%}
%%}

% calculate the brightness profile as a function of distance from star
% and subtract it off each image, returning both registered stacks
%%{
sub_12 = brightness(imgs_12, centers_12);
[reg_12_sub, centers_12_sub] = imRegister(sub_12, centers_12);
[sum_12_sub, median_12_sub] = combineImgs(reg_12_sub);
%{
figure('Name','Summed Subtracted ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12_sub));
figure('Name','Median Subtracted ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12_sub));
%}
[reg_12_sub_ang, centers_12_sub_ang] = ...
    imRegisterAng(sub_12, RADIUS, pangles_12);
[sum_12_sub_ang, median_12_sub_ang] = combineImgs(reg_12_sub_ang);
%{
figure('Name','Summed Rotated Subtracted ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12_sub_ang));
figure('Name','Median Rotated Subtracted ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12_sub_ang));
%}
sub_42b = brightness(imgs_42b, centers_42b);
[reg_42b_sub, centers_42b_sub] = imRegister(sub_42b, centers_42b);
[sum_42b_sub, median_42b_sub] = combineImgs(reg_42b_sub);
%{
figure('Name','Summed Subtracted ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b_sub));
figure('Name','Median Subtracted ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b_sub));
%}
[reg_42b_sub_ang, centers_42b_sub_ang] = ...
    imRegisterAng(sub_42b, RADIUS, pangles_42b);
[sum_42b_sub_ang, median_42b_sub_ang] = combineImgs(reg_42b_sub_ang);
%{
figure('Name','Summed Rotated Subtracted ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b_sub_ang));
figure('Name','Median Rotated Subtracted ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b_sub_ang));
%}
%%}
   
% for each image, subtract off the median-combined image of PSF (part 3), 
% then rotated-register and stack them
%%{
[adi_12, centers_12_adi] = adi(imgs_12, centers_12, RADIUS, median_12);
[reg_12_adi, centers_12_adi] = ...
    imRegisterAng(adi_12, RADIUS, pangles_12, centers_12_adi);
[sum_12_adi, median_12_adi] = combineImgs(reg_12_adi);
%{
figure('Name','Summed Rotated ADI ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12_adi));
figure('Name','Median Rotated ADI ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12_adi));
%}
[adi_42b, centers_42b_adi] = adi(imgs_42b, centers_42b, RADIUS, median_42b);
[reg_42b_adi, centers_42b_adi] = ...
    imRegisterAng(adi_42b, RADIUS, pangles_42b, centers_42b_adi);
[sum_42b_adi, median_42b_adi] = combineImgs(reg_42b_adi);
%{
figure('Name','Summed Rotated ADI ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b_adi));
figure('Name','Median Rotated ADI ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b_adi));
%}
%%}

% for each image, compare with all images of the other star, find the most 
% similar PSF and subtract it off, then rotated-register and stack them
[psf_12, centers_12_psf] = comparePsf(imgs_12, imgs_42b, RADIUS, ...
    centers_12, centers_42b);%, path_12, DIR_12, path_42b, DIR_42b, 'w');
[reg_12_psf, centers_12_psf] = ...
    imRegisterAng(psf_12, RADIUS, pangles_12, centers_12_psf);
[sum_12_psf, median_12_psf] = combineImgs(reg_12_psf);
%{
figure('Name','Summed Rotated PSF ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_12_psf));
figure('Name','Median Rotated PSF ROXs 12','NumberTitle','off');
colormap gray
imagesc(sqrt(median_12_psf));
%}
[psf_42b, centers_42b_psf] = comparePsf(imgs_42b, imgs_12, RADIUS, ...
    centers_42b, centers_12);%, path_42b, DIR_42b, path_12, DIR_12, 'a');
[reg_42b_psf, centers_42b_psf] = ...
    imRegisterAng(psf_42b, RADIUS, pangles_12, centers_42b_psf);
[sum_42b_psf, median_42b_psf] = combineImgs(reg_42b_psf);
%{
figure('Name','Summed Rotated PSF ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(sum_42b_psf));
figure('Name','Median Rotated PSF ROXs 42B','NumberTitle','off');
colormap gray
imagesc(sqrt(median_42b_psf));
%}
   
% for each median image, find real objects and find the position angle and
% projected separation for each object
% number of arcseconds/pixel on NIRC2 TODO: read from fits file
SCALE = 0.009952;
medians_12 = {median_12_ang, median_12_sub, median_12_sub_ang, ...
    median_12_adi, median_12_psf};
centers_12_med = {centers_12_ang, centers_12_sub, centers_12_sub_ang, ...
    centers_12_adi, centers_12_psf};
% get the centers of planets graphically because Hough isn't working TODO
for i = 1:length(medians_12)
    figure
    colormap gray
    imagesc(sqrt(medians_12{i}));
end

medians_42b = {median_42b_ang, median_42b_sub, median_42b_sub_ang, ...
    median_42b_adi, median_42b_psf};
centers_42b_med = {centers_42b_ang, centers_42b_sub, centers_42b_sub_ang, ...
    centers_42b_adi, centers_42b_psf};
% get the centers of planets graphically because Hough isn't working TODO
for i = 1:length(medians_42b)
    figure
    colormap gray
    imagesc(sqrt(medians_42b{i}));
end
% TODO: get center of star, weighted center of planet, use to calculate PA
% and projected separation
