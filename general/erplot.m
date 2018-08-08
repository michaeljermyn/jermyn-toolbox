function H = erplot(x,y,errBar,lineProps,transparent)

% plot lines with error bars
% uses code from open source project by Rob Campbell
%
% x is the x axis
% y is a vector/matrix of the lines to be plotted
% errBar is the vector of errors
% lineProps are the matlab line properties
% transparent is optional (1 or 0)
%
% H is the graph handle   


if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:)';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:)';
end


% error bars
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end

%Set default options
defaultProps={'-k'};
if nargin<4, lineProps=defaultProps; end
if isempty(lineProps), lineProps=defaultProps; end
if ~iscell(lineProps), lineProps={lineProps}; end

if nargin<5, transparent=0; end
  
% Plot to get the parameters of the line 
H.mainLine=plot(x,y,lineProps{:});

% Work out the color of the shaded region and associated lines
col=get(H.mainLine,'color');
edgeColor=col+(1-col)*0.55;
patchSaturation=0.15; %How de-saturated or transparent to make patch
if transparent
    faceAlpha=patchSaturation;
    patchColor=col;
    set(gcf,'renderer','openGL')
else
    faceAlpha=1;
    patchColor=col+(1-col)*(1-patchSaturation);
    set(gcf,'renderer','painters')
end

%Calculate the error bars
uE=y+errBar(1,:);
lE=y-errBar(2,:);

%Add the patch error bar
holdStatus=ishold;
if ~holdStatus, hold on,  end

%Make the patch
yP=[lE,fliplr(uE)];
xP=[x,fliplr(x)];

%remove nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];

H.patch=patch(xP,yP,1,'facecolor',patchColor,...
              'edgecolor','none',...
              'facealpha',faceAlpha);

%Make pretty edges around the patch. 
H.edge(1)=plot(x,lE,'-','color',edgeColor);
H.edge(2)=plot(x,uE,'-','color',edgeColor);

%Now replace the line (this avoids having to bugger about with z coordinates)
delete(H.mainLine)
H.mainLine=plot(x,y,lineProps{:});

% deactive legend entries
set(get(get(H.patch,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
set(get(get(H.edge(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
set(get(get(H.edge(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
set(get(get(H.mainLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','on')

if ~holdStatus, hold off, end

if nargout==1
    varargout{1}=H;
end
