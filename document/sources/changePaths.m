load('gTruth.mat')
temp = gTruth.imageFilename;

% For Ying
new_paths = strrep(temp, '/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs', '/Users/wangying/Desktop/ML-PRO/label'); % change the path with new path

% For Ziyao
% new_paths = strrep(temp, '/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs¡¯, ¡®C:\semester5\MachineLearning\ProjectData\forDeep'); % change the paths with new

gTruth.imageFilename = new_paths;