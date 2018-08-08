function varargout = jclassify(varargin)
% JCLASSIFY MATLAB code for jclassify.fig
%      JCLASSIFY, by itself, creates a new JCLASSIFY or raises the existing
%      singleton*.
%
%      H = JCLASSIFY returns the handle to a new JCLASSIFY or the handle to
%      the existing singleton*.
%
%      JCLASSIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JCLASSIFY.M with the given input arguments.
%
%      JCLASSIFY('Property','Value',...) creates a new JCLASSIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jclassify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jclassify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jclassify

% Last Modified by GUIDE v2.5 31-Oct-2016 10:48:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jclassify_OpeningFcn, ...
                   'gui_OutputFcn',  @jclassify_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before jclassify is made visible.
function jclassify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jclassify (see VARARGIN)

% Choose default command line output for jclassify
handles.output = hObject;

set(hObject,'Name','Jermyn Toolbox - Classification');
set(gcf,'color','white');

% find workspace variables

vars = evalin('base','whos;');

% disable
set(handles.run,'Enable','Off');
set(handles.showdata,'Enable','Off');
set(handles.export,'Enable','Off');
set(handles.features,'Enable','Off');
set(handles.publishfigure,'Enable','Off');
set(handles.normalize,'Enable','Off');
set(handles.errorbars,'Enable','Off');
set(handles.show_mean_spectra,'Enable','Off');
set(handles.xparam,'Enable','Off');
set(handles.yparam,'Enable','Off');
set(handles.dataslider,'Enable','Off');
set(handles.featureselection,'Enable','Off');
set(handles.xaxis,'Enable','Off');

% slider settings
set(handles.dataslider,'min',1);
set(handles.dataslider,'max',100);
set(handles.dataslider,'Value',1);

% data
varnames = {};
[nv,~] = size(vars);
nflag = 2;
varnames{1} = 'Select Data';
for i=1:1:nv
    flag1 = evalin('base',strcat('isnumeric(',vars(i).name,')'));
    if flag1
        flag2 = evalin('base',strcat('size(',vars(i).name,',1)>1'));
        flag3 = evalin('base',strcat('size(',vars(i).name,',2)>1'));
        if flag2 || flag3
            varnames{nflag} = vars(i).name;
            nflag = nflag + 1;
        end
    end
end
if ~isempty(varnames)
    set(handles.data,'String',varnames);
end

% classes
varnames = {};
[nv,~] = size(vars);
nflag = 2;
varnames{1} = 'Select Classes';
for i=1:1:nv
    flag1 = evalin('base',strcat('isnumeric(',vars(i).name,')'));
    if flag1
        flag2 = evalin('base',strcat('size(',vars(i).name,',1)>1'));
        flag3 = evalin('base',strcat('size(',vars(i).name,',2)>1'));
        if xor(flag2,flag3)
            varnames{nflag} = vars(i).name;
            nflag = nflag + 1;
        end
    end
end
if ~isempty(varnames)
    set(handles.classes,'String',varnames);
end

% partition
varnames = {};
[nv,~] = size(vars);
nflag = 2;
varnames{1} = 'Auto';
for i=1:1:nv
    flag1 = evalin('base',strcat('ismatrix(',vars(i).name,')'));
    if flag1
        flag2 = evalin('base',strcat('size(',vars(i).name,',1)>1'));
        flag3 = evalin('base',strcat('size(',vars(i).name,',2)>1'));
        if xor(flag2,flag3)
            varnames{nflag} = vars(i).name;
            nflag = nflag + 1;
        end
    end
end
if ~isempty(varnames)
    set(handles.partition,'String',varnames);
end

% x axis
varnames = {};
[nv,~] = size(vars);
nflag = 2;
varnames{1} = 'Auto';
for i=1:1:nv
    flag1 = evalin('base',strcat('ismatrix(',vars(i).name,')'));
    if flag1
        flag2 = evalin('base',strcat('size(',vars(i).name,',1)>1'));
        flag3 = evalin('base',strcat('size(',vars(i).name,',2)>1'));
        if xor(flag2,flag3)
            varnames{nflag} = vars(i).name;
            nflag = nflag + 1;
        end
    end
