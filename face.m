clc; clear; close all;
%% ---------- Parameters ----------
imgSize = [64, 64];       % resize images to 64x64
nPCA = 200;               % number of PCA components
nDict = 200;              % number of dictionary atoms
sparsity = 20;            % OMP max non-zero coefficients
nShow = 5;                % number of faces to display
%% ---------- Step 1: Load and preprocess images ----------
url = 'https://www.cl.cam.ac.uk/research/dtg/attarchive/pub/data/att_faces.zip';
zipFile = 'att_faces.zip';
dataFolder = 'att_faces';
if ~exist(dataFolder,'dir')
    if ~exist(zipFile,'file')
        fprintf('Downloading Olivetti Faces dataset...\n');
        websave(zipFile,url);
    end
    unzip(zipFile,dataFolder);
end
% Read and resize images
imageFiles = dir(fullfile(dataFolder,'s*','*.pgm'));
num_samples = length(imageFiles);



X = zeros(num_samples, prod(imgSize));
for i = 1:num_samples
    img = imread(fullfile(imageFiles(i).folder,imageFiles(i).name));
    img = imresize(img, imgSize);          % resize
    X(i,:) = double(img(:))';              % flatten
end
fprintf('Loaded and resized %d images.\n', num_samples);
%% ---------- Step 2: PCA ----------
[coeff, score, ~, ~, ~, mu] = pca(X, 'NumComponents', nPCA);
X_pca = score; % num_samples x nPCA
%% ---------- Step 3: Dictionary Learning (k-means approximation) ----------
[idx, D] = kmeans(X_pca, nDict, 'MaxIter', 500, 'Replicates', 3);
D = D';                       % columns = dictionary atoms
D = D ./ vecnorm(D);           % normalize columns
%% ---------- Step 4: Sparse coding using OMP ----------
X_dict = zeros(nDict, num_samples);
for i = 1:num_samples
    X_dict(:,i) = omp(D, X_pca(i,:)', sparsity);
end
%% ---------- Step 5: Reconstruct images ----------
X_reconstructed_pca = D * X_dict;
X_reconstructed = (X_reconstructed_pca' * coeff') + mu;
%% ---------- Step 6: Display ----------
figure('Name','Olivetti Face Reconstruction','Position',[100 100 1200 400]);
for i = 1:nShow
    % Original
    subplot(2,nShow,i);
    imshow(reshape(X(i,:), imgSize), []);
    title('Original');
    % Reconstructed
    subplot(2,nShow,i+nShow);
    imshow(reshape(X_reconstructed(i,:), imgSize), []);
    title('Reconstructed');
end
%% -------- Helper Function: Orthogonal Matching Pursuit --------
function coef = omp(D, y, sparsity)
    n_atoms = size(D,2);
    coef = zeros(n_atoms,1);
    residual = y;
    support = [];
    for k = 1:sparsity
        projections = abs(D' * residual);
        [~, idx] = max(projections);
        if ismember(idx, support), break; end 
        support = [support idx];
        Ds = D(:,support);
        coef_support = Ds \ y;
        coef(support) = coef_support;
        residual = y - Ds * coef_support;
        if norm(residual) < 1e-6, break; end
    end
end