function varargout = DetuningMappingGUI(varargin)
% DETUNINGMAPPINGGUI MATLAB code for DetuningMappingGUI.fig
%      DETUNINGMAPPINGGUI, by itself, creates a new DETUNINGMAPPINGGUI or raises the existing
%      singleton*.
%
%      H = DETUNINGMAPPINGGUI returns the handle to a new DETUNINGMAPPINGGUI or the handle to
%      the existing singleton*.
%
%      DETUNINGMAPPINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETUNINGMAPPINGGUI.M with the given input arguments.
%
%      DETUNINGMAPPINGGUI('Property','Value',...) creates a new DETUNINGMAPPINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DetuningMappingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DetuningMappingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DetuningMappingGUI

% Last Modified by GUIDE v2.5 16-Oct-2017 12:13:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DetuningMappingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @DetuningMappingGUI_OutputFcn, ...
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


% --- Executes just before DetuningMappingGUI is made visible.
function DetuningMappingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DetuningMappingGUI (see VARARGIN)

% Choose default command line output for DetuningMappingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global config;
config.Queue=MissionQueueObj(handles.listbox1);
% States (points) in the two coordinates
config.StateVV=[];
config.StateFz=[];
config.nTransitionPoint=51; % used in linspace(V1,V2, nPoint)
try
    handles.text4.String=[handles.text4.String,num2str(config.PDPowerCorrectionRatio)];
catch
end
config.fdetuning=[];
config.nSaveFigureIndex=1;
config.nTestIndex=1;
config.VVFzMap.DrawSolitonBoundary(handles.axes2);
config.VaomLowerBoundry=[];
config.VaomUpperBoundry=[];
config.FzLowerBoundry=[];
config.FzUpperBoundry=[];
config.VVhistory=[];
config.Fzhistory=[];
config.RestoreButton=handles.pushbutton17;
config.EDFA=[];
UpdateText5(config,handles);
edit6_Callback(hObject, eventdata, handles); % update D1, D2
edit7_Callback(hObject, eventdata, handles);

plot(handles.axes3,0.5:0.1:8.7,ppval(config.VVFzMap.AOMTrans,0.5:0.1:8.7));
xlim(handles.axes3,[0.5,8.7]);
xlabel(handles.axes3,'AOM Voltage (V)');
ylabel(handles.axes3,'AOM Transmission');
% UIWAIT makes DetuningMappingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DetuningMappingGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global config;
varargout{1} = handles.output;
% disconnect
try
    config.FG.delete;
catch
end
try
% disconnect
fclose(config.ESAvisaObj);
catch
end
try
config.OSA.Delete;
catch
end
try
    config.EDFA.delete;
catch
end

function mat=SwapEntry(mat,n1,n2)
    tmp=mat(n1,:);
    mat(n1,:)=mat(n2,:);
    mat(n2,:)=tmp;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) % move up
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
try
    config.StateVV=SwapEntry(config.StateVV,config.Queue.Listboxhandle.Value,config.Queue.Listboxhandle.Value-1);
    config.StateFz=SwapEntry(config.StateVV,config.Queue.Listboxhandle.Value,config.Queue.Listboxhandle.Value-1);
catch
end
config.Queue.SwapOrder([],-1);
UpdatePlot(config,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles) % move down
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
try
    config.StateVV=SwapEntry(config.StateVV,config.Queue.Listboxhandle.Value,config.Queue.Listboxhandle.Value+1);
    config.StateFz=SwapEntry(config.StateVV,config.Queue.Listboxhandle.Value,config.Queue.Listboxhandle.Value+1);
catch
end
config.Queue.SwapOrder([],0);
UpdatePlot(config,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles) % delete selection
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.VVhistory(end+1,:)=config.StateVV(config.Queue.Listboxhandle.Value,:);
config.StateVV(config.Queue.Listboxhandle.Value,:)=[];
try
    config.Fzhistory(end+1,:)=config.StateFz(config.Queue.Listboxhandle.Value,:);
    config.StateFz(config.Queue.Listboxhandle.Value,:)=[];
catch
end
config.Queue.DeleteQueue([]);
UpdatePlot(config,handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles) % clear list
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.Queue.ClearQueue();
config.StateVV=[];
config.StateFz=[];

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles) % add to list
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
Destination=[str2double(handles.edit1.String),str2double(handles.edit2.String),str2double(handles.edit3.String)]; % Voffset, VAOM, total time
Destination(3)=Destination(3)/config.nTransitionPoint; % delay for each point
if config.Queue.nListboxentry
    % connected last state the this one
    config.StateVV(end+1,:)=Destination(1:2);
    config.Queue.AddtoQueue({linspace(config.StateVV(end-1,1),config.StateVV(end,1),config.nTransitionPoint),linspace(config.StateVV(end-1,2),config.StateVV(end,2),config.nTransitionPoint),Destination(3)},...
        config.Queue.formatVectorString(Destination,config.Queue.nListboxentry+1));