end
if ~isempty(varnames)
    set(handles.xaxis,'String',varnames);
end

% find classifiers
solver_loc = what('classifiers');
solvers = dir([solver_loc.path '/*_train.m']);
varnames = {'Auto'};
for i=1:size(solvers)
    varnames{i+1} = solvers(i).name(1:end-8);
end
set(handles.classifier,'String',varnames);

% find feature selection
solver_loc = what('feature selection');
solvers = dir([solver_loc.path '/*.m']);
varnames = {'Auto'};
for i=1:size(solvers)
    varnames{i+1} = solvers(i).name(1:end-2);
end
set(handles.featureselection,'String',varnames);

global featureselection;
featureselection = 'MRMR';



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jclassify wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jclassify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in data.
function data_Callback(hObject, eventdata, handles)
% hObject    handle to data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data

contents = cellstr(get(hObject,'String'));
handles.mydata = evalin('base',contents{get(hObject,'Value')});
temp = handles.mydata(1,:,:,:);
temp = temp(:);
handles.myxaxis = 1:length(temp);
set(handles.xaxis,'Value',1);

% normalize
handles.mydatanorm = handles.mydata;
for i=1:size(handles.mydatanorm,1)
    if size(handles.mydatanorm,2)>1
        handles.mydatanorm(i,:,:,:) = norma(handles.mydatanorm(i,:,:,:));
    else
        handles.mydatanorm(i,:,:,:) = 0;
    end
end

% determine data info
if length(size(handles.mydata)) == 2
    nfeat = size(handles.mydata,2);
else
    nfeat = size(handles.mydata,2)*size(handles.mydata,3)*size(handles.mydata,4);
end
dinfo = {['# Samples: ' num2str(size(handles.mydata,1))], ...
    ['# Features: ' num2str(nfeat)]};
set(handles.datainfo,'String',dinfo);

if isfield(handles,'myclasses') && isfield(handles,'mydata')
    update_data_classes(handles);
    update_graph(handles,0);
    if isfield(handles,'myfeatures')
        handles = rmfield(handles,'myfeatures');
    end
    
    set(handles.normalize,'Enable','On');
    if length(size(handles.mydata)) == 2
        set(handles.errorbars,'Enable','On');
        set(handles.show_mean_spectra,'Enable','On');
        set(handles.features,'Enable','On');
        set(handles.featureselection,'Enable','On');
        set(handles.xaxis,'Enable','On');
    end
end

guidata(hObject, handles);


% --- updates global data and classes
function update_data_classes(handles)

global gdata;
global gclasses;
global mypartition_small;

gdata = [];
gclasses = [];
mypartition_small = [];

contents = cellstr(get(handles.class_select,'String'));
classes = get(handles.class_select,'Value');
numclasses = length(classes);

% create text notes
nfeat = size(handles.mydata,2);
dinfo = {['# Samples: ' num2str(size(handles.mydata,1))], ...
    ['# Features: ' num2str(nfeat)],''};

for i=1:numclasses
    curclass = str2num(contents{classes(i)});
    ind = (handles.myclasses == curclass);
    if get(handles.normalize,'Value')
        y = handles.mydatanorm(ind,:,:,:);
    else
        y = handles.mydata(ind,:,:,:);
    end
    gdata = [gdata; y];
    gclasses = [gclasses; repmat(curclass,size(y,1),1)];
    if isfield(handles,'mypartition')
        mypartition_small = [mypartition_small; handles.mypartition(ind,:)];
    end
    
    % update text notes
    dinfo{3} = [dinfo{3} ' ' contents{classes(i)} ':' ...
        num2str(sum(handles.myclasses==curclass))];
end

% add text notes
set(handles.datainfo,'String',dinfo);

% enable controls
set(handles.run,'Enable','On');
set(handles.showdata,'Enable','On');
set(handles.dataslider,'Enable','On');
set(handles.publishfigure,'Enable','On');

% update slider
set(handles.dataslider,'max',length(gclasses));
set(handles.dataslider,'Value',1);
set(handles.dataslider,'SliderStep',[1/length(gclasses),1/length(gclasses)]);
set(handles.datanum,'String','# 1');




