function[im_stack, im_centers] = adi(images, centers, radius, median_img)
% Angular differential imaging
thetas = 0:0.001:2*pi;
im_stack = cell(1, size(images,2));
center = circles({median_img}, radius);
im_centers = zeros(size(images,2),2);
for i = 1:size(images,2)
    img = images{i};
    % find the intensities of pixel values in a broad ring around the star 
    % (2x the radius of the coronagarph)
    r = (round(2*radius * sin(thetas) + centers(i,1)))';
    c = (round(2*radius * cos(thetas) + centers(i,2)))';
    r_med = (round(2*radius * sin(thetas) + center(1)))';
    c_med = (round(2*radius * cos(thetas) + center(2)))';
    circle = unique([r,c], 'rows');
    circle_med = unique([r_med,c_med], 'rows');
    intensities = zeros(2,size(circle,1));
    for j = 1:size(circle,1)
        row = circle(j,1);
        col = circle(j,2);
        intensities(1,j) = img(row,col);
        row = circle_med(j,1);
        col = circle_med(j,2);
        intensities(2,j) = median_img(row,col);
    end
    % remove where the median has an intensity of 0 to prevent divide-by-0
    intensities(:,intensities(2,:)==0) = [];
    ratio = median(intensities(1,:)./intensities(2,:));
    % register the science frame against the calibrator
    [registered, im_center] = ...
        imRegister({median_img, img}, [center;centers(i,:)]);
    registered(isnan(registered)) = 0;
    new_median = registered(:,:,1);
    img = registered(:,:,2);
    % rescale the calibrator brightness to the science target brightness
    new_median = new_median * ratio;
    im_centers(i,:) = im_center;
    % subtract off the calibrator and add to the image stack
    img = img - new_median;
    img(img < 0) = 0;
    im_stack{i} = img;
end
end