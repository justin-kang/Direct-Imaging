function[sub_stack] = brightness(images, centers)
% Calculates brightness profile as a function of distance from star,
% subtracts off each image, returns the subtracted stack
thetas = 0:0.001:2*pi;
% the stack of to-be-subtracted images
sub_stack = cell(1,size(images,2));
% loop through all the images
for i = 1:size(images,2)
    img = images{i};
    center = centers(i,:);
    radius_max = max(size(img,1),size(img,2));
    % loop through all radii, subtracting the median brightness at each radius
    for radius = 0:radius_max
        r = (round(radius * sin(thetas) + center(1)))';
        c = (round(radius * cos(thetas) + center(2)))';
        circle = unique([r,c], 'rows');
        % remove all rows with an index < 1 (outside of image)
        circle(any(circle<1,2),:) = [];
        % remove all rows with a row greater than number of rows in image
        circle(circle(:,1)>size(img,1),:) = [];
        % remove all rows with a col greater than number of cols in image
        circle(circle(:,2)>size(img,2),:) = [];
        % if no circles are inside this range there won't be any more in
        % the future, so break out
        if size(circle,1) == 0
            break;
        end
        % get the median intensity for all the pixels in the circle
        intensities = zeros(1,size(circle,1));
        for j = 1:size(circle,1)
            row = circle(j,1);
            col = circle(j,2);
            intensities(j) = img(row,col);
        end
        intensities = nonzeros(intensities);
        % subtract off the median intensity from each of the pixels
        if ~isempty(intensities)
            val = median(intensities);
            for j = 1:size(circle,1)
                row = circle(j,1);
                col = circle(j,2);
                img(row,col) = max(0,img(row,col)-val);
            end
        end
    end
    sub_stack{i} = img;
end
end