% This file 

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

% Feature extraction

train_original_bag = bagOfFeatures(train1);
trainSetLabels = train1.Labels;




%% defautl value of Boxconstraint is 1.

mdl_original = trainImageCategoryClassifier(train1,train_original_bag);
confMatrix1_1 = evaluate(mdl_original, train1);
confMatrix1_2 = evaluate(mdl_original, validationSet);
%%
[labelIdx, score] = predict(mdl_original,testSet);

testSetLabels = testSet.Labels;
pred = mdl_original.Labels(labelIdx);
%%
accuracy = sum(sum(testSetLabels == pred'))/size(testSetLabels,1);

%% initial range of hyperprameter
c = optimizableVariable('c',[1e-3,1e3],'Transform','log');
% sigma = optimizableVariable('sigma',[1e-3,1e3],'Transform','log');

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
        templateSVM('BoxConstraint', z.c),'Verbose',2);
  
confMatrix1 = evaluate(mdl, trainSet);

confMatrix2 = evaluate(mdl, validationSet);

[labelIdx1, score1] = predict(mdl,testSet);

pred1 = mdl.Labels(labelIdx1);

accuracy1 = sum(sum(testSetLabels == pred1'))/size(testSetLabels,1);
%% using the whole oversampled trainSet to train
train_bag = bagOfFeatures(trainSet);

mdl_oversampled = trainImageCategoryClassifier(trainSet,train_bag);
confMatrix2_1 = evaluate(mdl_oversampled, trainSet);
confMatrix2_2 = evaluate(mdl_oversampled, validationSet);
confMatrix2_3 = evaluate(mdl_oversampled, testSet);


%% try the oversampled train set
% Feature extraction

train_bag = bagOfFeatures(trainSet);

%
mdl_whole = trainImageCategoryClassifier(trainSet,train_bag);
confMatrix_w_1 = evaluate(mdl_whole, trainSet);
confMatrix_w_2 = evaluate(mdl_whole, validationSet);
%%
[labelIdx_w, score_w] = predict(mdl_whole,testSet);

pred_w = mdl_whole.Labels(labelIdx_w);
%
accuracy_w = sum(sum(testSetLabels == pred_w'))/size(testSetLabels,1);


%% give 6 possible values of 'Boxconstraint'

BC = 1;

params = [0.001; 0.02; 0.3; 5; 10; 300];
Error = zeros(length(params));
for i= 1:length(params)
    BC = params(i);
    BC
    model = trainImageCategoryClassifier(train1,train_original_bag, ...
        'learnerOptions',... 
        templateSVM('BoxConstraint', BC),'Verbose',1);
    Error(i) =  imageCategorical_loss(model,validationSet);
end
 min = find(Error == min(min(Error)));
 BC_best = params(min);
%% save
save('hog_classification2');






