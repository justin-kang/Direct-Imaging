function[registered, stack_center] = imRegister(images, centers)
%register all images
% get the maximum offset in center
r_min = min(centers(:,1));
r_max = max(centers(:,1));
c_min = min(centers(:,2));
c_max = max(centers(:,2));
r_off = r_max - r_min;
c_off = c_max - c_min;
% the image stack of to-be-registered images. NaN is used for values the 
% original image didn't have
[im_rows, im_cols] = size(images{1});
registered = NaN(im_rows + r_off, im_cols + c_off, size(images,2));
for i = 1:size(images,2)
    % register the image onto the image stack
    r_dif = r_max - centers(i,1);
    c_dif = c_max - centers(i,2);
    registered(1+r_dif:r_dif+size(images{i},1), ...
        1+c_dif:c_dif+size(images{i},2),i) = images{i};
end
stack_center = [r_max, c_max];
end