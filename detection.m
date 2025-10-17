 
% edgedetection 
tiledlayout(2,4);

BW = imread("C:\Users\LENOVO\OneDrive\Desktop\images.jpeg");
nexttile
plot(1,1)
imshow(BW); title("Original Image");
 BW1 = rgb2gray(BW);
nexttile
plot(1,2)
imshow(BW1); title("Gray Scale Image");
 img = BW1;
 grayth1 = graythresh(img);
%canny
img_canny = edge(img,"canny",0.4,0.5);
nexttile
plot(1,3)
imshow(img_canny); title("Canny Edge Image");

%sobel
img_sobelx = edge(img,"sobel");
nexttile
plot(1,4)
imshow(img_sobelx); title("Sobel Edge Image");
%prewitt

img_prewitt = edge(img,"prewitt");
nexttile
plot(2,1)
imshow(img_prewitt); title("Prewitt Edge Image");

% Roberts

roberts1 = edge(img,"roberts");
nexttile
plot(2,2)
imshow(roberts1); title("Roberts Edge Image");


% LoG (Laplacian of Gaussian)

log1 = edge(img,"log");
nexttile
plot(2,3)
imshow(log1); title("Log Edge Image");

% Zero Cross

zerocross1 = edge(img,"zerocross");
nexttile
plot(2,4)
imshow(zerocross1); title("Zerocross Edge Image");
