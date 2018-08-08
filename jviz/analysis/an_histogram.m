function an_histogram(inputs, outputs)

% analysis
%
% inputs is a matrix
% outputs is a matrix


% infer classes
[classes, uclasses, nclasses] = findclasses(inputs, outputs);

% histogram
myfig(6,8);
for i=1:nclasses
    cdata = inputs(uclasses(i)==classes,:,:,:,:,:);
    h = histogram(cdata(:),30,'FaceAlpha',0.2);
    hold on
end
set(gca,'yscale','log');

% save to workspace variable
assignin('base', 'jviz_histogram', h);
