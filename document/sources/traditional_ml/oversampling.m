%%  Unlike in the 'divide_n_sampling.m', made copies of all images.
% This file only generates 9 copies of each image in unbalanced, classes(< 10 images) 
% using image transformations and store copies in local folder('train_oversampled')

% load original train images by selectiong 'train_images' folder.
sub_trainSet = uigetdir(cd,'select train_images folder');
sub_trainSet = imageDatastore(sub_trainSet,'IncludeSubfolders',true,'LabelSource','foldernames');

%extract labels of classes with less and equal to 9 images.
labels_count = countEachLabel(sub_trainSet);
classlabels9 = labels_count(labels_count.Count < 10 ,{'Label'});
classlabels9 = table2array(classlabels9(:,1));

% 'tmp1' is a new datastore includes one image for each classes which its
% number of images in the range of 1 to 9. 
% 'tmp2' is a new datastore includes the rest images of classes which its
% number of images in the range of 1 to 9. .

[tmp1, tmp2] = splitEachLabel(sub_trainSet, 1, 'Include',classlabels9);

% merge tmp1, tmp2 to to_oversampling(datastore includes all 
%                                    images from classes with less than 10 images).

to_oversampling = imageDatastore(cat(1,tmp1.Files, tmp2.Files));
to_oversampling.Labels = cat(1,tmp1.Labels, tmp2.Labels);

%
numImages = numel(to_oversampling.Files);

% select folders to save transformed images for classes(less than 10 images)
local = uigetdir(cd,'select folder to save data');
cd(local);
des = [local filesep 'train_oversampled'];
 if ~exist('train_oversampled','dir')
         mkdir('train_oversampled');
 end
 cd(des);
for i = 1:numImages
    [img,fileinfo] = readimage(to_oversampling, i);
    whaleID_str = strsplit(fileinfo.Filename,  '/');
    whaleID_str = char(whaleID_str(end-1));
   
    destfolder = [des filesep whaleID_str];
     % create a folder for each whale (if non existant)
      if ~exist(whaleID_str,'dir')
          mkdir(whaleID_str);
      end
     I0 = rgb2gray(img);
     % Filter images
     h = fspecial('unsharp');
     I1 = imfilter(I0,h);
     
     % imadjust
     I2 = imadjust(I0);
     
     % image transformation
     % 1. rotation
     % generate two ramdom rotation matrices
     a = 30; % angle is 30
     R = [cosd(a) sind(a) 0; -sind(a) cosd(a) 0; 0 0 1];
     img_rotate = affine2d(R);
     I3 = imwarp(I0,img_rotate);
     
     
     % shear
     % generate random shear matrix 
     b = 0.75;
     S1 = [1 b 0; 0 1 0; 0 0 1]; % shear factor along the x axis is 1.5
     S2 = [1 0 0; b 1 0; 0 0 1]; % shear factor along the y axis is 1.5
     
     img_shear1 = affine2d(S1);
     img_shear2 = affine2d(S2);
     I4 = imwarp(I0,img_shear1);
     I5 = imwarp(I0,img_shear2);
     
     % two type of compositions ('rotation + shear' & 'shear + rotation')
     RS1 = R * S1;
     S1R = S1 * R;
     RS2 = R * S2;
     S2R = S2 * S2;
     
     img_r_s_1 = affine2d(RS1);
     img_s_1_r = affine2d(S1R);
     img_r_s_2 = affine2d(RS2);
     img_s_2_r = affine2d(S2R);
     
     I6 = imwarp(I0,img_r_s_1);
     I7 = imwarp(I0,img_s_1_r);
     I8 = imwarp(I0,img_r_s_2);
     I9 = imwarp(I0,img_s_2_r);
     
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
