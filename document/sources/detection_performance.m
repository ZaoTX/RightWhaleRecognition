extraFolder = 'needToTrain';
extraFolder2 = 'experiment_result_0_003_modifyCode';
pos_roi = imageDatastore('imgs_subset_rotate'); % Folder that contains whale images to detect
for i=1:10
    img = imread(pos_roi.Files{i});
%     img =
%     imread('/Users/jubin/Matlab/all/imgs/imgs_train_whaleIDs/imgs_subset_rotate/w_105.jpg');
    img_ratio = 0.3;
    if size(img, 1) > size(img, 2) % 이미지가 세로일 경우
       img2 = imresize(img, img_ratio);
    else % 이미지가 이미지가 가로일 경우
       img_ratio = img_ratio + 0.1;
       img2 = imresize(img, img_ratio);
    end
    
    detector = vision.CascadeObjectDetector('trained_model.xml');
    bbox_history = [];
    counter = 0;
    
    while 1
        bbox = step(detector, img2);
        if counter > 3 & size(bbox, 1) ~= 0
            break
        elseif counter > 3 & size(bbox, 1) == 0
            img_ratio = img_ratio + 0.1;
            img2 = imresize(img, img_ratio);
            bbox = step(detector, img2);
            break
        elseif counter > 4
            break
        end
        if size(bbox, 1) >= 3
            img_ratio = img_ratio - 0.1;
            img2 = imresize(img, img_ratio);
            bbox_history = cat(1, bbox_history, size(bbox, 1));
            counter = counter + 1;
            
        elseif size(bbox, 1) == 0
            img_ratio = img_ratio + 0.1;
            img2 = imresize(img, img_ratio);
            bbox_history = cat(1, bbox_history, size(bbox, 1));
            counter = counter + 1;
        else
            break
        end
    end
        
    detectedImg = insertObjectAnnotation(img2, 'rectangle', bbox, 'head');
    
    imshow(detectedImg);
    formatStr2 = 'exp0_with_modifying_%d.jpg';
%     fileName2 = sprintf(formatStr2, i);
%     imwrite(detectedImg, [extraFolder2 filesep fileName2]); % This part
%     for saving the cropped image
%     title(pos_roi.Files{i});
end