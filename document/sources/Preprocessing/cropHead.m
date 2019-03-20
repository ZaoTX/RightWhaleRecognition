%% crop whale head and store them to selected folder.

% Get the imagePath and make the corresponding whale_ID folder and save the image.
imageRoute = gTruth.imageFilename;
imageBoundingBoxes = gTruth.Head;
local = uigetdir(cd,'select folder to save cropped images');
cd(local);
imgs_train_cropped = [local filesep 'imgs_train_cropped'];
 if ~exist(imgs_train_cropped,'dir')
         mkdir('imgs_train_cropped');
 end
 cd(imgs_train_cropped);
for i = 1:size(imageRoute, 1)
    whaleID_str = strsplit(imageRoute{i},  '/');
    whaleID_str = char(whaleID_str(end-1));
   
    destfolder = [imgs_train_cropped filesep whaleID_str];
     % create a folder for each whale (if non existant)
      if ~exist(whaleID_str,'dir')
          mkdir(whaleID_str);
      end
 
      formatStr = '%s_%d.jpg';
 
%  Crop Head with imageBoundingBoxes
  
       img = imread(imageRoute{i});
       imcropped = imcrop(img, imageBoundingBoxes{i});
% %     imshow(imcropped);
      fileName = char(sprintf(formatStr, whaleID_str,i));
      fullFileName = fullfile(destfolder, fileName);
      if ~exist(fullFileName, 'file')
          imwrite(imcropped, fullFileName,'jpg');
      end
end