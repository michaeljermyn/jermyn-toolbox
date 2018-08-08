function model = BT_regression_train(data,classes,param)

% train classifier
%
% data has each row a single spectrum (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
% param are custom classifier settings
%
% model is the trained classifier


if length(param)<2
    param(2) = 5;
end

nclasses = length(unique(classes));
if nclasses == 2
    model = fitrensemble(data,classes);
else
    model = fitrensemble(data,classes);
end

