function [pred,scores] = BT_regression_predict(model,data)

% predict classes
%
% model is the trained classifier
% data has each row a single spectrum (#spectra x #features)
%
% pred are the predicted classes
% scores are the classifier scores


[pred] = predict(model,data);
scores = [pred pred];