else
    % the first point
    config.Queue.AddtoQueue(num2cell(Destination),config.Queue.formatVectorString(Destination,1));
    config.StateVV(1,:)=Destination(1:2);
end
UpdatePlot(config,handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles) % edit selection
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
Destination=[str2double(handles.edit1.String),str2double(handles.edit2.String),str2double(handles.edit3.String)]; % Voffset, VAOM, total time
Destination(3)=Destination(3)/config.nTransitionPoint; % delay for each point
if config.Queue.Listboxhandle.Value>1
    % connected last state the this one
    config.StateVV(config.Queue.Listboxhandle.Value,:)=Destination(1:2);
    config.Queue.EditQueue([],{linspace(config.StateVV(end-1,1),config.StateVV(end,1),config.nTransitionPoint),linspace(config.StateVV(end-1,2),config.StateVV(end,2),config.nTransitionPoint),Destination(3)},...
        config.Queue.formatVectorString(Destination,config.Queue.Listboxhandle.Value));
%     config.StateFz(config.Queue.Listboxhandle.Value,2)=config.VVFzMap.NormalizePowerFromVoltage(str2double(handles.edit4.String),Destination(2)); % get F2 from Vaom
else
    % the first point
    config.Queue.EditQueue([],num2cell(Destination),config.Queue.formatVectorString(Destination,1));
    config.StateVV(1,:)=Destination(1:2);
%     config.StateFz(1,2)=config.VVFzMap.NormalizePowerFromVoltage(str2double(handles.edit4.String),Destination(2)); % get F2 from Vaom
end
UpdatePlot(config,handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles) % increase first index
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
if ~exist(['configData' int2str(config.nTestIndex) '.mat'],'file')
    button = questdlg('You have not saved data (export data button). Proceed?');
    if ~strcmp(button,'Yes')
        return;
    end
end
config.nTestIndex=config.nTestIndex+1;
config.nSaveFigureIndex=1;
UpdateText5(config,handles);

function UpdateText5(config,handles)
handles.text5.String=['Figure number: (' int2str(config.nTestIndex) ',' int2str(config.nSaveFigureIndex) ')'];


function RunPath(config,nIndex,nOpMode)
config.RestoreButton.Enable='off';
for i=nIndex
    if i~=1
        config.Queue.Listboxhandle.Value=i;
    end
    QueueObjElement=config.Queue.ReadQueue(i);
    QueueObjElement=QueueObjElement{1};
    if iscell(QueueObjElement(3))
        time=QueueObjElement{3};
    else
        time=QueueObjElement(3);
    end
    switch nOpMode
        case 1
            % AOM voltage
            config.FG.path(QueueObjElement{1},QueueObjElement{2},time);
        case 2
            % EDFA current
            if QueueObjElement{1}~=QueueObjElement{end}
                for mm=1:length(QueueObjElement{1})
                    config.EDFA.Current=QueueObjElement{2}(mm);
                    config.FG.DC1=QueueObjElement{1}(mm);
                    pause(time);
                end
            end
    end
end
config.RestoreButton.Enable='on';



% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles) % connect to FG
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global config;
if hObject.Value
    myfg = Keysight33500(config.FGResourceStr);
    myfg.connect;
    config.FG=myfg;
    if ~isempty(myfg)
        handles.pushbutton7.Enable='on';
    end
else
    % disconnect
    config.FG.delete;
    handles.pushbutton7.Enable='off';
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles) % connect to ESA
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global config;
if hObject.Value
    config=ConnectESA(config);
