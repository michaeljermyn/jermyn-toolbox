function model = NN_train(data,classes,param)

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

model = feedforwardnet(param(2));
nnclasses = full(ind2vec(classes'));
model.trainFcn = 'trainscg';
model.trainParam.showWindow = false;
model.trainParam.showCommandLine = false; 

if (gpuDeviceCount>0)
    model = train(model,data',nnclasses,'useGPU','yes');
else
    model = train(model,data',nnclasses);
end

