function[registered, stack_center] = imRegisterAng(images, radius, ...
    p_angles, varargin)
%Register all images while aligning by angle (north)
[im_rows, im_cols] = size(images{1});
% account for increased size when rotating
im_rows = im_rows * 2 - 1;
im_cols = im_cols * 2 - 1;
center = [];
if ~isempty(varargin)
    center = varargin{1};
end
centers = zeros(size(images,2),2);
% the stack of rotated images
images_rot = cell(1,size(images,2));
for i = 1:size(images,2)
    images_rot{i} = imrotate(images{i}, p_angles(i));
    % for cases when the images are suppressed, use matrix rotation since 
    % hough might only detect the planet
    if ~isempty(varargin)
        r = round(size(images{i},1)/2 - center(i,1));
        c = round(center(i,2) - size(images{i},2)/2);
        mat = [cosd(p_angles(i)) sind(p_angles(i)); ...
            -sind(p_angles(i)) cosd(p_angles(i))];
        pt = mat*[r c]';
        centers(i,:) = [round(size(images_rot{i},1)/2-pt(1)) ...
            round(size(images_rot{i},2)/2+pt(2))]';
    end
end
% if the coronagraph is clearly defined, use hough
if isempty(varargin)
    centers = circles(images_rot, radius);
end
% the image stack of to-be-registered rotated images. NaN is used for values 
% the original image didn't have
registered = NaN(im_rows, im_cols, size(images,2));
for i = 1:size(images,2)
    % register the rotated image onto the image stack
    img = images_rot{i};
    r = ceil(size(registered,1)/2 - centers(i,1));
    c = ceil(size(registered,2)/2 - centers(i,2));
    registered(1+r:size(img,1)+r,1+c:size(img,2)+c,i) = img;
end
stack_center = [size(registered,1)/2, size(registered,2)/2];
end