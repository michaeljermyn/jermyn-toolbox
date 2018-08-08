function varargout = jviz(varargin)
% JVIZ MATLAB code for jviz.fig
%      JVIZ, by itself, creates a new JVIZ or raises the existing
%      singleton*.
%
%      H = JVIZ returns the handle to a new JVIZ or the handle to
%      the existing singleton*.
%
%      JVIZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JVIZ.M with the given input arguments.
%
%      JVIZ('Property','Value',...) creates a new JVIZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jviz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jviz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jviz

% Last Modified by GUIDE v2.5 13-Jun-2016 11:05:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jviz_OpeningFcn, ...
                   'gui_OutputFcn',  @jviz_OutputFcn, ...
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


% --- Executes just before jviz is made visible.
function jviz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jviz (see VARARGIN)

% Choose default command line output for jviz
handles.output = hObject;

% window settings
set(hObject,'Name','Jermyn Toolbox');
set(gcf,'color','white');
if ~ispref('jviz','colormap')
    setpref('jviz','colormap','jet');
end

% disable controls
set(handles.slider,'Enable','Off');
set(handles.dimension,'Enable','Off');
set(handles.slicedim,'Enable','Off');

% find workspace variables
findvars(handles);

% menu bar
topmenu{1} = uimenu(gcf,'Label','Visualization');
topmenu{2} = uimenu(gcf,'Label','Filters');
topmenu{3} = uimenu(gcf,'Label','Options');

% initial visualization function
global vizfname;
vizfname = 'viz_image';

% find visualization functions
solver_loc = what('visualization');
solvers = dir([solver_loc.path '/viz_*.m']);
varnames = {};
for i=1:size(solvers)
    varnames{i} = solvers(i).name(5:end-2);
    submenu = uimenu(topmenu{1},'Label',varnames{i}, ...
        'Callback',eval('{@viz,solvers(i).name(1:end-2),handles}'));
end

% find filters
solver_loc = what('filters');
solvers = dir([solver_loc.path '/filt_*.m']);
varnames = {};
for i=1:size(solvers)
    varnames{i} = solvers(i).name(6:end-2);
    submenu = uimenu(topmenu{2},'Label',varnames{i}, ...
        'Callback',eval('{@filt,solvers(i).name(1:end-2),handles}'));
end

