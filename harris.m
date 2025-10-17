% Read image
img = imread("C:\Users\LENOVO\OneDrive\Desktop\download (3).jpeg");
imshow(img);
title('Original Image');

% Convert to grayscale
gray = rgb2gray(img);

% Convert to single precision (float32 equivalent)
gray_float = im2single(gray);

% Harris corner detection
corners = detectHarrisFeatures(gray_float);

% Display the image with corners in red and bold
figure;
imshow(img);
hold on;
strongCorners = corners.selectStrongest(200); % select top 200
plot(strongCorners.Location(:,1), strongCorners.Location(:,2), 'ro', ...
    'MarkerSize', 4, 'LineWidth', 2); % red circles, bold
title('Harris Corner Detection - Red Bold Corners');
