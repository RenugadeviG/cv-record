clc; clear; close all;
% Read input image
img = imread("C:\Users\LENOVO\OneDrive\Desktop\images.png");
% Convert to grayscale if needed
if size(img, 3) == 3
    gray_img = rgb2gray(img);
else
    gray_img = img;
end
% Create tiled layo7ut (6 rows x 2 columns = 12 tiles)
tiledlayout(6, 2);
% Display Original Image
nexttile;
imshow(img);
title("Original Image");
% Grayscale Image
nexttile;
imshow(gray_img);
title("Grayscale Image");
% Structuring Element - Line
se_line = strel('line', 11, 90);
% 1. Erosion
eroded = imerode(gray_img, se_line);
nexttile;
imshow(eroded);
title("Erosion");
% 2. Dilation
dilated = imdilate(gray_img, se_line);
nexttile;
imshow(dilated);
title("Dilation");
% 3. Opening
opened = imopen(gray_img, se_line);
nexttile;
imshow(opened);
title("Opening");
% 4. Closing
closed = imclose(gray_img, se_line);
nexttile;
imshow(closed);
title("Closing");
% 5. Gradient
gradient_img = imsubtract(dilated, eroded);
nexttile;
imshow(gradient_img);
title("Gradient");
% 6. Top Hat
tophat_img = imtophat(gray_img, se_line);
nexttile;
imshow(tophat_img);
title("Top Hat");
% 7. Black Hat
blackhat_img = imbothat(gray_img, se_line);
nexttile;
imshow(blackhat_img);
title("Black Hat");
% 8. Rectangular Structuring Element
se_rect = strel('rectangle', [11, 11]);
rect_img = imdilate(gray_img, se_rect);
nexttile;
imshow(rect_img);
title("Rectangular SE");
% 9. Elliptical Structuring Element
se_ellipse = strel('disk', 6);  % Approximates ellipse
ellipse_img = imdilate(gray_img, se_ellipse);
nexttile;
imshow(ellipse_img);
title("Elliptical SE");
% 10. Cross Structuring Element (final tile)
se_cross = strel('arbitrary', [0 1 0; 1 1 1; 0 1 0]);
cross_img = imdilate(gray_img, se_cross);
nexttile;
imshow(cross_img);
title("Cross SE");