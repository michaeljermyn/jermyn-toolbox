function volviz(im,lambda,s_factor)

% slices volumes for visualization
% uses code from open source BSD license project by Timo Eckhard
%
% im is a matrix (3D)
% lambda is a set of axis labels for dimension 3: e.g. [400:5:500]
% s_factor is a subsampling factor (improves speed): e.g. 1 or 2


h.view_mode = 0;

if ~exist('lambda','var')
    lambda = 1:size(im,3);
end
if ~exist('s_factor','var')
    s_factor = 1;
end

h.lambda = lambda;
num_bands = size(im,3);

%% subsample image
if s_factor > 1
    im = im(1:s_factor:end,1:s_factor:end,:);
end

%% create figure with ui elements
ss = get(0,'ScreenSize');

fh = figure('units','pixels',...
              'numbertitle','off',...
              'name','Jermyn Toolbox - Volume Visualization',...
              'resize','on',...
              'toolbar','none',...
              'menubar','none',...
              'Position',[50 50 ss(3)-240 ss(4)-150]);
set(fh,'color','white');

%% create toolbar
im_width = size(im,1);
h.average_options = round([im_width/100 im_width/40 im_width/20]);

uitoolbar(fh);

%load zoom icons and normalize to range 0-1
icon1 = fullfile(matlabroot,'toolbox','matlab','icons','tool_zoom_in.png');
icon2 = fullfile(matlabroot,'toolbox','matlab','icons','tool_zoom_out.png');
cdata1 = double(imread(icon1))./(2^16-1);
cdata2 = double(imread(icon2))./(2^16-1);

%set black background transparent
cdata1(cdata1==0) = NaN;
cdata2(cdata2==0) = NaN;

%create rect icons
cdata3 = NaN([16 16 3]);
cdata4 = cdata3;
cdata5 = cdata3;
cdata6 = cdata3;

cdata3(7:end-5,7:end-6,:) = 0;
cdata4(5:end-3,5:end-4,:) = 0;
cdata5(3:end-1,3:end-2,:) = 0;
cdata6(2:end-0,2:end-1,:) = 0;

%assign zoom in to toolbar
h.h_zin = uitoggletool('cdata',cdata1,'tooltip','zoom in',...
                     'OnCallback',@ZoomInFcnCB,...
                     'OffCallback',@ZoomOffFcnCB);
%assign zoom out to toolbar
h.h_zout = uitoggletool('cdata',cdata2,'tooltip','zoom out',...
                     'OnCallback',@ZoomOutFcnCB,...
                     'OffCallback',@ZoomOffFcnCB);
%assign average tool to toolbar
h.average = h.average_options(1);
h.avg0 = uitoggletool('cdata',cdata3,'tooltip','no average - display one pixel','State','off',...
                     'OnCallback',@Avg0FcnCB,'Separator','On');
h.avg1 = uitoggletool('cdata',cdata4,'tooltip','average rectangle size 1/100 of image width','State','on',...
                     'OnCallback',@Avg1FcnCB);
h.avg2 = uitoggletool('cdata',cdata5,'tooltip','average rectangle size 1/40 of image width','State','off',...
                     'OnCallback',@Avg2FcnCB);
h.avg3 = uitoggletool('cdata',cdata6,'tooltip','average rectangle size 1/20 of image width','State','off',...
                     'OnCallback',@Avg3FcnCB);

clear icon1 icon2 cdata1 cdata2 cdata3 cdata4 cdata5;


%% create UI elements in figure
hp1 = uipanel('Title','Image','FontSize',12,...
             'BackgroundColor',[1 1 1],...
             'Position',[.01 .01 0.48 .98]);

h.haxp1 = axes('Units','normal', 'Position', [.05 .05 .92 .86], 'Parent', hp1,'Tag','ImageAxis');

h.hSlider = uicontrol('style','slider',...
                    'units','normalized',...
                    'min',1,...
                    'max',num_bands,...
                    'val',1,...
                    'SliderStep',[1/num_bands,1/num_bands],...
                    'Position',[.01 .97 .93 .04],...
                    'Parent',hp1);

h.hSliderText = uicontrol('Style','text','String','1',...
               'FontWeight','bold',...
               'units','normalized',...
               'HorizontalAlignment','left',...
               'Position',[.95 .967 .04 .04],...
               'BackgroundColor',[1 1 1],...
               'Parent',hp1);    

set(h.hSliderText,'String',lambda(1));
                
addlistener(h.hSlider,'ContinuousValueChange',@sliderCB);

hp2 = uipanel('Title','Spectrum','FontSize',12,...
             'BackgroundColor',[1 1 1],...
             'Position',[.51 .01 0.48 .98]);         
         
h.haxp2 = axes('Units','normal', 'Position', [.07 .05 .87 .9], 'Parent', hp2);

h.hT = uicontrol('Style','text','String','',...
               'FontWeight','bold',...
               'HorizontalAlignment','center',...
               'units','normalized',...
               'Position',[0 .01 1 .05],...
               'BackgroundColor',[1 1 1],...
               'Parent',hp1);
