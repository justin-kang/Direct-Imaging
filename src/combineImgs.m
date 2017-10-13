function [sum_img, median_img] = combineImgs(image_stack)
%given a stack of images, return the sum image and median image
% take the sum to create an image, then set remaining nan to 0
sum_img = sum(image_stack, 3, 'omitnan');
sum_img(isnan(sum_img)) = 0;
% take the median to create an image, then set remaining nan to 0
median_img = median(image_stack, 3, 'omitnan');
median_img(isnan(median_img)) = 0;
end

