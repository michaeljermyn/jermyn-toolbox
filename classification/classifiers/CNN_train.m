function model = CNN_train(data,classes,param)

% train classifier
%
% data has each row a single spectrum/image (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
% param are custom classifier settings
%
% model is the trained classifier


nclasses = length(unique(classes));

% max epochs
if length(param)<2
    param(2) = 90;
end

% mini batch size
if length(param)<3
    param(3) = 70;
end

% initial learn rate
if length(param)<4
    param(4) = 0.01;
end

data = permute(data,[2,3,4,1]);

% network structure
layers = [imageInputLayer([size(data,1) size(data,2) size(data,3)],'Normalization','none');
          convolution2dLayer(4,16);
          reluLayer();
          maxPooling2dLayer(2,'Stride',2);
          convolution2dLayer(5,12);
          reluLayer();
          maxPooling2dLayer(2,'Stride',2);
          fullyConnectedLayer(40);
          reluLayer();
          fullyConnectedLayer(nclasses);
          softmaxLayer();
          classificationLayer()];

% train network
opts = trainingOptions('sgdm','InitialLearnRate',param(4), ...
    'MaxEpochs',param(2),'MiniBatchSize',param(3));
model = trainNetwork(data,nominal(classes),layers,opts);

