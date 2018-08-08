function [pred,scores] = RF_predict(model,data)

% predict classes
%
% model is the trained classifier
% data has each row a single spectrum (#spectra x #features)
%
% pred are the predicted classes
% scores are the classifier scores


[pred,scores] = predict(model,data);

