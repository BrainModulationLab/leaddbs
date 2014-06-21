function varargout = ea_imageclassifier(varargin)
% EA_IMAGECLASSIFIER MATLAB code for ea_imageclassifier.fig
%      EA_IMAGECLASSIFIER, by itself, creates a new EA_IMAGECLASSIFIER or raises the existing
%      singleton*.
%
%      H = EA_IMAGECLASSIFIER returns the handle to a new EA_IMAGECLASSIFIER or the handle to
%      the existing singleton*.
%
%      EA_IMAGECLASSIFIER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EA_IMAGECLASSIFIER.M with the given input arguments.
%
%      EA_IMAGECLASSIFIER('Property','Value',...) creates a new EA_IMAGECLASSIFIER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ea_imageclassifier_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ea_imageclassifier_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ea_imageclassifier

% Last Modified by GUIDE v2.5 20-Jun-2014 13:53:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ea_imageclassifier_OpeningFcn, ...
                   'gui_OutputFcn',  @ea_imageclassifier_OutputFcn, ...
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


% --- Executes just before ea_imageclassifier is made visible.
function ea_imageclassifier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ea_imageclassifier (see VARARGIN)

% Choose default command line output for ea_imageclassifier
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


set(gcf,'name','Please specify image type');

global dcfilename tmpoutdir
setappdata(gcf,'dcfilename',dcfilename);
setappdata(gcf,'dcfilename',tmpoutdir);


nii=load_untouch_nii(getappdata(gcf,'dcfilename'));
nii.img=double(nii.img)/double(max(nii.img(:)));

h=slice(double(nii.img),round(size(nii.img,1)/2),...
    round(size(nii.img,2)/2),...
    round(size(nii.img,3)/2));
set(h,'FaceColor','interp',...
	'EdgeColor','none',...
	'DiffuseStrength',.8)
colormap gray
set(gcf, 'menubar', 'figure' )
set(gcf, 'toolbar', 'figure' )
set(gcf,'KeyPressFcn',@ea_keystr);

view(270,90)
axis equal
axis tight
axis off
% UIWAIT makes ea_imageclassifier wait for user response (see UIRESUME)
%uiwait(handles.figure1);





% --- Outputs from this function are returned to the command line.
function varargout = ea_imageclassifier_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



% --- Executes on button press in trapush.
function trapush_Callback(hObject, eventdata, handles)
% hObject    handle to trapush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('tra');

% --- Executes on button press in pretrapush.
function pretrapush_Callback(hObject, eventdata, handles)
% hObject    handle to pretrapush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('pre_tra');

% --- Executes on button press in corpush.
function corpush_Callback(hObject, eventdata, handles)
% hObject    handle to corpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('cor');

% --- Executes on button press in sagpush.
function sagpush_Callback(hObject, eventdata, handles)
% hObject    handle to sagpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('sag');

% --- Executes on button press in ctpush.
function ctpush_Callback(hObject, eventdata, handles)
% hObject    handle to ctpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('CT');

% --- Executes on button press in fusionpush.
function fusionpush_Callback(hObject, eventdata, handles)
% hObject    handle to fusionpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
finishandclose('fusion');


function ea_keystr(icfig,event)
%    pause
%commnd=get (gcf, 'CurrentKey');

        %global current_imclass
global tmpoutdir
%% get vars
eltog=getappdata(gcf,'eltog');
elplot=getappdata(gcf,'elplot');
coords_mm=getappdata(gcf,'coords_mm');




commnd=lower(event.Character);
switch commnd
    case 't'
        finishandclose('tra');
    case 'p'
        finishandclose('pre_tra');
        
    case 's'
        finishandclose('sag');
        
        
    case 'c'
        finishandclose('cor');
        
    case 'f'
        finishandclose('fusion');
        
    case 'a'
        finishandclose('CT');
        
    otherwise
        return
end



function finishandclose(current_imclass)

append='';
while exist([tmpoutdir,filesep,current_imclass,append,'.nii'],'file')
    append=[append,'2'];
end
movefile([getappdata(gcf,'dcfilename')],[getappdata(gcf,'tmpoutdir'),filesep,current_imclass,append,'.nii']);

close(gcf)
        