else
    % disconnect
    fclose(config.ESAvisaObj);
    config.ESAvisaObj=[];
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles) % read ESA
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
pushbutton22_Callback(hObject, eventdata, handles) % ESA stop
[Y,X]=RSA3408A_read(config.ESAvisaObj);
% config.ESAdata = RSA3K_ReadCorrectedData(config.ESAvisaObj, 1, 0);
config.ESAdata=[];
config.ESAdata(2,:)=10.^(Y/20);
config.ESAdata(1,:)=X;
% axes(handles.axes3);
Fig2=figure(6);
plot(config.ESAdata(1,:)/1e6,config.ESAdata(2,:));
xlabel('Frequency (MHz)');
ylabel('Amplitude (mV)')
pushbutton9_Callback(hObject, eventdata, handles); % peak finding
saveas(Fig2,['DetuningPath_Other_' int2str(config.nTestIndex) '_' int2str(config.nSaveFigureIndex) '.fig']);
config.nSaveFigureIndex=handles.listbox1.Value;
UpdateText5(config,handles);

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles) % peak finding
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
SmoothData=smooth(config.ESAdata(2,:),35);
[pks,locs,w]=findpeaks(SmoothData);
[pks,nmax]=max(pks);
locs=locs(nmax);
hold('on');
plot(config.ESAdata(1,locs)/1e6,pks,'.','MarkerSize',12);
plot(config.ESAdata(1,:)/1e6,SmoothData,'-k');
hold('off');
% the peak may not be the center due to under-sampling
% use gravitational center method
% localdata=config.ESAdata(:,locs-fix(w/2):locs+fix(w/2));
% config.tmpfdetuning=sum(localdata(1,:).*localdata(2,:))/sum(localdata(2,:));
config.tmpfdetuning=config.ESAdata(1,locs);
handles.edit5.String=num2str(config.tmpfdetuning/1e6); % unit?




function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles) % accept peak freq
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.fdetuning(config.Queue.Listboxhandle.Value)=str2double(handles.edit5.String)*1e6;
% map to Fz space
config=VVFzMap(config,handles,config.Queue.Listboxhandle.Value,false,handles.popupmenu2.Value-1);
UpdatePlot(config,handles,true);
% config.Fzhistory(end+1,:)=config.StateFz(config.Queue.Listboxhandle.Value,:);
% [config.Fzhistory,~]=DeleteDuplicateEntry(config.Fzhistory);

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles) % run selection
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
RunPath(config,config.Queue.Listboxhandle.Value,handles.popupmenu2.Value);

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles) % run to selection
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
RunPath(config,1:config.Queue.Listboxhandle.Value,handles.popupmenu2.Value);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles) % save figure
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
SaveAxesPlotFromGUI(handles.axes1,['DetuningPath_VV_' int2str(config.nTestIndex) '_' int2str(config.nSaveFigureIndex) '.fig']);
SaveAxesPlotFromGUI(handles.axes2,['DetuningPath_Fz_' int2str(config.nTestIndex) '_' int2str(config.nSaveFigureIndex) '.fig']);
% SaveAxesPlotFromGUI(handles.axes3,['DetuningPath_Other_' int2str(config.nSaveFigureIndex) '.fig']);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles) % export data
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
FG=config.FG;
ESA=config.ESAvisaObj;
OSA=config.OSA;
EDFA=config.EDFA;
rb=config.RestoreButton;
try
Osci=config.OscigroupObj;
catch
end
config.FG=[];
config.ESAvisaObj=[];
config.EDFA=[];
config.RestoreButton=[];
save(['configData' int2str(config.nTestIndex) '.mat'],'config','-v7.3');
config.FG=FG;
config.ESAvisaObj=ESA;
config.OSA=OSA;
config.OscigroupObj=[];
try
config.OscigroupObj=Osci;
catch
end
config.RestoreButton=rb;
config.EDFA=EDFA;

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles) % import data
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
FG=config.FG;
ESA=config.ESAvisaObj;
OSA=config.OSA;
rb=config.RestoreButton;
EDFA=config.EDFA;
try
Osci=config.OscigroupObj;
catch
end
config.FG=[];
config.ESAvisaObj=[];
config.EDFA=[];
config.OscigroupObj=[];
folder_name = uigetdir;
load(folder_name);
config.FG=FG;
config.ESAvisaObj=ESA;
config.OSA=OSA;

try
config.OscigroupObj=Osci;
catch
end
config.RestoreButton=rb;
config.EDFA=EDFA;


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles) % Update plot
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
try
    UpdatePlot(config,handles,false);
    UpdatePlot(config,handles,true);
catch
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles) % return to initial
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
RunPath(config,1,handles.popupmenu2.Value);


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles) % set power (EDFA)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
power=str2double(handles.edit12.String);
if ~isnan(power) && power>0 && power<1.9
    config.Power=power;
