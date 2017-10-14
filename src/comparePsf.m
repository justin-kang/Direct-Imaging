function[im_stack, centers] = comparePsf(images, calibrators, radius, ...
    img_centers, cal_centers, varargin)
% Subtracts a calibrator with the most similar PSF
% for a given image, compares to all other images for another sample, finds 
% the image with the most similar PSF, then subtracts it off
% the file we'll be saving the science frames and their best matches to
file = [];
dirs_img = [];
file_img = [];
dirs_cal = [];
file_cal = [];
if ~isempty(varargin)
    file = fopen('src/matches.txt', varargin{5});
    dirs_img = varargin{1};
    file_img = varargin{2};
    dirs_cal = varargin{3};
    file_cal = varargin{4};
end
% the subtracted image stack
im_stack = cell(size(images));
centers = zeros(size(images,2),2);
theta = 0:0.001:2*pi;
% loop through all the images in our stack
for i = 1:size(images,2)
    chi_sq = zeros(size(calibrators))';
    % register the science and all calibrator frames
    [registered, center] = ...
        imRegister([images(i),calibrators], [img_centers(i,:);cal_centers]);
    registered(isnan(registered)) = 0;
    % the registered original image
    img = registered(:,:,1);
    % the differences in the images
    diffs = zeros(size(registered));
    diffs(:,:,1) = [];
    % compares this image with all calibrator images
    for j = 1:size(calibrators,2)
        calibrator = registered(:,:,j+1);
        % find the median ratios in pixel values to rescale the calibrators
        r = (round(2*radius * sin(theta) + center(1)))';
        c = (round(2*radius * cos(theta) + center(2)))';
        circle = unique([r,c], 'rows');
        intensities = zeros(2,size(circle,1));
        for k = 1:size(circle,1)
            row = circle(k,1);
            col = circle(k,2);
            intensities(2,k) = img(row,col);
            intensities(1,k) = calibrator(row,col);
        end
        % remove where the median has an intensity of 0 to prevent divide-by-0
        intensities(:,intensities(2,:)==0) = [];
        ratio = median(intensities(1,:)./intensities(2,:));
        % subtract off and calculate the residual's chi-squared value
        diff = img - calibrator * ratio;
        diffs(:,:,j) = diff;
        chi = (diff .^ 2) ./ img;
        chi_sq(j) = sum(chi(:));
    end
    % use the minimum chi-squared as the best match
    [~, idx] = min(chi_sq);
    temp = diffs(:,:,idx);
    temp(temp<0) = 0;
    im_stack{i} = temp;
    centers(i,:) = center;
    % save the best match
    if ~isempty(varargin)
        fprintf(file, '%s%s matched by %s%s', dirs_img, file_img(i).name, ...
            dirs_cal, file_cal(idx).name);
        fprintf(file, '\n');
    end
end
if ~isempty(varargin)
    fclose(file);
end
end