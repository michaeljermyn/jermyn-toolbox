function model = SVM_train(data,classes,param)

% train classifier
%
% data has each row a single spectrum (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
% param are custom classifier settings
%
% model is the trained classifier


model = fitcsvm(data,classes);

