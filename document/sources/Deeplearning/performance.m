%% Test the performance for 1 image
% 
% img = readimage(val,2);
% 
% [pred,scrs] = classify(whalenet,img);
%% Test the performance for the whole validation set

[preds,scores] = classify(whalenet,val);
Actuals = val.Labels;
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