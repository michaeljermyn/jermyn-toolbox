function output = classifycv(data,classes,options)

% cross validated classification
%
% data has each row a single spectrum (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
% options are classification settings (all optional):
%       options.classifier is the classification method to use,
%           e.g. 'SVM','LDA','RF','BT','NN','CNN'...
%           'SVM' is the default for 1D
%           'CNN' is the default for 2D
%       options.numfolds is the number of folds to use for
%           cross validation, default is 8
%       options.partition is a custom partition indicating which fold
%           each sample is in, vector the size of classes
%       options.featureselection is the feature selection method,
%           'MRMR' is the default
%       options.features is a custom ordered features vector
%       options.params are custom parameters for the specific classifier,
%           the 1st element is always the number of features to use,
%           the 2nd element is often the complexity (number of nodes/trees)
%           e.g. {200,20}
%       options.hideprogress will hide the progress bar if it is 1
%       options.matching will match sample sizes for different classes if 1
%
% output.acc is the classification accuracy
% output.accmean is the average per-class accuracy
% output.sen is the sensitivity
% output.spe is the specificity
% output.pred are the predicted classes
% output.scores are the classification scores
% output.data is the original data
% output.classes is the original classes
% output.classifier is the classification method used
% output.params are the parameters used
% output.iparams is the expanded parameter list
% output.paccs are the average accuracies for each parameter set
% output.features are the ordered features by importance


uclasses = unique(classes);
nclasses = length(uclasses);

% sample size matching
if ~isfield(options,'matching')
    options.matching = 0;
end
if (options.matching)
    % create new data/classes
    data_new = [];
    classes_new = [];
    partition_new = [];
    
    % find smallest sample size class
    m = length(classes);
    for i=1:length(uclasses)
        n_cur = sum(classes==uclasses(i));
        if (n_cur < m)
            m = n_cur;
        end
    end
    
    % loop through classes
    for i=1:length(uclasses)
        classes_tmp = classes(classes==uclasses(i));
        
        % randomly sample the smallest sample size
        [data_tmp,idx] = datasample(data(classes==uclasses(i),:),m,1,'Replace',false);
        classes_new = [classes_new; classes_tmp(idx)];
        data_new = [data_new; data_tmp];
        if (isfield(options,'partition'))
            partition_tmp = options.partition(classes==uclasses(i));
            partition_new = [partition_new; partition_tmp(idx)]; 
        end
    end
    
    % copy over new data/classes
    data = data_new;
    classes = classes_new;
    if (isfield(options,'partition'))
        options.partition = partition_new;
    end
end

nsamples = length(classes);

% check other inputs
for i=1:length(uclasses)
    if sum(classes==uclasses(i)) < 15
        errordlg('Not enough data for classification','Jermyn Toolbox');
    end
end
if size(data,1) < 40
    errordlg('Not enough data for classification','Jermyn Toolbox');
end
if isrow(classes)
    classes = classes';
end
if ~exist('options','var')
    options.classifier = 'SVM';
end
if ~isfield(options,'numfolds')
    options.numfolds = 8;
end
if ~isfield(options,'featureselection')
    options.featureselection = 'MRMR';
end
if isfield(options,'classifier') && strcmp(options.classifier,'SVM') && nclasses > 2
    disp('SVM does not support multiclass problems, using LDA instead.');
    options.classifier = 'LDA';
end
if length(size(data)) == 2 && isfield(options,'classifier') && strcmp(options.classifier,'CNN')
    disp('CNN only supports image classification, using LDA instead.');
    options.classifier = 'LDA';
end
if ~isfield(options,'params')
    if size(data,2) > 31
        increm = floor(size(data,2)/15);
        prange = [1 2 4 8 10 20 30 40 80];
    else
        increm = 1;
        prange = 1:size(data,2);
    end
    
    if isfield(options,'classifier') && (strcmp(options.classifier,'BT') || ...
            strcmp(options.classifier,'RF') || ...
            strcmp(options.classifier,'NN'))
        options.params = {size(data,2),prange};
    else
        if length(size(data)) == 2
            options.params = {1:increm:size(data,2)};
        else
            options.params = {1};
        end
    end
end
hideprogress = 0;
if isfield(options,'hideprogress')
    if options.hideprogress
        hideprogress = 1;
    end
end

% determine cross validation partition
if ~isfield(options,'partition')
    if options.numfolds == nsamples
        % LOOCV
        options.partition = 1:nsamples; 
    else
        % k fold
        options.partition = crossvalind('Kfold',nsamples,options.numfolds); 
    end
end

% feature importance
if isfield(options,'features')
    features = options.features;
else
    if length(size(data)) == 2
        features = eval([options.featureselection '(data,classes);']);
    else
        features = 0;
    end
end
options.features = features;

% recursion if all classifiers
if ~isfield(options,'classifier')
    cf = {'SVM','LDA','RF','NN','BT'};
    out = {};
    acc = 0;
    options = rmfield(options,'params');
    for i=1:size(cf,2)
        options.classifier = cf{i};
        out{i} = classifycv(data,classes,options);
        if out{i}.acc > acc
            output = out{i};
            acc = output.acc;
        end
    end
    return;
end

% create parameter set
Sparams = options.params;
pstring1 = '';
pstring2 = '';
for i=1:size(Sparams,2)
    pstring1 = [pstring1 'ndd{' num2str(i) '} '];
    pstring2 = [pstring2 'ndd{' num2str(i) '}(:) '];
end
eval(['[' pstring1 '] = ndgrid(Sparams{:});']);
eval(['options.params = [' pstring2 ']'';']);

% parameter search
nparams = size(options.params,2);

if nparams == 1
    hideprogress = 1;
end
if ~hideprogress
    h = waitbar(0,'Parameter Search');
end

output.paccs = zeros(1,size(options.params,2));
output.paucs = zeros(1,size(options.params,2));
for p = 1:nparams
    
    % feature selection
    if length(size(data)) == 2
        fdata = data(:,sort(features(1:options.params(1,p))));
    else
        fdata = data;
    end

    % cross validated classification
    folds = unique(options.partition);
    for fold=1:length(folds)
        ind = (options.partition == folds(fold));
        model = eval([options.classifier ...
            '_train(fdata(~ind,:,:,:),classes(~ind),options.params(:,p))']);
        [PR,SC] = eval([options.classifier ...
            '_predict(model,fdata(ind,:,:,:))']);
        pred{p}(ind,:) = PR;
        scores{p}(ind,:) = SC;
    end
    
    output.paccs(p) = 100*sum(classes==pred{p})/nsamples;

    if ~hideprogress
        waitbar(p/nparams,h, ...
            ['Parameter Search (' num2str(p) '/' num2str(nparams) ')']);
    end

end

if ~hideprogress
    close(h);
end

% performance metrics
[output.acc,mind] = max(output.paccs);
output.pred = pred{mind};
output.scores = scores{mind};

accs = zeros(1,nclasses);
for i=1:nclasses
    accs(i) = 100*sum(uclasses(i)==output.pred(classes==uclasses(i)))/ ...
        sum(classes==uclasses(i));
end
output.accmean = sum(accs)/nclasses;

nor = min(classes);
dis = max(classes);
if nclasses == 2
    TP = length(find(intersect(find(output.pred==classes),find(classes~=nor))));
    TN = length(find(intersect(find(output.pred==classes),find(classes==nor))));
    NP = length(find(classes~=nor));
    NN = length(find(classes==nor));
    output.sen = 100*TP/NP;
    output.spe = 100*TN/NN;
else
    output.sen = NaN;
    output.spe = NaN;
end

% outputs
output.data = data;
output.classes = classes;
output.classifier = options.classifier;
output.params = options.params(:,mind)';
output.iparams = options.params;
output.features = features;