clear hp1 hp2;


%% load first image plane
set(gcf, 'currentaxes',h.haxp1);

imagesc(im(:,:,1)),colorbar;
caxis([min(im(:)) max(im(:))]);


%% add a dragable rectangle
ip_pos = [size(im,2)/2,size(im,1)/2];
h.imrect = imrect(h.haxp1,[ip_pos(1) ip_pos(2) h.average h.average]);
setResizable(h.imrect,0);
setColor(h.imrect,[1 0 0]);
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h.imrect,fcn); 
clear ip_pos;

%plot the corresponding spectra in axis 2
pos = round(getPosition(h.imrect));
av_area = im(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:);
avg_spectra = mean(mean(av_area,1),2);
avg_spectra = avg_spectra(:);
h.plot_curve_handle = plot(h.haxp2,lambda,avg_spectra);hold(h.haxp2,'on');
h.plot_point_handle = plot(h.haxp2,lambda(1),avg_spectra(1),'xr','linewidth',2);
grid(h.haxp2,'on');

%plot the corresponding location text
str = ['Location: (',num2str(pos(1)),',',num2str(pos(2)),')   Value: (',num2str(im(pos(2),pos(1),1)),')'];
set(h.hT,'String',str);


%% some additional callbacks
if h.view_mode == 1
    addNewPositionCallback(h.imrect,@update_imrect);
    set(h.haxp1,'ButtonDownFcn',@update_imrect);
    set(get(h.haxp1,'Children'),'ButtonDownFcn',@update_imrect);
elseif h.view_mode == 0
    set(fh,'WindowButtonUpFcn',{@figure_button_up,h.haxp1});
end


%% set the appdata
setappdata(fh,'h',h);
setappdata(fh,'im',im);


%% redraw the figure
set(fh,'ResizeFcn',@ResizeFcnCB);
ResizeFcnCB();

end


%% callbacks

%for the average buttons
function Avg0FcnCB(varargin)
    hh = getappdata(gcf,'h');
    
    %switch the other buttons off
    set(hh.avg1,'State','off');
    set(hh.avg2,'State','off');
    set(hh.avg3,'State','off');
    
    %set rectangle to correct size
    hh.average = 1;
    pos = getPosition(hh.imrect);
    setConstrainedPosition(hh.imrect,[pos(1),pos(2),hh.average,hh.average]);
    
    setappdata(gcf,'h',hh);
end
function Avg1FcnCB(varargin)
    hh = getappdata(gcf,'h');
    
    %switch the other buttons off
    set(hh.avg0,'State','off');
    set(hh.avg2,'State','off');
    set(hh.avg3,'State','off');
    
    %set rectangle to correct size
    hh.average = hh.average_options(1);
    pos = getPosition(hh.imrect);
    setConstrainedPosition(hh.imrect,[pos(1),pos(2),hh.average,hh.average]);
    
    setappdata(gcf,'h',hh);
end
function Avg2FcnCB(varargin)
    hh = getappdata(gcf,'h');
    
    %switch the other buttons off
    set(hh.avg0,'State','off');
    set(hh.avg1,'State','off');
    set(hh.avg3,'State','off');

    %set rectangle to correct size
    hh.average = hh.average_options(2);
    pos = getPosition(hh.imrect);
    setConstrainedPosition(hh.imrect,[pos(1),pos(2),hh.average,hh.average]);
    
    setappdata(gcf,'h',hh);
end
function Avg3FcnCB(varargin)
    hh = getappdata(gcf,'h');
    
    %switch the other buttons off
    set(hh.avg0,'State','off');
    set(hh.avg1,'State','off');
    set(hh.avg2,'State','off');

    %set rectangle to correct size
    hh.average = hh.average_options(3);
    pos = getPosition(hh.imrect);
    setConstrainedPosition(hh.imrect,[pos(1),pos(2),hh.average,hh.average]);
    
    setappdata(gcf,'h',hh);
end

%for the zoom buttons
function ZoomInFcnCB(varargin)
    hh = getappdata(gcf,'h');
    set(hh.h_zout,'State','off');
    h_zinobj = zoom(gcf);
    set(h_zinobj,'Enable','on','Direction','In');
end
function ZoomOutFcnCB(varargin)
    hh = getappdata(gcf,'h');
    set(hh.h_zin,'State','off');
    h_zoutobj = zoom(gcf);
    set(h_zoutobj,'Enable','on','Direction','Out');
end
function ZoomOffFcnCB(varargin)
    zoom off;
end





