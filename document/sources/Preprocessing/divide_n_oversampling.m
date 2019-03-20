%% Initialization
clear; close all; clc
%% divide the given cropped dataset

% cropped dataset->trainSet + testSet  -> sub_trainSet + sub_validationSet + testSet
% a datastore for all the cropped images(4544) 
dataFolder = uigetdir(cd,'select imgs_train_cropped folder');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');
% split the datastore into trainSet set and testSet set.
[trainSet,testSet]= splitEachLabel(imds,0.8,'randomized');

% extract fileNames
%fileNames = imds.Labels;
% get the tabel with classes(labels) and the number of included images 
counts_labels = countEachLabel(trainSet);
% extract labels of one-image-classes
minClass_labels = counts_labels(counts_labels.Count==1,{'Label'});
minClass_labels = table2array(minClass_labels(:,1));

% train_One is a new datastore with 24 images from from classes with one image.
% emp is an empty datastore.
[train_One,emp] = splitEachLabel(trainSet, 1, 'Include',  minClass_labels);

%extract labels of classes with less and equal to 5 images.
minorClass_labels = counts_labels(counts_labels.Count < 6 ,{'Label'});
minorClass_labels = table2array(minorClass_labels(:,1));

% 'val_two' is a new datastore includes one image for each classes which its
% number of images in the range of 1 to 5. 
% 'train_two' is a new datastore includes the rest images of classes which
% its number of images in the range of 2 to 5.
[val_two, train_two] = splitEachLabel(trainSet, 1, 'randomized','Include', minorClass_labels);

%extract labels of classes with greater or equal to 6 images.
otherClasses = counts_labels(counts_labels.Count>5,{'Label'});
otherClasses = table2array(otherClasses(:,1));
% split images of these classes into 'train_final' 90%, and 'val_final'
% 10%.
[train_final,val_final] = splitEachLabel(trainSet, 0.9, 'randomized','Include',otherClasses);

% merge into a sub_trainSet and a sub_validationSet

sub_trainSet = imageDatastore(cat(1,train_One.Files, train_two.Files, train_final.Files));
sub_trainSet.Labels = cat(1,train_One.Labels, train_two.Labels, train_final.Labels);

sub_validationSet = imageDatastore(cat(1,val_two.Files, val_final.Files));
sub_validationSet.Labels = cat(1,val_two.Labels, val_final.Labels);

%% save trainSet testSet and sub_validationSet into concrete local folders.
% After calling store2local, the first thing is to select a location to
% store corresponding images.
store_to_local(testSet,'test_images');
store_to_local(sub_validationSet, 'validation_images');
store_to_local(sub_trainSet, 'train_images');


%% Oversampling inbalanced sub_trainSet

% aggressive oversamplings : generate 9 copies of each image in sub_trainSet
% using image transformations and store in local folders.

numImages = numel(sub_trainSet.Files);

local = uigetdir(cd,'select folder to save data');
cd(local);
des = [local filesep 'transformed_imgs'];
 if ~exist('transformed_imgs','dir')
         mkdir('transformed_imgs');
 end
 cd(des);
for i = 1:numImages
    [img,fileinfo] = readimage(sub_trainSet, i);
    whaleID_str = strsplit(fileinfo.Filename,  '/');
    whaleID_str = char(whaleID_str(end-1));
   
    destfolder = [des filesep whaleID_str];
     % create a folder for each whale (if non existant)
      if ~exist(whaleID_str,'dir')
          mkdir(whaleID_str);
      end
      
     % Filter images
     h = fspecial('unsharp');
     I1 = imfilter(img,h);
     
     
     % imadjust
     I_gray = rgb2gray(img);
     I2 = imadjust(I_gray);
     
     % image transformation
     % 1. rotation
     % generate two ramdom rotation matrices
     a = 30; % angle is 30
     R = [cosd(a) sind(a) 0; -sind(a) cosd(a) 0; 0 0 1];
     img_rotate = affine2d(R);
     I3 = imwarp(img,img_rotate);
     
     
     % shear
     % generate random shear matrix 
     b = 0.75;
     S1 = [1 b 0; 0 1 0; 0 0 1]; % shear factor along the x axis is 1.5
     S2 = [1 0 0; b 1 0; 0 0 1]; % shear factor along the y axis is 1.5
     
     img_shear1 = affine2d(S1);
     img_shear2 = affine2d(S2);
     I4 = imwarp(img,img_shear1);
     I5 = imwarp(img,img_shear2);
     
     % two type of compositions ('rotation + shear' & 'shear + rotation')
     RS1 = R * S1;
     S1R = S1 * R;
     RS2 = R * S2;
     S2R = S2 * S2;
     
     img_r_s_1 = affine2d(RS1);
     img_s_1_r = affine2d(S1R);
     img_r_s_2 = affine2d(RS2);
     img_s_2_r = affine2d(S2R);
     
     I6 = imwarp(img,img_r_s_1);
     I7 = imwarp(img,img_s_1_r);
     I8 = imwarp(img,img_r_s_2);
     I9 = imwarp(img,img_s_2_r);
     
     formatStr = '%s_%d_%d.jpg';
     
     for j = 1:9
     img_tmp =  eval(sprintf('I%d',j));   
     fileName = char(sprintf(formatStr, whaleID_str,i,j));
     fullFileName = fullfile(destfolder, fileName);
     if ~exist(fullFileName, 'file')
         imwrite(img_tmp, fullFileName,'jpg');
     end
     
     end  
   
end

