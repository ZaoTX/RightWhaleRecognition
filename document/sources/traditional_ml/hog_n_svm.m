%%Initialization
clear; close all; clc

%% load data
% create two datastores by selecting the following two folders sequantially:
% the 'train_images' and 'train_oversampled'.

train_original = uigetdir(cd,'select train_images folder');
train1 = imageDatastore(train_original,'IncludeSubfolders',true,'LabelSource','foldernames');

% turn to gray
numImages = numel(train1.Files);
for i = 1:numImages
    [img,fileinfo] = readimage(train1, i);
    img = rgb2gray(img);
    imwrite (img,fileinfo.Filename);
end

%%
train_oversampled  = uigetdir(cd,'select train_oversampled folder');
train2 = imageDatastore(train_oversampled,'IncludeSubfolders',true,'LabelSource','foldernames');

% merge into one datastore ('trainSet'). 

trainSet = imageDatastore(cat(1,train1.Files, train2.Files));
trainSet.Labels = cat(1,train1.Labels, train2.Labels);

%% Feature extraction

%resize images
inputSize = [128 128];
trainSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);

%pre-processing 
img = readimage(trainSet,46);
figure;
subplot(2,3,2);
imshow(img);

[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
[hog_16x16, vis16x16] = extractHOGFeatures(img,'CellSize',[16 16]);
[hog_32x32, vis32x32] = extractHOGFeatures(img,'CellSize',[32 32]);

subplot(2,3,4)
plot(vis8x8);
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});

subplot(2,3,5)
plot(vis16x16)
title({'CellSize = [16 16]'; ['Length = ' num2str(length(hog_16x16))]});

subplot(2,3,6)
plot(vis32x32)
title({'CellSize = [32 32]'; ['Length = ' num2str(length(hog_32x32))]});

%% Loop over the trainSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.
cellSize = [8 8];
hogFeatureSize = length(hog_8x8);


%hog feature extraction for training set.
[trainSetFeatures, trainSetLabels] = featureEx(trainSet, hogFeatureSize, cellSize);

[coeff,scoreTrain,~,~,explained,mu] = pca(trainSetFeatures); % scoreTrain: principal component scores 

explained

sum_explained = 0;
idx = 0;
while sum_explained < 95
    idx = idx + 1;
    sum_explained = sum_explained + explained(idx);
end
idx

%% select principal componenet scores according to the idx

scoreTrain95 = scoreTrain(:,1:idx);

c = optimizableVariable('c',[1e-3,1e3],'Transform','log');

% load validation data
% select folder 'validation_images'

validationSet = uigetdir(cd,'select validation_images folder');
validationSet = imageDatastore(validationSet,'IncludeSubfolders',true,'LabelSource','foldernames');

%resize images
inputSize = [128 128];
validationSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);

% turn to gray
n2 = numel(validationSet.Files);

for i = 1:n2
    [img2,fileinfo] = readimage(validationSet, i);
    img2 = rgb2gray(img2);
    imwrite (img2,fileinfo.Filename);
end

%% 
[valSetFeatures, valSetLabels] = featureEx(validationSet, hogFeatureSize, cellSize);
scoreVal95 = (valSetFeatures-mu)*coeff(:,1:idx);

minfn = @(z)gather(loss(fitcecoc(scoreTrain95,trainSetLabels, ...
        'Coding','onevsall',...
        'Learners',templateSVM('BoxConstraint', z.c,'KernelFunction', 'linear', 'Standardize', true),'Verbose',1),...
        scoreVal95,valSetLabels));
    
results = bayesopt(minfn,c,'MaxObjectiveEvaluations',30,'Verbose',1);

zbest = bestPoint(results);
mdl = fitcecoc(scoreTrain95, trainSetLabels,...
    'Coding','onevsall',...
    'Learners',templateSVM('BoxConstraint', zbest.c,...
    'KernelFunction', 'linear', 'Standardize', true),'Verbose',1);

%% load test data
% select folder 'test_images'

testSet = uigetdir(cd,'select test_images folder');
testSet = imageDatastore(testSet,'IncludeSubfolders',true,'LabelSource','foldernames');
%resize images
inputSize = [128 128];
testSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);

% turn to gray
n2 = numel(testSet.Files);

for i = 1:n2
    [img2,fileinfo] = readimage(testSet, i);
    img2 = rgb2gray(img2);
    imwrite (img2,fileinfo.Filename);
end

[testSetFeatures, testSetLabels] = featureEx(testSet, hogFeatureSize, cellSize);
scoreTest95 = (testSetFeatures-mu)*coeff(:,1:idx);

[pred,score,cost] = predict(mdl, scoreTest95);
accuracy = sum(testSetLabels == pred)/size(testSetLabels,1);
accuracy