end


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)  % hit lower boundry
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
global log; % The other GUI global variable
Vaomrange=config.StateVV(config.Queue.Listboxhandle.Value,2):-0.01:0;
config.VaomLowerBoundry(config.Queue.Listboxhandle.Value,:)=[config.StateVV(config.Queue.Listboxhandle.Value,1),config.FG.path(config.StateVV(config.Queue.Listboxhandle.Value,1),Vaomrange,0.2,log)]; % return when soliton off
hold(handles.axes1,'on');
plot(config.StateVV(config.Queue.Listboxhandle.Value,1),config.VaomBoundry(config.Queue.Listboxhandle.Value,1),'kx');
hold(handles.axes1,'off');
config=VVFzMap(config,handles,config.Queue.Listboxhandle.Value,true);
UpdatePlot(config,handles,false);
UpdatePlot(config,handles,true);

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)  % hit upper boundry
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
global log; % The other GUI global variable
Vaomrange=config.StateVV(config.Queue.Listboxhandle.Value,2):0.01:8.7;
config.VaomUpperBoundry(config.Queue.Listboxhandle.Value,:)=[config.StateVV(config.Queue.Listboxhandle.Value,1),config.FG.path(config.StateVV(config.Queue.Listboxhandle.Value,1),Vaomrange,0.2,log)]; % return when soliton off
hold(handles.axes1,'on');
plot(config.StateVV(config.Queue.Listboxhandle.Value,1),config.VaomBoundry(config.Queue.Listboxhandle.Value,2),'bx');
hold(handles.axes1,'off');
config=VVFzMap(config,handles,config.Queue.Listboxhandle.Value,true);
UpdatePlot(config,handles,false);
UpdatePlot(config,handles,true);


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles) % ESA run
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
% fprintf(log.ESAvisaObj,':INITiate:IMMediate');
fprintf(config.ESAvisaObj,':INITiate[:IMMediate]');
fprintf(config.ESAvisaObj,':INITiate:CONTinuous ON');

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles) % ESA stop
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
fprintf(config.ESAvisaObj,':INITiate:CONTinuous OFF');


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles) % re-enable button
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.RestoreButton.Enable='on';


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles) % connect OSA
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global config;
if hObject.Value
    config.OSA=YokogawaOSA(config.OSAResourceStr);
    config.OSA.InputBufferSize=45001*24;
    config.OSA.Connect;
else
    % disconnect
    config.OSA.Delete;
end

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles) % read OSA Y data
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
if handles.checkbox5.Value
    config.OSA.Initiate; % single
end
config.OSAYData=config.OSA.ReadTraceYData(handles.popupmenu1.String{handles.popupmenu1.Value});

config.solitonobj=SolitonSpectrumObj([config.OSAXData;config.OSAYData],true); % true if data in unit dB
pushbutton25_Callback(hObject, eventdata, handles) % fit detuning


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles) % fit detuning
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
% Use current OSA data
config.solitonobj.ManualPeakSeperationWavelength=[str2double(handles.edit8.String),str2double(handles.edit9.String)];
bRemovepump=0;
if handles.checkbox4.Value
    config.solitonobj = config.solitonobj.FitSolitonShape(bRemovepump,false,[1550],'forcepeak'); % 'FWHM' in THz
else
    config.solitonobj = config.solitonobj.FitSolitonShape(bRemovepump,false,[1550]); % 'FWHM' in THz
end
if handles.checkbox4.Value
    config.solitonobj = config.solitonobj.FitSolitonShape(bRemovepump,false,[1550],'forcepeak'); % 'FWHM' in THz
else
    config.solitonobj = config.solitonobj.FitSolitonShape(bRemovepump,false,[1550]); % 'FWHM' in THz
