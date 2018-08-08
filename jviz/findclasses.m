function [classes,uclasses,nclasses] = findclasses(inputs, outputs)

% find classes in output matrix
%
% outputs is a matrix


if (size(outputs,1) == size(inputs,1))
    classes = outputs(:,1);
elseif (size(outputs,2) == size(inputs,1))
    classes = outputs(1,:)';
else
    classes = ones(size(inputs,1),1);
end

nclasses = length(unique(classes));
if (nclasses > 10)
    classes = kmeans(classes,10);
end

uclasses = unique(classes);
nclasses = length(uclasses);