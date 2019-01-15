load('gTruth.mat');

% Get the imagePath and make the corresponding whale_ID folder and save the image.
imageRoute = gTruth.imageFilename;
imageBoundingBoxes = gTruth.Head;

for i = 1:size(imageRoute, 1)
    whaleID_str = strsplit(imageRoute{i}, '/');
    whaleID_str = whaleID_str{8};

    % create a folder for each whale (if non existant)
    if ~exist(whaleID_str,'dir')
        mkdir(whaleID_str);
    end

    formatStr = '%s_%d.jpg';

    % Crop Head with imageBoundingBoxes

    img = imread(imageRoute{i});
    imcropped = imcrop(img, imageBoundingBoxes{i});
%     imshow(imcropped);
    fileName = sprintf(formatStr, whaleID_str, i);
    if ~exist(fileName, 'file')
        imwrite(imcropped, [whaleID_str filesep fileName]);
    end
end