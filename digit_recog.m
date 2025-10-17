%% Parameters
SZ = 20; CLASS_N = 10; DIGITS_FN = "C:\Users\LENOVO\OneDrive\Desktop\digit.png";
%% Utilities
mosaic = @(w,img) cell2mat(reshape(img, w, [])'); 
split2d = @(img,sz) reshape(mat2cell(img,repmat(sz,1,size(img,1)/sz),...
                                     repmat(sz,1,size(img,2)/sz)),[],1);
deskew = @(img,SZ) img; 

% Highlight misclassified digits
function out = highlightError(img, correct)
    if size(img,3)==1
        img = repmat(img,1,1,3);
    end
    if ~correct, img(:,:,2:2)=0;
    end 
    out = img;
end
%% Load & preprocess digits
img = im2gray(imread(DIGITS_FN));
digits = split2d(img,SZ);
labels = repelem((0:CLASS_N-1)', numel(digits)/CLASS_N);

rng(321); idx=randperm(numel(digits));
digits = digits(idx); labels=labels(idx);

digits_deskewed = cellfun(@(x) deskew(x,SZ), digits,'UniformOutput',false);
hog = cellfun(@(x) extractHOGFeatures(x,'CellSize',[10 10]), digits_deskewed,'UniformOutput',false);
samples = vertcat(hog{:});
%% Train/Test split
train_n = round(0.9*size(samples,1));
Xtr = samples(1:train_n,:); Ytr = labels(1:train_n);
Xte = samples(train_n+1:end,:); Yte = labels(train_n+1:end);
digits_test = digits_deskewed(train_n+1:end);
%% Show test set
figure; imshow(mosaic(25, cellfun(@(x) repmat(x,1,1,3), digits_test,'UniformOutput',false)));
title('Test Set (10%)');
%% kNN
knn = fitcknn(Xtr,Ytr,'NumNeighbors',4); 
Yknn = predict(knn,Xte);
fprintf('kNN Error: %.2f %%\n', mean(Yknn~=Yte)*100);
 disp(confusionmat(Yte,Yknn));

vis_knn = cellfun(@(img,c) highlightError(img,c), digits_test,num2cell(Yknn==Yte),'UniformOutput',false);
figure; imshow(mosaic(25, vis_knn)); title('kNN Result');
%% SVM
svm = fitcecoc(Xtr,Ytr,'Learners',templateSVM('KernelFunction','rbf','BoxConstraint',2.67,'KernelScale',1/5.383));
Ysvm = predict(svm,Xte);
fprintf('SVM Error: %.2f %%\n', mean(Ysvm~=Yte)*100);
disp('Confusion matrix (SVM):'); disp(confusionmat(Yte,Ysvm));

vis_svm = cellfun(@(img,c) highlightError(img,c), digits_test,num2cell(Ysvm==Yte),'UniformOutput',false);
figure; imshow(mosaic(25, vis_svm)); title('SVM Result');

