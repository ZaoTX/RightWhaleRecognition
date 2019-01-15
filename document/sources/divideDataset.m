%% divide the training dataset
% traning dataset->traning dataset + vaildation set(100) 
% a datastore for the images  for labeling
% a datastore for all the images(4544) 
dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
% split the datastore into training set and validation set.
[train,val]= splitEachLabel(imds,0.8,'randomize');
% extract fileNames
fileNames = imds.Labels;