% --- Executes during object creation, after setting all properties.
function data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in classes.
function classes_Callback(hObject, eventdata, handles)
% hObject    handle to classes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classes

contents = cellstr(get(hObject,'String'));
handles.myclasses = evalin('base',contents{get(hObject,'Value')});
if size(handles.myclasses,1) == 1
    handles.myclasses = handles.myclasses';
end
varnames = unique(handles.myclasses);
varnames(isnan(varnames)) = [];
set(handles.class_select,'String',num2str(varnames));
set(handles.class_select,'Value',1:length(varnames));

if isfield(handles,'myclasses') && isfield(handles,'mydata')
    update_data_classes(handles);
    update_graph(handles,0);
    if isfield(handles,'myfeatures')
        handles = rmfield(handles,'myfeatures');
    end

    set(handles.normalize,'Enable','On');
    if length(size(handles.mydata)) == 2
        set(handles.errorbars,'Enable','On');
        set(handles.show_mean_spectra,'Enable','On');
        set(handles.features,'Enable','On');
        set(handles.featureselection,'Enable','On');
        set(handles.xaxis,'Enable','On');
    end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function classes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- update the graph
function update_graph(handles,publish)
    
if publish
    myfig(6,10);
    mywidth = 2;
else
    axes(handles.graph);
    mywidth = 1.5;
end

cla
hold on

global gdata;
global gclasses;
global mypartition_small;

classes = unique(gclasses);
numclasses = length(classes);


if length(size(gdata)) == 2 % spectra

    colors = {'k','r','b','m','g','c','y'};

    % loop through the selected classes
    for i=1:numclasses
        if i<7
            mycol = colors{i};
        else
            mycol = 'k';
        end
        ind = (gclasses == classes(i));
        y = gdata(ind,:);
        
        if get(handles.show_mean_spectra,'Value')
            if get(handles.errorbars,'Value') && length(handles.myxaxis)>1 && size(y,1)>1
                erplot(handles.myxaxis,y,{@mean,@std}, ...
                    {'Color',mycol,'LineWidth',1}, 1);    
            elseif size(y,1)>1
                plot(handles.myxaxis,mean(y,1),mycol,'LineWidth',mywidth);
            else
                plot(handles.myxaxis,y,mycol,'LineWidth',mywidth);
            end
        end
    end
    
    % reverse x axis if needed
    if handles.myxaxis(1) > handles.myxaxis(end)
        set(gca,'xdir','reverse');
    else
        set(gca,'xdir','normal');
    end

    if ~publish && get(handles.show_mean_spectra,'Value')
        legend(num2str(classes));
    end

    % show individual data if active
    if get(handles.showdata,'Value')
        dnum = get(handles.dataslider,'Value');
        y = gdata(dnum,:);
         
        ind = (classes == gclasses(dnum));
        plot(handles.myxaxis,y,colors{ind});
        
        if size(mypartition_small,1) > 1
            ylim = get(gca,'ylim');
            xlim = get(gca,'xlim');
            xpos = xlim(1) + 0.02*(xlim(2)-xlim(1));
            ypos = ylim(2) - 0.05*(ylim(2)-ylim(1));
            text(xpos,ypos,['Partition: ' num2str(mypartition_small(dnum))], ...
                'Color', 'b');
        end
    end
    
    % publish options
    if publish
        set(gca, 'box', 'off');
        set(gca,'YTick',[]);
        set(gca,'YColor','w');
        set(gca,'fontsize',16);
    end

else % images
    
    % show individual data if active
    if get(handles.showdata,'Value')
        dnum = get(handles.dataslider,'Value');
        y = squeeze(gdata(dnum,:,:,:));
        imshow(y);
    else
        imagem = squeeze(mean(gdata,1));
        imshow(imagem);
    end
    
end



% --- create param graph
%function param_graph(handles)

