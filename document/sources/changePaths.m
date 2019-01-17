%% changePaths in gTruth.mat
% you need to select the folder which includes the original images
load('gTruth.mat')
temp = gTruth.imageFilename;
joobinPath = '/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs';

 yourPath = uigetdir(cd,'select folder containing training images');
 new_paths = strrep(temp, joobinPath, yourPath); % change the paths with new path
 
gTruth.imageFilename = new_paths;