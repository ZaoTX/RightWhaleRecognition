
%% this step shows us how to find a good method to do deblurring
%Deblurring Images

dataFolder = uigetdir(cd,'select folder containing training images');
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');

c = numel(imds.Files);
%for i = 1:c
I = readimage(imds,34);
figure;imshow(I);title('Original Image');
pause;
I = rgb2gray(I);
figure;imshow(I);title('Grey Scale');
pause;
% text(size(I,2),size(I,1)+15, ...
%     'Image courtesy of Massachusetts Institute of Technology', ...
%     'FontSize',7,'HorizontalAlignment','right');
%pause;
 PSF = fspecial('gaussian',7,10);
 Blurred = imfilter(I,PSF,'symmetric','conv');
% figure;
% imshow(Blurred);
% title('Blurred Image');
% pause;
%first deblurring method
UNDERPSF = ones(size(PSF)-4);
[J1,P1] = deconvblind(I,UNDERPSF);
figure;
imshow(J1);
title('Deblurring with Undersized PSF');
pause;
%second deblurring method
% OVERPSF = padarray(UNDERPSF,[4 4],'replicate','both');
% [J2,P2] = deconvblind(I,OVERPSF);
% figure;imshow(J2);
% title('Deblurring with Oversized PSF');
% pause;
%third deblurring method(We use this at first)
INITPSF = padarray(UNDERPSF,[2 2],'replicate','both');
[J3,P3] = deconvblind(I,INITPSF);
figure;imshow(J3);
title('Deblurring with INITPSF');
pause;
% improve 1
WEIGHT = edge(Blurred,'sobel',.05);
se = strel('disk',2);
WEIGHT = 1-double(imdilate(WEIGHT,se));
WEIGHT([1:3 end-(0:2)],:) = 0;
WEIGHT(:,[1:3 end-(0:2)]) = 0;
figure
imshow(WEIGHT);
title('Weight Array');
pause;
% improve 2
[J,P] = deconvblind(I,INITPSF,30,[],WEIGHT);
figure;imshow(J)
title('Deblurred Image');
P1 = 2;
P2 = 2;
FUN = @(PSF) padarray(PSF(P1+1:end-P1,P2+1:end-P2),[P1 P2]);
[JF,PF] = deconvblind(Blurred,OVERPSF,30,[],WEIGHT,FUN);
figure;imshow(JF);
title('Deblurred Image');
%end