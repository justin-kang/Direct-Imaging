function[imgs] = brightness(images, centers)
% Calculates brightness profile as a function of distance from star,
% subtracts off each image, returns the subtracted stack
thetas = 0:0.001:2*pi;
% the stack of to-be-subtracted images
imgs = zeros(size(images{1},1),size(images{1},2),size(images,2));
% loop through all the images
for i = 1:size(images,3)
    image = images{i};
    center = centers(i,:);
    radius_max = max(size(image,1),size(image,2));
    % loop through all radii, subtracting the median brightness at each radius
    for radius = 0:radius_max
        r = (round(radius * sin(thetas) + center(1)))';
        c = (round(radius * cos(thetas) + center(2)))';
        circle = unique([r,c], 'rows');
        % make sure the circle is inside the image
        circle = circle(circle(:,1) >= 1,:);
        circle = circle(circle(:,1) <= size(image,1),:);
        circle = circle(circle(:,2) >= 1,:);
        circle = circle(circle(:,2) <= size(image,2),:);
        % if no circles are inside this range there won't be any more in
        % the future, so break out
        if size(circle,1) == 0
            break;
        end
        % get the nonzero median intensity for all the pixels in the circle
        intensities = zeros(1,size(circle,1));
        for j = 1:size(circle,1)
            row = circle(j,1);
            col = circle(j,2);
            intensities(j) = image(row, col);
        end
        % subtract off the median intensity from each of the pixels
        if ~isempty(intensities)
            val = median(intensities);
            for j = 1:size(circle,1)
                row = circle(j,1);
                col = circle(j,2);
                image(row,col) = max(0,image(row,col)-val);
            end
        end
    end
    imgs(:,:,i) = image;
end
end