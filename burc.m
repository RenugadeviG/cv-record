
% Read grayscale images
img1 = imread("C:\Users\LENOVO\OneDrive\Desktop\wimages (4).jpeg");
img2 = imread("C:\Users\LENOVO\OneDrive\Desktop\images (4).jpeg");

if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
if size(img2,3) == 3
    img2 = rgb2gray(img2);
end

% Detect SIFT features
points1 = detectSIFTFeatures(img1);
points2 = detectSIFTFeatures(img2);

% Extract descriptors
[features1, valid_points1] = extractFeatures(img1, points1);
[features2, valid_points2] = extractFeatures(img2, points2);

% Match using Lowe's ratio test with exhaustive search
indexPairs = matchFeatures(features1, features2, ...
                           'Method', 'Exhaustive', ...
                           'MaxRatio', 0.7);

% Retrieve matched points
matchedPoints1 = valid_points1(indexPairs(:,1));
matchedPoints2 = valid_points2(indexPairs(:,2));

% Display matches
figure;
showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
title('Matched SIFT Features using Lowe''s Ratio Test');
