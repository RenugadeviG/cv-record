clc; clear; close all;
%% Step 1: Load digit dataset
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos','nndatasets','DigitDataset');
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
% Resize to 8x8 to match Python example
imds.ReadFcn = @(filename) imresize(im2double(imread(filename)), [8 8]);
% Convert to numeric arrays
numSamples = numel(imds.Files);
X = zeros(numSamples, 64);
y = zeros(numSamples,1);
for i = 1:numSamples
    img = readimage(imds,i);
    X(i,:) = img(:)';       % flatten 8x8 -> 64
    y(i) = double(imds.Labels(i));
end
%% Step 2: Train-test split (70/30)
cv = cvpartition(y, 'HoldOut', 0.3);
X_train = X(training(cv),:);
y_train = y(training(cv),:);
X_test = X(test(cv),:);
y_test = y(test(cv),:);
%% Step 3: Train Random Forest classifier
model = TreeBagger(100, X_train, y_train, 'OOBPrediction', 'On', 'Method', 'classification');
%% Step 4: Predict on test set
y_pred = str2double(predict(model, X_test));
%% Step 5: Confusion matrix and accuracy
confMat = confusionmat(y_test, y_pred);
disp('Confusion Matrix:');
disp(confMat);
accuracy = sum(y_pred == y_test)/numel(y_test);
fprintf('Overall Accuracy: %.4f\n\n', accuracy);
%% Step 6: Per-class Precision, Recall, F1
numClasses = size(confMat,1);
precision = zeros(numClasses,1);
recall = zeros(numClasses,1);
f1 = zeros(numClasses,1);
support = sum(confMat,2); % true labels per class
for i = 1:numClasses
    TP = confMat(i,i);
    FP = sum(confMat(:,i)) - TP;
    FN = sum(confMat(i,:)) - TP;
    
    precision(i) = TP / (TP + FP);
    recall(i) = TP / (TP + FN);
    f1(i) = 2 * (precision(i)*recall(i)) / (precision(i)+recall(i));
end
% Display table
fprintf('Class\tPrecision\tRecall\t\tF1-Score\tSupport\n');
for i = 1:numClasses
    fprintf('%d\t%.3f\t\t%.3f\t\t%.3f\t\t%d\n', i-1, precision(i), recall(i), f1(i), support(i));
end
%% Step 7: Macro-average
macro_precision = mean(precision);
macro_recall = mean(recall);
macro_f1 = mean(f1);
%% Step 8: Weighted-average
weighted_precision = sum(precision .* support) / sum(support);
weighted_recall = sum(recall .* support) / sum(support);
weighted_f1 = sum(f1 .* support) / sum(support);
%% Step 9: Micro-average
TP_micro = sum(diag(confMat));
FP_micro = sum(confMat(:)) - TP_micro;
FN_micro = FP_micro;
micro_precision = TP_micro / (TP_micro + FP_micro);
micro_recall = TP_micro / (TP_micro + FN_micro);
micro_f1 = 2 * (micro_precision * micro_recall) / (micro_precision + micro_recall);
%% Step 10: Display averages
fprintf('\nAverages:\n');
fprintf('Macro Precision: %.3f, Recall: %.3f, F1: %.3f\n', macro_precision, macro_recall, macro_f1);
fprintf('Weighted Precision: %.3f, Recall: %.3f, F1: %.3f\n', weighted_precision, weighted_recall, weighted_f1);
fprintf('Micro Precision: %.3f, Recall: %.3f, F1: %.3f\n', micro_precision, micro_recall, micro_f1);
%% Step 11: Plot confusion matrix
figure;
cm = confusionchart(y_test, y_pred);
cm.Title = 'Digit Classification Confusion Matrix';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';