%myfig(5,5);
% cla
% hold on
% paccs = handles.output.paccs;
% iparams = handles.output.iparams;
% params = handles.output.params;
% 
% if size(iparams,1) == 1
%     
%     plot(iparams,paccs,'k.','MarkerSize',14);
%     xlabel('# Features');
%     ylabel('Accuracy (%)');
%     view(2);
%     
% else
% 
%     xc = get(handles.xparam,'Value');
%     yc = get(handles.yparam,'Value');
%     
%     if xc ~= yc
%     
%         % find paccs for the param settings
%         xvals = unique(iparams(xc,:));
%         yvals = unique(iparams(yc,:));
%         [gx,gy] = ndgrid(xvals,yvals);
%         gz = gx;
%         for x=1:size(gz,1)
%             for y=1:size(gz,2)
%                 ind = intersect(find(iparams(xc,:) == xvals(x)), ...
%                     find(iparams(yc,:) == yvals(y)));
%                 gz(x,y) = max(paccs(ind));
%             end
%         end
% 
%         % draw surface
%         if isvector(gz)
%             plot3(gx,gy,gz,'k.');
%         else
%             h = surf(gx,gy,gz);
%             colormap(handles.graph3,c_blizzard);
%             shading interp;
%             alpha(0.7);
%             set(h,'EdgeColor',[0.8 0.8 0.8]);
%         end
%     
%     end
%     
%     xlabel(['Parameter ' num2str(xc)]);
%     ylabel(['Parameter ' num2str(yc)]);
%     zlabel('Accuracy (%)');
%     view(26,52);
%     
% end
% 
% myfig(5,5);
% cla
% hold on
% paucs = handles.output.paucs;
% iparams = handles.output.iparams;
% 
% plot(iparams,paucs,'k.','MarkerSize',14);
% xlabel('# Features');
% ylabel('AUC');
% view(2);
    


function param_graph(handles)

axes(handles.graph3);
cla
hold on
paccs = handles.output.paccs;
iparams = handles.output.iparams;
params = handles.output.params;

if size(iparams,1) == 1
    
    plot(iparams,paccs,'k.','MarkerSize',10);
    plot(params,paccs(iparams==params),'r.','MarkerSize',10);
    xlabel('# Features');
    ylabel('Accuracy (%)');
    view(2);
    
else

    xc = get(handles.xparam,'Value');
    yc = get(handles.yparam,'Value');
    
    if xc ~= yc
    
        % find paccs for the param settings
        xvals = unique(iparams(xc,:));
        yvals = unique(iparams(yc,:));
        [gx,gy] = ndgrid(xvals,yvals);
        gz = gx;
        for x=1:size(gz,1)
            for y=1:size(gz,2)
                ind = intersect(find(iparams(xc,:) == xvals(x)), ...
                    find(iparams(yc,:) == yvals(y)));
                gz(x,y) = max(paccs(ind));
            end
        end

        % draw surface
        if isvector(gz)
            plot3(gx,gy,gz,'k.');
        else
            h = surf(gx,gy,gz);
            colormap(handles.graph3,c_blizzard);
            shading interp;
            alpha(0.7);
            set(h,'EdgeColor',[0.8 0.8 0.8]);
        end
    
    end
    
    xlabel(['Parameter ' num2str(xc)]);
    ylabel(['Parameter ' num2str(yc)]);
    zlabel('Accuracy (%)');
    view(26,52);
    
end





% --- Executes on selection change in class_select.
function class_select_Callback(hObject, eventdata, handles)
% hObject    handle to class_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns class_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from class_select

update_data_classes(handles);
update_graph(handles,0);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function class_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to class_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)
% hObject    handle to normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalize

update_data_classes(handles);
update_graph(handles,0);

guidata(hObject, handles);


% --- Executes on selection change in classifier.
function classifier_Callback(hObject, eventdata, handles)
% hObject    handle to classifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classifier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classifier


% --- Executes during object creation, after setting all properties.
function classifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function parameters_Callback(hObject, eventdata, handles)
% hObject    handle to parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parameters as text
%        str2double(get(hObject,'String')) returns contents of parameters as a double


% --- Executes during object creation, after setting all properties.
function parameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gdata;
global gclasses;
global featureselection;

