function loss = imageCategorical_loss(mdl, imds)

[~, KnownlabelIdx, PredictedlabelIdx, ~] = evaluate(mdl, imds);

loss = mean(double(KnownlabelIdx ~= PredictedlabelIdx));

end
