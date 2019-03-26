function [features, setLabels] = featureEx(imds, hogFeatureSize, cellSize)
% Extract HOG features from an imageDatastore.

setLabels = imds.Labels;
numImages = numel(imds.Files);
features  = zeros(numImages, hogFeatureSize, 'single');

% Process each image and extract features
for j = 1:numImages
    img = readimage(imds,j);
    features(j, :) = extractHOGFeatures(img,'CellSize',cellSize);
end
end
