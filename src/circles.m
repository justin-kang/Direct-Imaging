function[centers] = circles(images, radius, varargin)
% how wide to expect the star's flux to go
WINDOW = radius * 4;
% the file we will be writing the centers to
file = [];
if length(varargin) > 1
    file = fopen('src/star_centers.txt', varargin{4});
end
% the matrix of centers
centers = zeros(size(images,2),2);
for i = 1:size(images,2)
    img = images{i};
    % get the center of the coronagraphs from the images
    center = detectCircles(img, radius);
    % just use the center if don't need to get weighted centroid
    if ~isempty(varargin)
        centers(i,:) = center;
        continue;
    end
    % correct the center using weighted centroid
    % make a window around the star
    r_min = center(1,1) - WINDOW;
    r_max = center(1,1) + WINDOW;
    c_min = center(1,2) - WINDOW;
    c_max = center(1,2) + WINDOW;
    if r_min < 1
        r_min = 1; 
    end
    if r_max > size(img,1)
        r_max = size(img,1); 
    end
    if c_min < 1
        c_min = 1; 
    end
    if c_max > size(img,2)
        c_max = size(img,2);
    end
    % get the patch of just the star from the image
    img_patch = img(r_min:r_max,c_min:c_max);
    % find the center by calculating the weighted centroid
    [r_sum, r_flux, c_sum, c_flux] = deal(uint64(0));
    for r = 1:size(img_patch,1)
        for c = 1:size(img_patch,2)
            r_sum = r_sum + img_patch(r,c) * r;
            r_flux = r_flux + img_patch(r,c);
            c_sum = c_sum + img_patch(r,c) * c;
            c_flux = c_flux + img_patch(r,c);
        end
    end
    r_cen = round(r_sum / r_flux) + r_min;
    c_cen = round(c_sum / c_flux) + c_min;
    % copy the center to the matrix
    centers(i,:) = [r_cen, c_cen];
    % print out the center to the file
    if length(varargin) > 1
        dirs = varargin{2};
        img_path = varargin{3};
        fprintf(file,'"%s%s" %u %u %u', dirs, img_path(i).name, r_cen, c_cen);
        fprintf(file, '\n');
    end
end
if length(varargin) > 1
    fclose(file);
end
end