if isfield(handles,'myclasses') && isfield(handles,'mydata')

    % retrieve parameters
    types = get(handles.classifier,'String');
    type = types{get(handles.classifier,'Value')};
    if strcmp(type,'Auto')
        if length(size(gdata)) == 2
            options.classifier = 'SVM';
        else
            options.classifier = 'CNN';
        end
    else
        options.classifier = type;
    end
    params = get(handles.parameters,'String');
    if ~strcmp(params,'Auto')
        options.params = eval(params);
    end
    
    folds = get(handles.folds,'String');
    if ~strcmp(folds,'Auto')
        folds = str2num(folds);
        options.numfolds = folds;
    end

    options.featureselection = featureselection;
    
    if isfield(handles,'myfeatures')
        options.features = handles.myfeatures;
    end

    % collect data
    mypartition = [];
    contents = cellstr(get(handles.class_select,'String'));
    classes = get(handles.class_select,'Value');
    numclasses = length(classes);
    
    if numclasses > 1

        for i=1:numclasses
            curclass = str2num(contents{classes(i)});
            ind = (handles.myclasses == curclass);
            if isfield(handles,'mypartition') && ~strcmp(handles.mypartition,'Auto')
                mypartition = [mypartition; handles.mypartition(ind)];
            end 
        end
        
        if isfield(handles,'mypartition') && ~strcmp(handles.mypartition,'Auto')
            options.partition = mypartition;
        end
        
        % sample size matching
        if (get(handles.match_sample_sizes,'Value'))
            options.matching = 1;
        end
        
        % disable param controls
        set(handles.xparam,'Enable','Off');
        set(handles.yparam,'Enable','Off');
        
        % format classes to use lowest numbers
        lowclasses = gclasses;
        uclasses = unique(gclasses);
        for i=1:length(uclasses)
            lowclasses(gclasses==uclasses(i)) = i;
        end
        
        % classify
        set(handles.results,'String',{'Classifying...'});
        drawnow();
        output = classifycv(gdata,lowclasses,options);
        
        % format predictions to true class labels
        temp = output.pred;
        for i=1:length(uclasses)
            temp(output.pred==i) = uclasses(i);
        end
        output.pred = temp;
        
        % save output
        handles.outputdata = output.data;
        handles.outputclasses = output.classes;
        if isfield(options,'partition')
            handles.outputpartition = options.partition;
        end
        handles.outputxaxis = handles.myxaxis;
        handles.output = output;
        handles.myfeatures = output.features;
        
        % enable export
        set(handles.export,'Enable','On');
        
        % report results
        res = {['Sensitivity: ' num2str(round(output.sen,1)) '%'], ...
            ['Specificity: ' num2str(round(output.spe,1)) '%'], ...
            ['Accuracy: ' num2str(round(output.acc,1)) '%'], ...
            ['Mean Accuracy: ' num2str(round(output.accmean,1)) '%'], ...
            '', ...
            ['Parameters: ' num2str(output.params)], ...
            ['Classifier: ' output.classifier], ...
            };
        set(handles.results,'String',res);
        
        % create ROC
        pclass = max(output.classes);
        axes(handles.graph2);
        cla
        if length(unique(output.classes)) == 2
            viewroc(output.classes,handles.output.scores(:,2));
        end
        
        % enable multi-parameter controls and give default values
        if size(output.iparams,1)>1
            aparams = {};
            for i=1:size(output.iparams,1)
                aparams{end+1} = num2str(i);
            end
            set(handles.xparam,'Enable','On');
            set(handles.xparam,'String',aparams);
            set(handles.xparam,'Value',1);
            set(handles.yparam,'Enable','On');
            set(handles.yparam,'String',aparams);
            set(handles.yparam,'Value',2);
        end
        
        % create param graph
        param_graph(handles);
    
    end

end

guidata(hObject, handles);



function folds_Callback(hObject, eventdata, handles)
% hObject    handle to folds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of folds as text
%        str2double(get(hObject,'String')) returns contents of folds as a double


% --- Executes during object creation, after setting all properties.
function folds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to folds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in partition.
function partition_Callback(hObject, eventdata, handles)
% hObject    handle to partition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns partition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from partition

contents = cellstr(get(hObject,'String'));
if strcmp(contents{get(hObject,'Value')},'Auto')
    handles.mypartition = 'Auto';
