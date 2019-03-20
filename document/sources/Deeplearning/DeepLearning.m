%% Modify Network Layers
whalenet = alexnet;
%layers = whalenet.Layers;
% get the inputSize
inputSize = whalenet.Layers(1).InputSize(1:2);
% inputSize1 = [28 28 3];
% layers(1).InputSize = inputSize1;
% extract fileNames
%fileNames = imds.Labels;

layersTransfer = whalenet.Layers(1:end-3);
numClasses = 111;
layers = [
    layersTransfer
    batchNormalizationLayer
    fullyConnectedLayer(numClasses)%,'WeightLearnRateFactor',10,'BiasLearnRateFactor',5
    softmaxLayer
    classificationLayer];
% new fully connected layer
% there are 447 right whales
% whaleLayer = fullyConnectedLayer(447);
% layers(23) = whaleLayer;
% layers(end) = classificationLayer;
%% divide the training dataset
% traning dataset->traning dataset + vaildation set(100) 
% a datastore for the images  for labeling
% a datastore for all the images(4544) 
dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
%auds = augmentedImageDatastore([227 227],imds);
pixelRange = [-30 30];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandRotation',[-90,90], ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3],...
    'RandXScale',[0.9 1.1], ...
    'RandYScale',[0.9 1.1]);
%augImds = augmentedImageDatastore([227 227],imds,'DataAugmentation',imageAugmenter);
% resize to 227*227*3
imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize);
% resize to 28*28*3
%imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize1);
% split the datastore into training set and validation set.
[train,val]= splitEachLabel(imds,0.8,'randomize');
augimdsTrain =  augmentedImageDatastore(inputSize(1:2),train, 'DataAugmentation',imageAugmenter);

augimdsValidation =  augmentedImageDatastore(inputSize(1:2),val);
% set the options
opts = trainingOptions('sgdm', ...
    'MaxEpochs',40, ...
    'Shuffle','every-epoch', ...
    'Verbose',true, ...
    'InitialLearnRate', 0.001,...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'Plots','training-progress');

[whalenet,info] = trainNetwork(augimdsTrain,layers,opts);

%% compute TrainingLoss
%plot(info.TrainingLoss);