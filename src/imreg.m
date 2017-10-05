function[sum_image, median_image] = imreg(images, centers)
% get the maximum offset in center
r_min = min(centers(:,1));
r_max = max(centers(:,1));
c_min = min(centers(:,2));
c_max = max(centers(:,2));
r_off = r_max - r_min;
c_off = c_max - c_min;
% produce a 3d image stack of registered images (aligned about a point). use 
% NaN to account for pixels that the original image didn't have
[im_rows, im_cols] = size(images{1});
image_stack = NaN(im_rows + r_off, im_cols + c_off, size(images,2));
for i = 1:size(images,2)
    r_dif = r_max - centers(i,1);
    c_dif = c_max - centers(i,2);
    image_stack(1+r_dif:r_dif+im_rows,1+c_dif:c_dif+im_cols,i) = images{i};
end
% take the sum of each pixel to create an image, then set remaining nan to 0
sum_image = sum(image_stack, 3, 'omitnan');
sum_image(isnan(sum_image)) = 0;
% take the median to create an image, then set remaining nan to 0
median_image = median(image_stack, 3, 'omitnan');
median_image(isnan(median_image)) = 0;
end