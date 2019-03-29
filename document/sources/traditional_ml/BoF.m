% The file is to use Bag of features for the feature extraction and feature selection and use linear svm to train.

%%Initialization
clear; close all; clc

%% load data

% train data
% create two datastores by selecting the following two folders sequantially:
% the 'train_images' and 'train_oversampled'.

train_original = uigetdir(cd,'select train_images folder');
train1 = imageDatastore(train_original,'IncludeSubfolders',true,'LabelSource','foldernames');

%
train_oversampled  = uigetdir(cd,'select train_oversampled folder');
train2 = imageDatastore(train_oversampled,'IncludeSubfolders',true,'LabelSource','foldernames');

% merge into one datastore ('trainSet'). 

trainSet = imageDatastore(cat(1,train1.Files, train2.Files));
trainSet.Labels = cat(1,train1.Labels, train2.Labels);

% load validation data
% select folder 'validation_images'

validationSet = uigetdir(cd,'select validation_images folder');
validationSet = imageDatastore(validationSet,'IncludeSubfolders',true,'LabelSource','foldernames');

% load test data
% select folder 'test_images'

testSet = uigetdir(cd,'select test_images folder');
testSet = imageDatastore(testSet,'IncludeSubfolders',true,'LabelSource','foldernames');
%resize images
inputSize = [128 128];

trainSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);
validationSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);
testSet.ReadFcn = @(loc)imresize(imread(loc),inputSize);

%% For original dataset 'train1'(without oversampled).

% Feature extraction
train_original_bag = bagOfFeatures(train1);

% initial range of hyperprameter
c = optimizableVariable('c',[1e-2,1e1],'Transform','log');

% tuning hyperprameters

%
minfn = @(z)gather(imageCategorical_loss(trainImageCategoryClassifier(train1,train_original_bag, ...
        'learnerOptions',... 
        templateSVM('BoxConstraint', z.c),'Verbose',1),validationSet));
    
results = bayesopt(minfn,c,'MaxObjectiveEvaluations',6,'Verbose',1);

zbest = bestPoint(results);

%% training model with optimized values

mdl = trainImageCategoryClassifier(train1,train_original_bag, ...
        'learnerOptions',... 
        templateSVM('BoxConstraint', zbest.c),'Verbose',2);
  
confMatrix1 = evaluate(mdl, trainSet);

confMatrix2 = evaluate(mdl, validationSet);

[labelIdx1, score1] = predict(mdl,testSet);

pred1 = mdl.Labels(labelIdx1);

accuracy1 = sum(sum(testSetLabels == pred1'))/size(testSetLabels,1);

%% try the oversampled train set 'trainSet'

% Feature extraction
train_bag = bagOfFeatures(trainSet);

% tuning c
minfn_w = @(z)gather(imageCategorical_loss(trainImageCategoryClassifier(subSet,subSet_bag, ...
        'learnerOptions',... 
        templateSVM('BoxConstraint', z.c),'Verbose',1),validationSet));
    
results_w = bayesopt(minfn,c,'MaxObjectiveEvaluations',5,'Verbose',1);

zbest_w = bestPoint(results);
%

mdl_whole = trainImageCategoryClassifier(trainSet,trainbag, ...
        'learnerOptions',... 
        templateSVM('BoxConstraint', zbest_w.c),'Verbose',2);
        
confMatrix_w_1 = evaluate(mdl_whole, trainSet);
confMatrix_w_2 = evaluate(mdl_whole, validationSet);
%%
[labelIdx_w, score_w] = predict(mdl_whole,testSet);

pred_w = mdl_whole.Labels(labelIdx_w);
%
accuracy_w = sum(sum(testSetLabels == pred_w'))/size(testSetLabels,1);