end
config.D1=str2double(handles.edit6.String); % MHz
config.D2=str2double(handles.edit7.String); % kHz
detuning=config.solitonobj.Detuning(config.D1*1e6*2*pi,config.D2*1e3*2*pi,config.Qloaded); % does not have 2pi
handles.edit5.String=num2str(detuning/1e6);
[fig,ax,Lines] = config.solitonobj.PlotFitResults(false);
xlabel('Wavelength (nm)');
ylabel('Spectral power (dBm)');
title(['Fitted pulse width: ' num2str(config.solitonobj.SolitonShapeParam(1,end)) ' fs, detuning: ' num2str(detuning/1e6) ' MHz, soliton power: ' num2str(config.solitonobj.TotalPower) ' mW']);
config.nSaveFigureIndex=handles.listbox1.Value;
saveas(fig,['SolitonSpectrum_' int2str(config.nTestIndex) '_' int2str(config.nSaveFigureIndex) '.fig']);
UpdateText5(config,handles);

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
global config;
config.D1=str2double(handles.edit6.String); % MHz
config.VVFzMap.D1=config.D1;

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
global config;
config.D2=str2double(handles.edit7.String); % kHz
config.VVFzMap.D2=config.D2;

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles) % add point to Fz space
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.FzLowerBoundry(end+1,:)=[str2double(handles.edit10.String),str2double(handles.edit11.String)];
UpdatePlot(config,handles);


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles) % Save OSA X Data
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.OSAXData=config.OSA.ReadTraceXData(handles.popupmenu1.String{handles.popupmenu1.Value});


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles) % Read OSA Y Data + ESA Run
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton21_Callback(hObject, eventdata, handles); % ESA run
pushbutton24_Callback(hObject, eventdata, handles); % read OSA Y data

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles) % autorun
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
for i=config.Queue.Listboxhandle.Value:config.Queue.nListboxentry
    RunPath(config,i,handles.popupmenu2.Value);
    pause(1);
    if handles.checkbox5.Value
        pushbutton28_Callback(hObject, eventdata, handles) % Read OSA Y Data + ESA Run
    end
    pause(0.5);
    pushbutton8_Callback(hObject, eventdata, handles) % read ESA
    pause(0.5);
    pushbutton10_Callback(hObject, eventdata, handles) % accept peak freq
    pause(0.5);
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles) % connect to Osci
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
global config;
global log;
switch handles.popupmenu3.Value
    case 1
        % tek oscilloscope
        if hObject.Value
            config.OscigroupObj=log.OscigroupObj;
        end
    case 2
        % infinium
        if hObject.Value
            config.OscigroupObj=Infiniium(config.OsciResourceStr);
            config.OscigroupObj.connect;
        end
end

% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles) % Osci fft
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
switch handles.popupmenu3.Value
    case 1
        % tek oscilloscope
        [ X,Y ] = tektronix3014_read(3,config);
    case 2
        % infinium
        waveform=config.OscigroupObj.read(1,20001);
        X=waveform.XData;
        Y=waveform.YData;
end
FY=abs(fft(Y));
N=length(Y);
freq=(0:N-1)/(N*(X(2)-X(1)));
figure;
plot(freq/1e6,FY);
xlabel('Frequency (MHz)');
ylabel('Amplitude');
xlim([2,30]);

% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles) % add array
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% see whether Vservo is array or Vaom is array
Varray=str2double(handles.edit1.String);
if isnan(Varray)
    % Vservo is array
    eval(['Varray=' handles.edit1.String ';']);
    for i=1:length(Varray)
        handles.edit1.String=num2str(Varray(i));
        pushbutton5_Callback(hObject, eventdata, handles) % add to list
    end
else
    % Vaom is array
    eval(['Varray=' handles.edit2.String ';']);
    for i=1:length(Varray)
        handles.edit2.String=num2str(Varray(i));
        pushbutton5_Callback(hObject, eventdata, handles) % add to list
    end    
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles) % connect to EDFA
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
global config;
if hObject.Value
    config.EDFA=IPGPhotonics(config.EDFAResourceStr);
    config.EDFA.connect;
else
    config.EDFA.delete;
end


function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles) % EDFA power output
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
global config;
config.EDFA.Emission(hObject.Value);



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles) % set current
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
current=str2double(handles.edit14.String);
if ~isnan(current) && current>0 && current<2.9
    config.EDFA.Current=current;
end

function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global config;
switch hObject.Value
    case 1
         % AOM
         config.nTransitionPoint=31; % used in linspace(V1,V2, nPoint)
    case 2
         % EDFA
         config.nTransitionPoint=21; % used in linspace(V1,V2, nPoint)
         EDFAcurve=[1.15000000000000,0.604300000000000;1,0.459000000000000;0.850000000000000,0.326400000000000;0.800000000000000,0.278000000000000;0.780000000000000,0.261000000000000;0.760000000000000,0.245600000000000;0.720000000000000,0.214100000000000];
         plot(handles.axes3,EDFAcurve(:,1),EDFAcurve(:,2),'.-');
         xlabel(handles.axes3,'EDFA current (A)');
         ylabel(handles.axes3,'PD power (mW)');
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton32_Callback(hObject, eventdata, handles) % accept power
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% see whether Vservo is array or Vaom is array
global config;
config.StateFz(handles.listbox1.Value,2)=str2double(handles.edit13.String)*1e-3*config.PDPowerCorrectionRatio/config.VVFzMap.Pth;
UpdatePlot(config,handles,true);


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles) % clear history
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global config;
config.VVhistory=[];
config.Fzhistory=[];


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
