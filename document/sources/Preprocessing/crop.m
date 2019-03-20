%% When running this file, you have to select two locations:
%  First, the 'imgs_train_whaleIDs'folder; 
%  Second, the location to store the folder with cropped images.

%% changePaths in gTruth.mat

% preconditions: download 'gTruth.mat' to the workspace.
load('gTruth.mat')
temp = gTruth.imageFilename;
joobinPath = '/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs';

%select the 'imgs_train_whaleIDs' folder on your computer
yourPath = uigetdir(cd,'select the imgs_train_whaleIDs.');
new_paths = strrep(temp, joobinPath, yourPath); % change the paths with the new path
 
gTruth.imageFilename = new_paths;

%% to crop whale head and store them to a 'imgs_train_cropped' folder.

% Get the imagePath and create the corresponding whale_ID folder and save the image.
imageRoute = gTruth.imageFilename;
imageBoundingBoxes = gTruth.Head;

% to select the location for 'imgs_train_cropped' folder.
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
 
%  Crop Head with imageBoundingBoxes(ROIs)
  
       img = imread(imageRoute{i});
       imcropped = imcrop(img, imageBoundingBoxes{i});
% %     imshow(imcropped);
      fileName = char(sprintf(formatStr, whaleID_str,i));
      fullFileName = fullfile(destfolder, fileName);
      if ~exist(fullFileName, 'file')
          imwrite(imcropped, fullFileName,'jpg');
      end
end
