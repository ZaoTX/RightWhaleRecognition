% inputs: imds is the datastore needed to be stored, 
%         folderName is the name of the new folder to store imds.
% After the function, new folder are created with subfolders of images
% according to their labels.
function store_to_local(imds, folderName)

numImages = numel(imds.Files);

local = uigetdir(cd,'select folder to save data');
cd(local);
oldFolder = cd;
des = [local filesep folderName];
 if ~exist(folderName,'dir')
         mkdir(folderName);
 end
 cd(des);
for i = 1:numImages
    [img,fileinfo] = readimage(imds, i);
    whaleID_str = strsplit(fileinfo.Filename,  '/');
    whaleID_str = char(whaleID_str(end-1));
   
    destfolder = [des filesep whaleID_str];
     % create a folder for each whale (if non existant)
      if ~exist(whaleID_str,'dir')
          mkdir(whaleID_str);
      end
 
      formatStr = '%s_%d.jpg';
 
      fileName = char(sprintf(formatStr, whaleID_str,i));
      fullFileName = fullfile(destfolder, fileName);
      if ~exist(fullFileName, 'file')
          imwrite(img, fullFileName,'jpg');
      end
end
cd(oldFolder); 
end
