% --- Load image ---
img = im2double(imread("C:\Users\LENOVO\OneDrive\Desktop\download (4).jpeg"));
[h, w, ~] = size(img);

% --- Preprocess ---
I = imgaussfilt(rgb2gray(img), 1);
G = imgradient(I);

% --- Fixed colors (max 6 regions) ---
fixedColors = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0];

% --- Number of regions (command window input) ---
numRegions = input('Enter the number of regions (1–6): ');
if isempty(numRegions) || numRegions < 1 || numRegions > 6
    error('Please enter a number between 1 and 6');
end

% --- Interactive marker drawing ---
figure, imshow(img), title('Draw ROI markers (double-click to finish each)');
markerMask = zeros(h, w, 'uint16');
for id = 1:numRegions
    fprintf('Now draw marker %d...\n', id);   % marker number only in command window
    roi = drawfreehand('Color', fixedColors(id,:), 'FaceAlpha', 0.2, 'LineWidth', 1.5);
    markerMask(createMask(roi)) = id;
end

% --- Show user markers ---
figure, imshow(label2rgb(markerMask, fixedColors(1:numRegions,:), 'w'));
title('User Markers');

% --- Watershed segmentation ---
G2 = imimposemin(G, markerMask > 0);
L = watershed(G2);

% --- Assign watershed regions to nearest marker ---
assignedMap = zeros(h, w, 'uint16');
for lab = setdiff(unique(L),0)'   % loop over watershed basins
    pix = (L == lab);
    vals = markerMask(pix);
    if any(vals)
        assignedMap(pix) = mode(vals(vals>0));
    end 
end

% Fill unassigned pixels
if any(assignedMap(:)==0)
    [~, idx] = bwdist(markerMask > 0);
    assignedMap(assignedMap==0) = markerMask(idx(assignedMap==0));
end

% --- Build segmentation overlay ---
segRGB = label2rgb(assignedMap, fixedColors(1:numRegions,:), 'w');
overlay = 0.6*img + 0.4*im2double(segRGB);
overlay(repmat(L==0,[1 1 3])) = 1;  % white boundaries

% --- Show final segmentation ---
figure, imshow(overlay), title('Final Watershed Segmentation');


