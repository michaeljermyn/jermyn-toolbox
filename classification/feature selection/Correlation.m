function features = Correlation(data,classes)

% feature selection - correlation
%
% data has each row a single spectrum (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
%
% features are ordered by importance, assumes only 2 classes


uclasses = unique(classes);
G1 = data(classes==uclasses(1),:);
G2 = data(classes==uclasses(2),:);

% t-test p-values
[~,p,~,~] = ttest2(G1,G2,'Vartype','unequal');

% sort features by p-values
[~,features] = sort(p,2);