%--------------------------------------------------------------------------
%the slider callback
function sliderCB(varargin)
    hh = getappdata(gcf,'h');
    im = getappdata(gcf,'im');
    %get the current imrect location
    pos_imrect = getPosition(hh.imrect);
    %get the current zoom info (xlim,ylim);
    hh.xlim = get(gca,'xlim');
    hh.ylim = get(gca,'ylim');
    %assign new image according to slider position
    new_step = round(get(hh.hSlider,'value')/1)*1;
    imagesc(im(:,:,new_step)),colorbar;
    caxis([min(im(:)) max(im(:))]);
    %restore the previous zoom position
    set(gca,'xlim',hh.xlim);
    set(gca,'ylim',hh.ylim);
    %assign a new slider text
    set(hh.hSliderText,'String',hh.lambda(new_step));
    %add the image rect again
    hh.imrect = imrect(hh.haxp1,pos_imrect);
    setResizable(hh.imrect,0);
    setColor(hh.imrect,[1 0 0]);
    fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
    setPositionConstraintFcn(hh.imrect,fcn); 
    if hh.view_mode == 1
        addNewPositionCallback(hh.imrect,@update_imrect);
        set(hh.haxp1,'ButtonDownFcn',@update_imrect);
        set(get(hh.haxp1,'Children'),'ButtonDownFcn',@update_imrect);
    end
    %update location text
    pos = round(getPosition(hh.imrect));
    avg_spectra = get(hh.plot_curve_handle,'YData');
    cur_val = avg_spectra(new_step);
    str = ['Location: (',num2str(pos(1)),',',num2str(pos(2)),')   Value: (',num2str(cur_val),')'];
    set(hh.hT,'String',str);
    %replace current band point on axis 2 by new one
    lambda = get(hh.plot_curve_handle,'XData');
    set(hh.plot_point_handle,'XData',lambda(new_step));
    set(hh.plot_point_handle,'YData',cur_val);
    setappdata(gcf,'h',hh);    
end

%--------------------------------------------------------------------------





%what to do when the figure is resized
function ResizeFcnCB(varargin)
    hh = getappdata(gcf,'h');
 
    %fix the height of the slider
    set(hh.hSlider,'units','pixels');
    pSl = get(hh.hSlider, 'Position');
    set(hh.hSlider, 'Position', [pSl(1) pSl(2) pSl(3) 20]);
    set(hh.hSlider,'units','normalized');
    %fix the height of the slider text
    set(hh.hSliderText,'units','pixels');
    pSl = get(hh.hSliderText, 'Position');
    set(hh.hSliderText, 'Position', [pSl(1) pSl(2) pSl(3) 20]);
    set(hh.hSliderText,'units','normalized');
    
    %fix the height of the axis1
    set(hh.haxp1,'units','pixels');
    pPa = get(hh.haxp1, 'Position');
    min_p1 = 70;                                            %minimal y location for panel 1. Reserves space for slider and text
    set(hh.haxp1, 'Position', [pPa(1) min_p1 pPa(3) pPa(4)]);
    set(hh.haxp1,'units','normalized');

    %fix the height and location of the textbox
    set(hh.hT,'units','pixels');
    pT = get(hh.hT, 'Position');
    set(hh.hT, 'Position', [0 0.01 pT(3) 20]);
    set(hh.hT,'units','normalized');     
    
    %add a new position constraint for the imrect
    fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
    setPositionConstraintFcn(hh.imrect,fcn); 
    
    setappdata(gcf,'h',hh);
end

%this callback function is used to redraw the plot in axis 2 when the mousebutton goes up.
function figure_button_up(varargin)
    update_imrect();
end

%image rect update function
function update_imrect(varargin)
    hh = getappdata(gcf,'h');
    im = getappdata(gcf,'im');
    
    %position of last click in axis 1
    pos_imrect = round(get(hh.haxp1,'currentpoint'));
    pos_imrect = pos_imrect(1,1:2);
    
    %check if the clicked position is in the axis 1 ...
    xl = get(hh.haxp1,'XLim');
    yl = get(hh.haxp1,'YLim');
    if pos_imrect(1) >= xl(1) && pos_imrect(1) <= xl(2) && ...
        pos_imrect(2) >= yl(1) && pos_imrect(2) <= yl(2)

        %replace the imrect to new loacation
        setConstrainedPosition(hh.imrect,[pos_imrect,hh.average,hh.average]);

        %compute average region
        pos = round(getPosition(hh.imrect));
        av_area = im(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3),:);
        avg_spectra = mean(mean(av_area,1),2);
        avg_spectra = avg_spectra(:);
        
        %update location text
        new_step = round(get(hh.hSlider,'value')/1)*1;
        cur_val = avg_spectra(new_step);
        str = ['Location: (',num2str(pos(1)),',',num2str(pos(2)),')   Value: (',num2str(cur_val),')'];
        set(hh.hT,'String',str);
        
        %plot average reflectance over imrect area in axes 2
        lambda = get(hh.plot_curve_handle,'XData');
        set(hh.plot_curve_handle,'YData',avg_spectra);
        set(hh.plot_point_handle,'XData',lambda(new_step));
        set(hh.plot_point_handle,'YData',cur_val);
        
        setappdata(gcf,'h',hh);
    end
end