% options
submenu = uimenu(topmenu{3},'Label','window/level', ...
        'Callback',eval('{@options_windowlevel,handles}'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jviz wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- find workspace variables
function findvars(handles)
% handles is the GUI object

vars = evalin('base','whos;');
varnames = {};
[nv,~] = size(vars);
nflag = 2;
varnames{1} = 'Select Inputs';
for i=1:1:nv
    flag = evalin('base',strcat('isnumeric(',vars(i).name,')'));
    if flag
        varnames{nflag} = vars(i).name;
        nflag = nflag + 1;
    end
end
if ~isempty(varnames)
    set(handles.inputs,'String',varnames);
    varnames{1} = 'Select Ouputs';
    set(handles.outputs,'String',varnames);
end


% --- retrieve inputs/outputs
function [inputs, outputs] = getdata(handles)
% handles is the GUI object

inval = get(handles.inputs,'Value');
instr = get(handles.inputs,'String');
outval = get(handles.outputs,'Value');
outstr = get(handles.outputs,'String');
if (inval ~= 1)
    inputs = evalin('base',instr{inval});
else
    inputs = [];
end
if (outval ~= 1)
    outputs = evalin('base',outstr{outval});
else
    outputs = [];
end


% --- slice data
function [data] = slicedata(data)
% data is an n-dim matrix
% slices are the desired slice locations for each dim
% dims is the number of dims to use fully

global slices;

slicestr = '';
for i=1:length(size(data))
    if slices(i) ~= 0
        slicestr = [slicestr num2str(slices(i)) ','];
    else
        slicestr = [slicestr ':,'];
    end
end
slicestr = ['data(' slicestr(1:end-1) ')'];

data = squeeze(eval(slicestr));



% --- window/leve
function options_windowlevel(hObject, eventdata, handles)
% handles is the GUI object

uiwait(imcontrast(handles.ax));
tmp = get(handles.ax,'CLim')


% --- vizualization functions
function viz(hObject, eventdata, fname, handles)
% fname is the function name
% handles is the GUI object

global vizfname;
vizfname = fname;

axes(handles.ax);
cla(handles.ax,'reset');
hold on
[inputs, outputs] = getdata(handles);
inputs = slicedata(inputs);

if (~isempty(inputs))
    eval([fname '(inputs,outputs);']);
end

set(gca, 'box', 'off');


% --- filter functions
function filt(hObject, eventdata, fname, handles)
% fname is the function name
% handles is the GUI object

[inputs, outputs] = getdata(handles);
inputs = slicedata(inputs);

if (~isempty(inputs))
    eval([fname '(inputs,outputs);']);
end

% add to inputs/outputs lists
ins = get(handles.inputs,'String');
outs = get(handles.outputs,'String');

varloc = find(strcmp(ins,'jviz_permute'));
ins(varloc) = [];
varloc = find(strcmp(outs,'jviz_permute'));
outs(varloc) = [];

ins{end+1} = ['jviz_' fname(6:end)];
outs{end+1} = ['jviz_' fname(6:end)];

set(handles.inputs,'String',ins);
set(handles.outputs,'String',outs);
set(handles.inputs,'Value',length(ins));

% update input & visualize
inputs_Callback(hObject, eventdata, handles);



% --- Outputs from this function are returned to the command line.
function varargout = jviz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in inputs.
function inputs_Callback(hObject, eventdata, handles)
% hObject    handle to inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns inputs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inputs

global slices;
global vizfname;

[inputs, ~] = getdata(handles);
handles.dimsizes = size(inputs);
handles.ndims = length(size(inputs));

% enable gui controls
set(handles.dimension,'Enable','On');
dims = cellfun(@num2str, num2cell(1:handles.ndims), 'UniformOutput', false);
set(handles.dimension,'String',dims);
set(handles.slider,'Enable','Off');
set(handles.slider,'max',handles.dimsizes(1));
set(handles.slider,'min',1);
set(handles.slider,'Value',1);
set(handles.slider,'SliderStep',[1/handles.dimsizes(1),1/handles.dimsizes(1)]);
set(handles.num,'String',['ALL / ' num2str(handles.dimsizes(1))]);
set(handles.slicedim,'Enable','On');
set(handles.slicedim,'Value',0);
set(handles.size,'String',['Size: ' num2str(handles.dimsizes)]);

% initialize slice values
slices = zeros(1,handles.ndims);

% visualize
viz(hObject, eventdata, vizfname, handles);

% enable window/level controls
setpref('jviz','levels',[min(inputs(:)) max(inputs(:))]);
enableWL();

% Update handles structure
guidata(hObject, handles);




% --- Window / Level controls
% RIGHT button
function enableWL(hfig)
if nargin<1
	hfig=gcf;
end
G=get(hfig,'userdata');
G.oldWBMFcn = get(hfig,'WindowButtonMotionFcn');
set(hfig,'userdata',G);

set(hfig,'WindowButtonDownFcn',@WBDFcn);
set(hfig,'WindowButtonUpFcn',@WBUFcn);

function WBDFcn(varargin)
fh=varargin{1};
if ~strcmp(get(fh,'SelectionType'),'normal')
    set(fh, 'WindowButtonMotionFcn',@AdjWL);
    G=get(fh,'userdata');

    G.initpnt=get(gca,'currentpoint');
    G.initClim = get(gca,'Clim');
    set (fh,'userdata',G);
end
    
function WBUFcn(varargin)
fh=varargin{1};
if ~strcmp(get(gcf,'SelectionType'),'normal')
G=get(fh,'userdata');
set(fh,'WindowButtonMotionFcn',G.oldWBMFcn);
end
setpref('jviz','levels',get(gca,'Clim'));

function AdjWL(varargin)
fh=varargin{1};
G=get(fh,'userdata');
G.cp=get(gca,'currentpoint');
G.x=G.cp(1,1);
G.y=G.cp(1,2);
G.xinit = G.initpnt(1,1);
G.yinit = G.initpnt(1,2);
G.dx = G.x-G.xinit;
G.dy = G.y-G.yinit;
G.clim = G.initClim+G.initClim(2).*[G.dx G.dy]./128;
try
    switch get(fh,'SelectionType')
        case 'extend' % Mid-button, shft+left button,
%             'extend'
        set(findobj(fh,'Type','axes'),'Clim',G.clim);
        case 'alt' %right-click,ctrl+left button,
%             'alt'
        set(gca,'Clim',G.clim);
    end;
end;




% --- Executes during object creation, after setting all properties.
function inputs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in outputs.
function outputs_Callback(hObject, eventdata, handles)
% hObject    handle to outputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns outputs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputs

global vizfname;

% visualize
viz(hObject, eventdata, vizfname, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function outputs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global slices;
global vizfname;
contents = cellstr(get(handles.dimension,'String'));
dim = str2num(contents{get(handles.dimension,'Value')});

val = round(get(hObject,'Value'));
set(handles.slider,'Value',val);
set(handles.num,'String',[num2str(val) ' / ' num2str(handles.dimsizes(dim))]);
slices(dim) = val;

% visualize
viz(hObject, eventdata, vizfname, handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in dimension.
function dimension_Callback(hObject, eventdata, handles)
% hObject    handle to dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dimension contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dimension

contents = cellstr(get(hObject,'String'));
dim = str2num(contents{get(hObject,'Value')});
global slices;

% modify slider
set(handles.slider,'max',handles.dimsizes(dim));
set(handles.slider,'min',1);
set(handles.slider,'SliderStep',[1/handles.dimsizes(dim),1/handles.dimsizes(dim)]);
if slices(dim) == 0
    set(handles.num,'String',['ALL / ' num2str(handles.dimsizes(dim))]);
    set(handles.slider,'Enable','Off');
    set(handles.slider,'Value',1);
    set(handles.slicedim,'Value',0);
else
    set(handles.num,'String',[num2str(slices(dim)) ' / ' num2str(handles.dimsizes(dim))]);
    set(handles.slider,'Enable','On');
    set(handles.slider,'Value',slices(dim));
    set(handles.slicedim,'Value',1);
end

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function dimension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in slicedim.
function slicedim_Callback(hObject, eventdata, handles)
% hObject    handle to slicedim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slicedim

global slices;
global vizfname;
contents = cellstr(get(handles.dimension,'String'));
dim = str2num(contents{get(handles.dimension,'Value')});

if get(hObject,'Value')
    slices(dim) = 1;
    set(handles.num,'String',['1 / ' num2str(handles.dimsizes(dim))]);
    set(handles.slider,'Enable','On');
    set(handles.slider,'Value',1);
else
    slices(dim) = 0;
    set(handles.num,'String',['ALL / ' num2str(handles.dimsizes(dim))]);
    set(handles.slider,'Enable','Off');
    set(handles.slider,'Value',1);
end

% visualize
viz(hObject, eventdata, vizfname, handles);

% Update handles structure
guidata(hObject, handles);
