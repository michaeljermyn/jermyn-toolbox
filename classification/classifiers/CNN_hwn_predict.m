function [pred,scores] = CNN_hwn_predict(model,data)

% predict classes
%
% model is the trained classifier
% data has each row a single spectrum (#spectra x #features)
%
% pred are the predicted classes
% scores are the classifier scores


data = permute(data,[2,3,4,1]);

scores = predict(model,data);
pred = double(classify(model,data));