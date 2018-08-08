function features = MRMR(data,classes)

% feature selection - minimum redundancy maximum relevance
% uses code from open source project by Nguyen Xuan Vinh
%
% data has each row a single spectrum (#spectra x #features)
% classes is the true class of each spectra (#spectra x 1)
%
% features are ordered by importance


% discretize data
a = myQuantileDiscretize(data,70);
C = classes;

% calculate MRMR
maxFeature=size(a,2);
H=computeMImatrix_4([a C]);
f=H(1:end-1,end);
H=H(1:end-1,1:end-1);
features = mrmr(H,f,maxFeature);




% supporting functions
% ----------------------------------------

function b = myQuantileDiscretize(a,d)

if nargin<2 
    d=3;
end
[n,dim]=size(a);
b=zeros(n,dim);
for i=1:dim
   b(:,i)=doDiscretize(a(:,i),d);
end
b=b+1;

% ----------------------------------------

function y_discretized = doDiscretize(y,d)

ys=sort(y);
y_discretized=y;
pos=ys(round(length(y)/d *[1:d]));
for j=1:length(y)
    y_discretized(j)=sum(y(j)>pos);
end

% ----------------------------------------

function MRMRFS = mrmr(H,f,maxFeature)
[~,dim]=size(H);
if nargin<3 
    maxFeature=dim;
end
max_MI=0;firstFeature=1;
for i=1:dim
    CMI=f(i);
    if CMI>max_MI
        max_MI=CMI;
        firstFeature=i;
    end
end
best_fs=zeros(1,maxFeature);
best_fs(1)=firstFeature;
selected=zeros(1,dim);
selected(best_fs(1))=1;
for j=2:maxFeature
    max_inc=-inf;
    bestFeature=0;
    for i=1:dim
       if selected(i) 
           continue;
       end
       rel=f(i);       
       red=sum(H(i,best_fs(1:j-1)))/(j-1);
       inc=rel-red;
       if inc>max_inc
           max_inc=inc;
           bestFeature=i;
       end
    end
    best_fs(j)= bestFeature;
    selected(bestFeature)=1;    
end
MRMRFS=best_fs;

