function viz_erplot(inputs, outputs)

% visualization
%
% inputs is a matrix
% outputs is a matrix


% check dimensions
inputs = inputs(:,:,1);

% infer classes
[classes, uclasses, nclasses] = findclasses(inputs, outputs);

% class colors
colors = {[0 0 0],[0.9 0 0],[0.22 0.60 1],[0.18 0.68 0], ...
    [0.87 0.56 0.87],[0.07 0.25 0.54],[1 0.75 0.29],[0 1 0.82], ...
    [0.5 0.05 0.54],[1 1 0]};

% plot error lines
nfeat = size(inputs,2);
for i=1:nclasses
    y = inputs(uclasses(i)==classes,:);
    erplot(1:nfeat,y,{@mean,@std},{'Color',colors{i},'LineWidth',1},1);
end

legend(num2str(uclasses));
