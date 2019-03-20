%% Initialization
clear; close all; clc
%% divide the given cropped dataset

% cropped dataset->trainSet + testSet  -> sub_trainSet + sub_validationSet + testSet
% a datastore for all the cropped images(4544) 
dataFolder = uigetdir(cd,'select imgs_train_cropped folder');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
% split the datastore into trainSet set and testSet set.
[trainSet,testSet]= splitEachLabel(imds,0.8,'randomized');

% extract fileNames
%fileNames = imds.Labels;
% get the tabel with classes(labels) and the number of included images 
counts_labels = countEachLabel(trainSet);
% extract labels of one-image-classes
minClass_labels = counts_labels(counts_labels.Count==1,{'Label'});
minClass_labels = table2array(minClass_labels(:,1));

% train_One is a new datastore with 24 images from from classes with one image.
% emp is an empty datastore.
[train_One,emp] = splitEachLabel(trainSet, 1, 'Include',  minClass_labels);

%extract labels of classes with less and equal to 5 images.
minorClass_labels = counts_labels(counts_labels.Count < 6 ,{'Label'});
minorClass_labels = table2array(minorClass_labels(:,1));

% 'val_two' is a new datastore includes one image for each classes which its
% number of images in the range of 1 to 5. 
% 'train_two' is a new datastore includes the rest images of classes which
% its number of images in the range of 2 to 5.
[val_two, train_two] = splitEachLabel(trainSet, 1, 'randomized','Include', minorClass_labels);

%extract labels of classes with greater or equal to 6 images.
otherClasses = counts_labels(counts_labels.Count>5,{'Label'});
otherClasses = table2array(otherClasses(:,1));
% split images of these classes into 'train_final' 90%, and 'val_final'
% 10%.
[train_final,val_final] = splitEachLabel(trainSet, 0.9, 'randomized','Include',otherClasses);

% merge into a sub_trainSet and a sub_validationSet

sub_trainSet = imageDatastore(cat(1,train_One.Files, train_two.Files, train_final.Files));
sub_trainSet.Labels = cat(1,train_One.Labels, train_two.Labels, train_final.Labels);

sub_validationSet = imageDatastore(cat(1,val_two.Files, val_final.Files));
sub_validationSet.Labels = cat(1,val_two.Labels, val_final.Labels);

%% save trainSet testSet and sub_validationSet into concrete local folders.
% After calling store2local, the first thing is to select a location to
% store corresponding images.
store_to_local(testSet,'test_images');
store_to_local(sub_validationSet, 'validation_images');
store_to_local(sub_trainSet, 'train_images');
