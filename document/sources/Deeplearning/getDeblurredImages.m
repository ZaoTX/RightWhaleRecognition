%% crop whale head and store them to selected folder.
% I create this script using the same idea like crophead 
% You need to run changePaths.m at first
 
% choose your folder containing trainig images
dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
% Get the imagePath and make the corresponding whale_ID folder and save the image.
imageRoute = gTruth.imageFilename;

local = uigetdir(cd,'select folder to save cropped images');
cd(local);
des = [local filesep 'imgs_train_debulrred'];
 if ~exist(des,'dir')
         mkdir('imgs_train_debulrred');
 end
 cd(des);
for i = 1:size(imageRoute, 1)
      I =im2double(readimage(imds,i));


      LEN = 21;
      THETA = 11;
      PSF = fspecial('motion', LEN, THETA);
      blurred = imfilter(I, PSF, 'conv', 'circular');


      noise_var = 0.0001;


      estimated_nsr = noise_var / var(I(:));
      wnr3 = deconvwnr(I, PSF, estimated_nsr);
      whaleID_str = strsplit(imageRoute{i},  '/');
      whaleID_str = char(whaleID_str(end-1));
      whaleID_str = strsplit(imageRoute{i},  '/');
      whaleID_str = char(whaleID_str(end-1));
   
     destfolder = [des filesep whaleID_str];
     % create a folder for each whale (if non existant)
      if ~exist(whaleID_str,'dir')
          mkdir(whaleID_str);
      end
 
      formatStr =  '%s_%d.jpg';
 
% %     imshow(imcropped);
      fileName = char(sprintf(formatStr, whaleID_str,i));
      fullFileName = fullfile(destfolder, fileName);
      if ~exist(fullFileName, 'file')
          imwrite( wnr3, fullFileName,'jpg');
      end
end