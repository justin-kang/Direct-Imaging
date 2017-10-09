function[sum_image, median_image] = imreg_ang(images, RADIUS, p_angles)
%Register all images while aligning by angle (north) and produce the sum
%and median images of the stack
[im_rows, im_cols] = size(images{1});
% account for increased size when rotating
im_rows = im_rows * 2 - 1;
im_cols = im_cols * 2 - 1;
% the stack of rotated images
images_rot = cell(1,size(images,2));
for i = 1:size(images,2)
    images_rot{i} = imrotate(images{i}, p_angles(i));
end
centers = circles(images_rot, RADIUS, '', '', 0);
% the image stack of to-be-registered rotated images. NaN is used for values 
% the original image didn't have
image_stack = NaN(im_rows, im_cols, size(images,2));
for i = 1:size(images,2)
    % register the rotated image onto the image stack
    img = images_rot{i};
    r = ceil(size(image_stack,1)/2 - centers(i,1));
    c = ceil(size(image_stack,2)/2 - centers(i,2));
    image_stack(1+r:size(img,1)+r,1+c:size(img,2)+c,i) = img;
end
% take the sum to create an image, then set remaining nan to 0
sum_image = sum(image_stack, 3, 'omitnan');
sum_image(isnan(sum_image)) = 0;
% take the median to create an image, then set remaining nan to 0
median_image = median(image_stack, 3, 'omitnan');
median_image(isnan(median_image)) = 0;
end