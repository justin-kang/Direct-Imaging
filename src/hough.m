function[H] = hough(im, radius)
%hough Performs the Hough transform for a given image and radius
%   Uses the Hough transform to create an accumulator array (Hough space)
%   given an input image and radius. <usegrad> allows for the choice of
%   getting the angle from the gradient of the image, rather than going
%   through a set of discretized thetas.
% initialize the hough space
H = zeros(size(im,1),size(im,2));
% find the edge pixels from the image
[r,c] = find(edge(im, 'Canny', [.35,.45]) > 0);
thetas = 0:0.001:2*pi;
% increment the accumulator
for i = 1:size(r)
    % go through the discretized values of theta
    for j = 1:numel(thetas)
        a = round(c(i) + radius * cos(thetas(j)));
        b = round(r(i) - radius * sin(thetas(j)));
        if a <= size(H,2) && a >= 1 && b <= size(H,1) && b >= 1
            H(b,a) = H(b,a) + 1;
        end
    end
end
end