%% Test the performance for 1 image
% 
% img = readimage(val,2);
% 
% [pred,scrs] = classify(whalenet,img);
%% Test the performance for the whole test set
% you can run this section to measure the performance in test set
load('whalenetSgdm0.001.mat')
% this line can be change to
% val.ReadFcn =  @(loc)imresize(imread(loc),inputSize(1:2));
val.ReadFcn =  @(loc)imresize(imread(loc),[227 227]);
[preds,scores] = classify(whalenet,test);
Actuals = test.Labels;
numCorrect = nnz(preds == Actuals);
fracCorrect = numCorrect/numel(preds);

%confusionchart(val.Labels,preds)
%% Using for loop
 
for i=1:numel(preds)
    %confusionchart(val.Labels(i),preds(i));
    charAct = char(Actuals(i));
    charPred = char(preds(i));
    fprintf('the actual whaleID is:\n',charAct);
    fprintf(charAct);
    fprintf('\n');
    fprintf('our prediction is:\n',charPred);
    fprintf(charPred);
     fprintf('\n');
    pause;
end