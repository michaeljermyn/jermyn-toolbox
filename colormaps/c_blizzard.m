function cmap = c_blizzard()
% Custom colormap
%
% cmap is the colormap


% base colors
T = [0,   0,   0            % black
     0, 63,  84             % dark blue
     79, 160, 214           % blue
     181, 228, 247        	% light blue
     255, 255, 255]./255;   % white

% color ranges
x = [0,70,150,200,255];

% linear mapping
cmap = interp1(x/255,T,linspace(0,1,255));