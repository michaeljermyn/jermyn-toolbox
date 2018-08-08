function filt_permute(inputs, outputs)

% filter
%
% inputs is a matrix
% outputs is a matrix


% ask order
prompt = {'Dimension order:'};
dlg_title = 'Input';
num_lines = 1;
def = {['[' num2str(1:length(size(inputs))) ']']};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% permute
inputs = permute(inputs,str2num(answer{1}));

% save to workspace variable
assignin('base', 'jviz_permute', inputs);
