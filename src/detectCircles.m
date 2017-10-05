function[centers] = detectCircles(im,radius)
%detectBetterCircles a Hough transform circle detector
%   Using input image <im> and <radius>, returns any detected circles of that 
%   size. <usegrad> is a flag to use gradient instead of quantized angles. 
%   <bins> is used to bins the accumulator array. <centers> is an N x 2 matrix 
%   that lists the (x,y) position for each detected circle center.
% constants
bins = 3;
thres = 0.95;
H = hough(im, radius);
% create the bins matrix and gather votes
h = zeros(round(size(H,1)/bins), round(size(H,2)/bins));
for r = 1:size(h,1)
    for c = 1:size(h,2)
        tr = r * bins - (bins-1)/2;
        tc = c * bins - (bins-1)/2;
        window = H(max(1, tr-(bins-1)/2):min(size(H,1), tr+(bins-1)/2), ...
            max(1, tc-(bins-1)/2):min(size(H,2), tc+(bins-1)/2));
        h(r,c) = sum(window(:));
    end
end
% threshold to find candidates for circle centers
threshold = thres * max(h(:));
[row, col] = find(h >= threshold);
% get centers and revert to original (non-binned) coordinate system
centers = horzcat(row,col);
centers = centers * bins - (bins-1)/2;
end