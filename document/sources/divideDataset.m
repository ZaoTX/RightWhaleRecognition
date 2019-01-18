%% divide the training dataset
% traning dataset->traning dataset + vaildation set(100) 
% a datastore for the images  for labeling
% a datastore for all the images(4544) 
dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
%% Modify Network Layers
whalenet = alexnet;
layers = whalenet.Layers;
% get the inputSize
inputSize = whalenet.Layers(1).InputSize(1:2);
% resize to 227*227*3
imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize);
% split the datastore into training set and validation set.
[train,val]= splitEachLabel(imds,0.8,'randomize');
% extract fileNames
fileNames = imds.Labels;


% new fully connected layer
% there are 447 right whales
whaleLayer = fullyConnectedLayer(447);
layers(23) = whaleLayer;
layers(end) = classificationLayer;