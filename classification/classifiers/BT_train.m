function model = BT_train(data,classes,param)

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
    model = fitensemble(data,classes,'RobustBoost',param(2),'tree');
else
    model = fitensemble(data,classes,'AdaboostM2',param(2),'tree');
end

