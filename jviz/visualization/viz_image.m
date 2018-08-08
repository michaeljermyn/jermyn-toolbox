function viz_image(inputs, outputs)

% visualization
%
% inputs is a matrix
% outputs is a matrix


% check dimensions
inputs = inputs(:,:,1);

imshow(inputs, [min(inputs(:)) max(inputs(:))]);

% colormap
cmap = getpref('jviz','colormap');
colormap(eval(cmap));