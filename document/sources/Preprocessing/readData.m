%% Read images according to train.csv and categorized images into different subfolders according to labels.
%  preconditions:
%  1. downloaded the following file into one folder from kaggle(https://www.kaggle.com/c/noaa-right-whale-recognition/data)
%     train.csv, imgs.zip file and w_7489.jpg
%
%  2. put train.csv and w_7489.jpg into imgs folder.
%
%  3. create two subfolders in imgs folder to store data:
%  folder1: CSVs_train, folder2: imgs_train_whaleIDs

%  your folder order should be like this :
%  imgs(folder)------ CSVs_train(folder)-whaleID.csv with its corresponding imageNames store in csv
%                   | imgs_train_whaleIDs(folder)-whale_ID(folders) with its corresponding images                
%                   | train.csv
%                   | images 

%% Organize Image files in a separate folder for each whaleID
dataFolder = uigetdir(cd,'select imgs folder');
cd(dataFolder);
% Extract whaleID counts & corresponding image files
train = readtable([dataFolder filesep 'train.csv'],'Format','%s%C');
summary(train)
[c,h] = histcounts(train.whaleID);
[c_sorted,originalInd] = sort(c);
ordered_whales = categorical(h(flip(originalInd)));

% Define source/destination folders
CSVdestFolder = [dataFolder filesep 'CSVs_train'];
Original_imgs_folder = [dataFolder];
Organized_imgs_folder = [dataFolder filesep 'imgs_train_whaleIDs'];
cd(Organized_imgs_folder);

% Initialize table to save list of files for each unique whaleID
summary_table = table(ordered_whales',flip(c_sorted)',cell(numel(ordered_whales),1),'VariableNames',{'whaleID' 'ImgCount' 'FileList'});
count = 0;
% Loop for each class
for i=1:numel(ordered_whales)
    % Extract table of files
    file_list = train(train.whaleID==ordered_whales(i),1);
    whaleID_str = char(ordered_whales(i));
    summary_table.FileList(i) = {cellstr(table2array(file_list))};
    
    % csvwrite list of files for each whaleID
    writetable(file_list,[CSVdestFolder filesep whaleID_str '.csv']);
    
    % create a folder for each whale (if non existant)
    if ~exist(whaleID_str,'dir')
        mkdir(whaleID_str);
    end
    destFolder = [Organized_imgs_folder filesep whaleID_str];
     
    % Loop & move the corresponding train images
    parfor f = 1:height(file_list)
        try
            movefile([Original_imgs_folder filesep char(file_list.Image(f))],destFolder);
        catch
            disp([file_list{f,1} ' already moved or non-existent!!']);
        end
    end
end
 
% Save as .mat file
save ImageFileSummary summary_table
