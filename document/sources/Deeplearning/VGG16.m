%% Modify Network Layers
whalenet = vgg16;
%layers = whalenet.Layers;
% get the inputSize
inputSize = whalenet.Layers(1).InputSize;
% inputSize1 = [28 28 3];
% layers(1).InputSize = inputSize1;
% extract fileNames
%fileNames = imds.Labels;

layersTransfer = whalenet.Layers(1:end-3);
%you can change the number of classes for your case
numClasses = 111;
% layers = [
%     layersTransfer
%     batchNormalizationLayer
%     fullyConnectedLayer(numClasses)%,'WeightLearnRateFactor',10,'BiasLearnRateFactor',5
%     softmaxLayer
%     classificationLayer];
% new fully connected layer
layers = whalenet.Layers;
whaleLayer = fullyConnectedLayer(numClasses);
layers(39) = whaleLayer;
layers(end) = classificationLayer;
%% divide the training dataset
% traning dataset->traning dataset + vaildation set(100) 
% a datastore for the images  for labeling
% a datastore for all the images(4544) 

 dataFolder = uigetdir(cd,'select folder containing training images');
 imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');

%auds = augmentedImageDatastore([227 227],imds);

% train = uigetdir(cd,'select folder containing training images');
% val = uigetdir(cd,'select folder containing validation images');
% test = uigetdir(cd,'select folder containing test images');
% train =  imageDatastore(train,'IncludeSubfolders',true,'LabelSource','foldernames');
% val =  imageDatastore(val,'IncludeSubfolders',true,'LabelSource','foldernames');
% test = imageDatastore(test,'IncludeSubfolders',true,'LabelSource','foldernames');

pixelRange = [-10 10];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandYReflection',true, ...
    'RandRotation',pixelRange, ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3],...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);
%augImds = augmentedImageDatastore([227 227],imds,'DataAugmentation',imageAugmenter);
% resize to 227*227*3
 imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize(1:2));
% resize to 28*28*3
%imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize1);
% split the datastore into training set and validation set.

[train,val]= splitEachLabel(imds,0.6,'randomize');
[val,test] =splitEachLabel(val,0.5,'randomize');
 augimdsTrain =  augmentedImageDatastore(inputSize,train, 'DataAugmentation',imageAugmenter);
% 
 augimdsValidation =  augmentedImageDatastore(inputSize,val,'DataAugmentation',imageAugmenter);
%%
% set the options
%    'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.2, ...
% %     'LearnRateDropPeriod',5, ...
opts = trainingOptions('sgdm', ...
    'MaxEpochs',55, ...
    'Verbose',false, ...
    'InitialLearnRate', 0.001,...
    'ValidationData', augimdsValidation, ...
    'ValidationFrequency',3, ...
    'Plots','training-progress');

[whalenet,info] = trainNetwork(augimdsTrain ,layers,opts);

%% compute TrainingLoss
%plot(info.TrainingLoss);