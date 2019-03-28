positive_ins = pos_roi;

neg_folder = 'Negative_Images';
if ~exist(neg_folder, 'dir')
    mkdir(neg_folder);
end
formatStr = 'neg%d.jpg';   % Output format for negatives
for i=1022:size(pos_roi,1)
 img = imread(pos_roi.imageFilename{i});
 imcropped = imcrop(img,[1 1 1078 670]); % Crop
 fileName = sprintf(formatStr,i);
 imwrite(imcropped,[neg_folder filesep fileName]); % Save negative images
end

neg_dir = fullfile('/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs/Negative_Images');
%%
trainCascadeObjectDetector('trained_model.xml', positive_ins, neg_dir, ...
    'NumCascadeStages', 10, 'FalseAlarmRate',0.03,...
    'FeatureType','LBP');