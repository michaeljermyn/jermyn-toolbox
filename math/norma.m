function [y] = norma(x)

% normalizes a vector by mean and standard deviation
%
% x is the input vector
%
% y is the normalized vector

moy=mean(x(:));
std_x=std(x(:));
y=(x-moy)./std_x;
