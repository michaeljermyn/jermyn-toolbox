function f = myfig(height,width)
% creates a figure with specified size
%
% height is the height in inches
% width is the width in inches

f = figure;
set(gcf,'color','white');
set(gcf, 'units', 'inches', 'position', [0.5 0.5 width height]) % L B W H
set(gca,'Position',[.15 .15 .8 .8]);

% other options:
% set(gca, 'box', 'off');
% set(gca,'YTick',[])
% set(gca,'YColor','w')