else
    handles.mypartition = evalin('base',contents{get(hObject,'Value')});
    if size(handles.mypartition,1) == 1
        handles.mypartition = handles.mypartition';
    end
    
    update_data_classes(handles);
    update_graph(handles,0);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function partition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to partition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showdata.
function showdata_Callback(hObject, eventdata, handles)
% hObject    handle to showdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showdata

update_graph(handles,0);

guidata(hObject, handles);



% --- Executes on slider movement.
function dataslider_Callback(hObject, eventdata, handles)
% hObject    handle to dataslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = round(get(hObject,'Value'));
set(handles.dataslider,'Value',val);
set(handles.datanum,'String',['# ' num2str(val)]);

update_graph(handles,0);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dataslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

output = handles.output;
data = handles.outputdata;
classes = handles.outputclasses;
xaxis = handles.outputxaxis;
if isfield(handles,'outputpartition')
    partition = handles.outputpartition;
end

[fn,pn] = myuiputfile('.mat','Save Data To');
if fn == 0
    return;
end
if isfield(handles,'outputpartition')
    save([pn fn],'output','data','classes','xaxis','partition');
else
    save([pn fn],'output','data','classes','xaxis');
end

% save figure
% [fn,pn] = myuiputfile('*.fig','Save Figure');
% if fn == 0
%     return;
% end
% newFig = myfig(6,9);
% copyobj(handles.graph,newFig);
% set(gca,'Position',[.15 .15 90 30]);
% hgsave(newFig,[pn fn]);
% close(newFig);




% --- Executes on selection change in xaxis.
function xaxis_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xaxis

contents = cellstr(get(hObject,'String'));
if strcmp(contents{get(hObject,'Value')},'Auto')
    if isfield(handles,'mydata')
        handles.myxaxis = 1:size(handles.mydata,2);
    end
else
    handles.myxaxis = evalin('base',contents{get(hObject,'Value')});
end

if isfield(handles,'myclasses') && isfield(handles,'mydata')
    update_graph(handles,0);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in features.
function features_Callback(hObject, eventdata, handles)
% hObject    handle to features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update feature selection
set(handles.results,'String',{'Finding Features...'});

drawnow();
global gdata;
global gclasses;
global featureselection;

if ~isfield(handles,'myfeatures')
    handles.myfeatures = eval([featureselection '(gdata,gclasses)']);
end

axes(handles.graph);
for f=1:20
    p = handles.myxaxis(handles.myfeatures(f));
    line([p p],get(handles.graph,'YLim'),'Color', ...
        [0.2 0.2 0.2 0.2],'LineWidth',1);
end

set(handles.results,'String',{''});

guidata(hObject, handles);


% --- Executes on button press in errorbars.
function errorbars_Callback(hObject, eventdata, handles)
% hObject    handle to errorbars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of errorbars

update_graph(handles,0);

guidata(hObject, handles);


% --- Executes on selection change in featureselection.
function featureselection_Callback(hObject, eventdata, handles)
% hObject    handle to featureselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns featureselection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from featureselection

contents = cellstr(get(hObject,'String'));
nm = contents{get(hObject,'Value')};
global featureselection;
if ~strcmp(nm,'Auto')
    featureselection = nm;
end
if isfield(handles,'myfeatures')
    handles = rmfield(handles,'myfeatures');
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function featureselection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featureselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xparam.
function xparam_Callback(hObject, eventdata, handles)
% hObject    handle to xparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xparam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xparam

param_graph(handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in yparam.
function yparam_Callback(hObject, eventdata, handles)
% hObject    handle to yparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns yparam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yparam

param_graph(handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in publishfigure.
function publishfigure_Callback(hObject, eventdata, handles)
% hObject    handle to publishfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_graph(handles,1);

guidata(hObject, handles);


% --- Executes on button press in show_mean_spectra.
function show_mean_spectra_Callback(hObject, eventdata, handles)
% hObject    handle to show_mean_spectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_mean_spectra

update_graph(handles,0);

guidata(hObject, handles);


% --- Executes on button press in match_sample_sizes.
function match_sample_sizes_Callback(hObject, eventdata, handles)
% hObject    handle to match_sample_sizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of match_sample_sizes
