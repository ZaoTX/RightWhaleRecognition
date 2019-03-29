%% Load data
% traning dataset->traning dataset + vaildation set(100) 
% a datastore for the images  for labeling
% a datastore for all the images(4544) 
dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
%auds = augmentedImageDatastore([227 227],imds);
%% divide dataset & imageAugmenter

net = inceptionv3;
inputSize = net.Layers(1).InputSize;

pixelRange = [-10 10];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandRotation',pixelRange, ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3],...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);
% resize 
imds.ReadFcn =  @(loc)imresize(imread(loc),inputSize(1:2));

[train,val,test]= splitEachLabel(imds,0.6,0.2,'randomize');
augimdsTrain =  augmentedImageDatastore(inputSize(1:2),train, 'DataAugmentation',imageAugmenter);

augimdsValidation =  augmentedImageDatastore(inputSize(1:2),val);
%% Replace Final Layers
if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net);
end 
[learnableLayer,classLayer] = findLayersToReplace(lgraph);

numClasses = numel(categories(train.Labels));

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end

lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);
%% Freeze Initial Layers

layers = lgraph.Layers;
connections = lgraph.Connections;

layers(1:10) = freezeWeights(layers(1:10));
lgraph = createLgraphUsingConnections(layers,connections);

options = trainingOptions('sgdm', ...
    'MiniBatchSize',32, ...
    'MaxEpochs',20, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'Verbose',false, ...
    'Plots','training-progress');
net = trainNetwork(augimdsTrain,lgraph,options);