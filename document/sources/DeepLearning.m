

% set the options
opts = trainingOptions('sgdm','InitialLearnRate',0.001);
[whalenet,info] = trainNetwork(train,layers,opts);

%% compute TrainingLoss
plot(info.TrainingLoss);