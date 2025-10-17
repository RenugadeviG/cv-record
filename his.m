% Read and convert to grayscale
img = imread("C:\Users\LENOVO\OneDrive\Desktop\images (1).jpeg");
if size(img,3)==3, img = rgb2gray(img); end

% Resize to 50%
img = imresize(img, 0.5);
fprintf('Resized Dimensions: %dx%d\n', size(img,1), size(img,2));
figure; imshow(img); title('Resized Image');

% Histogram Equalization
eq_img = histeq(img);
imwrite([img eq_img], 'Histo1_res.png');
figure; imshow([img eq_img]); title('Original and Equalized Image');
% Histogram & CDF

[h,~] = imhist(img); cdf = cumsum(h); cdf_norm = cdf*max(h)/max(cdf);
figure; 
yyaxis left, bar(h,'r'); ylabel('Histogram');
yyaxis right, plot(cdf_norm,'b','LineWidth',1.5); ylabel('CDF');
xlim([0 256]); xlabel('Intensity'); legend('Histogram','CDF'); title('Histogram & CDF');
saveas(gcf,'histo2_cdf.png');

% Display saved results
figure;
subplot(1,2,1); imshow(imread('Histo1_res.png')); title('Original & Equalized');
subplot(1,2,2); imshow(imread('histo2_cdf.png')); title('CDF & Histogram');
