function [fn,pn] = myuigetfile(ext,title)

% Allows the user to browse for a file, remembers last path.
%
% ext is the file extension to look for
% title is the title of the window
% fn is the resulting filename
% pn is the resulting path


% retrieve last used path
if ispref('jbox','lastpath')
    lastpath = getpref('jbox','lastpath');
else
    lastpath = pwd;
end

% get file
[fn,pn] = uigetfile(ext,title,lastpath);

% save path
if pn
    setpref('jbox','lastpath',pn);
end