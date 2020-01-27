function varargout = scanQ(varargin)
% SCANQ MATLAB code for scanQ.fig
%      SCANQ, by itself, creates a new SCANQ or raises the existing
%      singleton*.
%
%      H = SCANQ returns the handle to a new SCANQ or the handle to
%      the existing singleton*.
%
%      SCANQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANQ.M with the given input arguments.
%
%      SCANQ('Property','Value',...) creates a new SCANQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scanQ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scanQ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scanQ

% Last Modified by GUIDE v2.5 21-Dec-2019 16:29:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scanQ_OpeningFcn, ...
                   'gui_OutputFcn',  @scanQ_OutputFcn, ...
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


% --- Executes just before scanQ is made visible.
function scanQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scanQ (see VARARGIN)

% Choose default command line output for scanQ
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% load configuration
global Config;
load ('config.mat','Config');
handles.Directory.String = Config.Directory;
handles.Condition.String = Config.Condition;
handles.Wavelength.String = Config.Wavelength;
handles.MZI_FSR.String = Config.MZI_FSR;
handles.Scan_start.String = Config.Scan_start;
handles.Scan_end.String = Config.Scan_end;
handles.ReverseScan.Value = Config.ReverseScan;
handles.Disk_FSR.String = Config.Disk_FSR;
handles.MZI_D1.String = Config.D1;
handles.MZI_D2.String = Config.D2;
handles.MZI_D3.String = Config.D3;
handles.Delay.String = Config.Delay;
if isfield(Config,'Scan')
    handles.Scan.Value = 1;
    handles.Scan_Range.String = Config.Scan;
end
if isfield(Config,'Q')
    handles.Srate.String = Config.Q.Srate;
    handles.Scale.String = Config.Q.Scale;
end
instrreset;
clc;

% UIWAIT makes scanQ wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scanQ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in B_Connect.
function B_Connect_Callback(hObject, eventdata, handles)
global Device Config;
try
    if strcmp(hObject.String,'Connect')
        hObject.String = 'Disconnect';
        load('config.mat','Device');
        if ischar(Device.laser1)
            eval(['Device.laser1 =' Device.laser1 '();']);
        end
        if ischar(Device.laser2)
            Device.laser2 = Device.laser1;
        end
        Device.osc.connect;
        Device.laser1.connect;
        if Device.laser2 ~= Device.laser1
            Device.laser2.connect;
        end
        if isfield(Device,'fg')
            Device.fg.connect;
        end
    else
        hObject.String = 'Connect';
        Device.laser1.disconnect;
        Device.laser2.disconnect;
        Device.osc.Stop;
        Device.osc.disconnect;
        if isfield(Device,'fg')
            Device.fg.CH1(0);
            Device.fg.disconnect;
        end
    end
catch ME
    disp(ME.message);
end
if Device.laser1.isconnected
    handles.B_Move.Enable = 'on';
    if isfield(Config,'Current')
        handles.B_LaserOn.Enable = 'on';
        if Device.laser1.PowerON
            handles.B_LaserOn.String = 'Power off';
            handles.B_LaserOn.ForegroundColor = [0,0.6,0];
        else
            handles.B_LaserOn.String = 'Power on';
        end
    end
else
    handles.B_Move.Enable = 'off';
    handles.B_LaserOn.Enable = 'off';
end
if Device.osc.isconnected
    handles.B_Set.Enable = 'on';
else
    handles.B_Set.Enable = 'off';
end
fprintf('\n');


% --- Executes on button press in B_LaserOn.
function B_LaserOn_Callback(hObject, eventdata, handles)
% hObject    handle to B_LaserOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Device Config;
hObject.Enable = 'off';
if Device.laser1.PowerON
%     if isfield(Device,'fg')
%        Device.fg.CH1(0);
%     end
    hObject.String = 'Power on';
    hObject.ForegroundColor = [0,0,0];
    Device.laser1.Current = 0;
    pause(6);
    Device.laser1.PowerON = 0;
else
%     if isfield(Device,'fg')
%        Device.fg.CH1(1);
%     end
    hObject.String = 'Power off';
    hObject.ForegroundColor = [0,0.6,0];
    Device.laser1.PowerON = 1;
    pause(6);
    Device.laser1.Current = handles.Wavelength.String;
end
hObject.Enable = 'on';

% --- Executes on button press in B_Move.

function B_Move_Callback(hObject, eventdata, handles)
global Device;
if isfield(Device,'fg')
    Device.fg.CH1(0);
end
Device.laser1.Move2Wavelength(str2double(handles.Wavelength.String));
if isfield(Device,'fg')
    Device.fg.CH1(1);
end


function Wavelength_Callback(hObject, eventdata, handles)
% hObject    handle to Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wavelength as text
%        str2double(get(hObject,'String')) returns contents of Wavelength as a double


% --- Executes during object creation, after setting all properties.
function Wavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Current_Callback(hObject, eventdata, handles)
% hObject    handle to Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Current as text
%        str2double(get(hObject,'String')) returns contents of Current as a double


% --- Executes during object creation, after setting all properties.
function Current_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Directory_Callback(hObject, eventdata, handles)
if ~isempty(hObject.String) && hObject.String(end) ~= '\'
    hObject.String = [hObject.String '\'];
end


% --- Executes during object creation, after setting all properties.
function Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Condition_Callback(hObject, eventdata, handles)
% hObject    handle to Condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Condition as text
%        str2double(get(hObject,'String')) returns contents of Condition as a double


% --- Executes during object creation, after setting all properties.
function Condition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Method.
function Method_Callback(hObject, eventdata, handles)
global Config;
handles.SetWhenRun.Value = 1;
handles.Scan.Value = 0;
handles.Scan.Enable = 'off';
handles.Scan_Range.Enable = 'off';
handles.L_Delay.Visible = 'off';
handles.Delay.Visible = 'off';
handles.Corr.Visible = 'off';
switch hObject.Value
    case 1
        handles.Prefix.String = '';
        if isfield(Config,'Q')
            handles.Srate.String = Config.Q.Srate;
            handles.Scale.String = Config.Q.Scale;
        end
        handles.Scan.Enable = 'on';
        handles.Scan_Range.Enable = 'on';
        handles.Corr.Visible = 'on';
        if ~isempty(handles.Scan_Range.String)
            handles.Scan.Value = 1;
        end
    case 2
        handles.Prefix.String = 'disper\';
        if isfield(Config,'D')
            handles.Srate.String = Config.D.Srate;
            handles.Scale.String = Config.D.Scale;
        end
        handles.L_Delay.Visible = 'on';
        handles.Delay.Visible = 'on';
    case 3
        handles.Prefix.String = 'ringdown\';
    case 4
        handles.Prefix.String = 'etc\';
end


% --- Executes during object creation, after setting all properties.
function Method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in B_Run.
function B_Run_Callback(hObject, eventdata, handles)
global Data Config Device;
directory = [handles.Directory.String, handles.Prefix.String];
if ~isdir(directory)
    mkdir(directory)
end
filename_raw = [directory, handles.Condition.String];
% close all
srate = str2double(handles.Srate.String);
scale = str2double(handles.Scale.String);
if strcmp(handles.Points.String,'AUTO')
    point = srate * 10 * scale;
else
    point = str2double(handles.Points.String);
end
if strcmp(handles.B_Connect.String,'Connect')
    B_Connect_Callback(handles.B_Connect, eventdata, handles)
end
if handles.SetWhenRun.Value && handles.Method.Value < 4
    B_Set_Callback([], [], handles);
    handles.SetWhenRun.Value = 0;
end

switch handles.Method.Value
    case 1
        %% Q Measurement
        lambda = str2double(handles.Wavelength.String);
        FSR_MZI = str2double(handles.MZI_FSR.String);
        if handles.Scan.Value
            Device.osc.Run;
            eval(['lambda = ' handles.Scan_Range.String ';']);
        end
        for idx = 1:numel(lambda)
            filename = [filename_raw '-',num2str(lambda(idx)),'nm'];
            if abs(Device.laser1.Wavelength - lambda(idx)) > 0.5
                Device.laser1.Move2Wavelength(lambda(idx));
                pause(1);
            end
            disp(['wavelength ', num2str(lambda(idx)), ' nm in progress...'])
            ReadTrace(filename,Device.osc,point,Config.trans_ch,Config.mzi_ch);
            Device.osc.Run;
            load([filename,'.mat'],'data_matrix','-mat');
            if exist('data_matrix','var')
                trans = data_matrix(:,2);
                mzi = data_matrix(:,3);
            end
            Q_obj=Q_trace_fit(trans,mzi,FSR_MZI,lambda(idx),str2double(handles.QSens.String),handles.Corr.String);
            if (numel(Q_obj.modeQ0) > 0)
                Qstat=Q_obj.plot_Q_stat;
                saveas(gcf,[filename,'_Qstats.png']);
                saveas(gcf,[filename,'_Qstats.fig']);
                tracestat=Q_obj.plot_trace_stat;
                saveas(gcf,[filename,'_trace.png']);
                saveas(gcf,[filename,'_trace.fig']);
                Qmax=Q_obj.plot_Q_max;
                saveas(gcf,[filename,'_Q_max=' num2str(Q_obj.modeQ0(1),'%.4g') 'M.png']);
                saveas(gcf,[filename,'_Q_max=' num2str(Q_obj.modeQ0(1),'%.4g') 'M.fig']);
                disp(['Maximum intrinsic Q = ' num2str(Q_obj.modeQ0(1),'%.4g') 'M']);
            else
                disp('No mode detected');
            end
            Data.Q_obj = Q_obj;
        end
    case 2
        %% Dispersion Measurement
        filename = [filename_raw,'-',handles.Scan_start.String,'-',handles.Scan_end.String,'nm'];
        scan_start = str2double(handles.Scan_start.String);
        scan_end = str2double(handles.Scan_end.String);
        Device.laser2.SetScan(scan_start,scan_end,Config.slewrate);
        disp('Returning to start wavelength...')
%         Device.osc.Stop;
        Device.laser2.Move2Wavelength(scan_start);
        pause(5);
        % Scan
        delay = str2double(handles.Delay.String);
        B_Set_Callback([], [], handles);
        if (delay > 0)
            Device.osc.Single;
            pause(delay);
            Device.laser2.Scan;
        else
            Device.laser2.Scan;
            pause(-delay);
            Device.osc.Single;
        end
        disp('Scanning...');
        pause(Config.Scan_time);
        disp('Reading...');
        if ~isfield(Config,'mzi2_ch')
            Config.mzi2_ch = Config.mzi_ch;
        end
        ReadTrace(filename,Device.osc,point,Config.trans_ch,Config.mzi2_ch);
        Data.Currfilename = filename;
        mfileloc = mfilename('fullpath');
        cd(mfileloc(1:end-14));
        run('..\FittingUtil\dispersion_analyzer.m');

%         disp('Processing started');
%         Disper = ProcessDispersion(handles,filename);
%         Data.Disper = Disper;
%         Disper.plot_results;
%         disk_FSR = str2double(handles.Disk_FSR.String);
%         saveas(gcf,[filename,'_scatter_D1=', num2str(disk_FSR/10^3,7),'GHz.fig'])
%         saveas(gcf,[filename,'_scatter_D1=', num2str(disk_FSR/10^3,7),'GHz.png'])
%         Disper.plot_results('color');
%         saveas(gcf,[filename,'_dispersion_color_D1=', num2str(disk_FSR/10^3,7),'GHz.fig'])
%         saveas(gcf,[filename,'_dispersion_color_D1=', num2str(disk_FSR/10^3,7),'GHz.png'])
%         EnableDispersionProcess(handles,'on');
        Device.laser2.Move2Wavelength(Config.final);
    case 3
        %% Ringdown
        for ii = 1:10
            lambda = str2double(handles.Wavelength.String);
            FSR_MZI = str2double(handles.MZI_FSR.String);
            filename=[filename_raw,'-',num2str(lambda),'nm-Num',num2str(ii)];
            ReadTrace(filename,Device.osc,point,Config.trans_ch,Config.mzi_ch);
            Device.osc.Run;
            load([filename,'.mat']);
            if exist('data_matrix','var')
                time = data_matrix(:,1);
                trans = data_matrix(:,2);
                mzi = data_matrix(:,3);
            end
            Qfit = ringdown_trace_fit(time,trans,mzi,FSR_MZI,lambda,1.1);
            if (numel(Qfit.modeQ0) > 0)
                tracestat=Qfit.plot_trace_stat;
                saveas(gcf,[filename,'_trace.png']);
                saveas(gcf,[filename,'_trace.fig']);
                Qmax=Qfit.plot_Q_max;
                saveas(gcf,[filename,'_Q_max=' num2str(Qfit.modeQ0(1),'%.4g') 'M.png']);
                saveas(gcf,[filename,'_Q_max=' num2str(Qfit.modeQ0(1),'%.4g') 'M.fig']);
            else
                disp('No mode detected');
            end
        end
    case 4
        %% Reading
        NChan = 4; % Number of channel
        %% Device.osc.Stop;
        [X,Y] = Device.osc.readmultipletrace(NChan,[]);
        figure;
        for ii = 1:NChan
            chanstr=['Channel ',num2str(ii)];
            plot(X,Y(:,ii),'DisplayName',chanstr);
            legend('-DynamicLegend');
            hold on
        end
        save([filename_raw '.mat'],'X','Y');
        filename = filename_raw;
end
Data.Currfilename = filename;
fprintf('Finished\r\n');



function Prefix_Callback(hObject, eventdata, handles)
% hObject    handle to Prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Prefix as text
%        str2double(get(hObject,'String')) returns contents of Prefix as a double


% --- Executes during object creation, after setting all properties.
function Prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in B_Goto.
function B_Goto_Callback(hObject, eventdata, handles)
% Open current directory
winopen([handles.Directory.String, handles.Prefix.String]);


% --- Executes on button press in B_Clear.
function B_Clear_Callback(hObject, eventdata, handles)
global Data;
if isfield(Data,'Disper')
    Data = rmfield(Data,'Disper');
end
EnableDispersionProcess(handles,'off');
instrreset;


% --- Executes on button press in B_SaveSetting.
function B_SaveSetting_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
global Config;
Config.Directory = handles.Directory.String;
Config.Condition = handles.Condition.String;
save('config.mat','Config','-append');


function Corr_Callback(hObject, eventdata, handles)
% hObject    handle to Corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Corr as text
%        str2double(get(hObject,'String')) returns contents of Corr as a double


% --- Executes during object creation, after setting all properties.
function Corr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QSens_Callback(hObject, eventdata, handles)
% hObject    handle to QSens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QSens as text
%        str2double(get(hObject,'String')) returns contents of QSens as a double


% --- Executes during object creation, after setting all properties.
function QSens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QSens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Scan.
function Scan_Callback(hObject, eventdata, handles)
% hObject    handle to Scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Scan



function Scan_Range_Callback(hObject, eventdata, handles)
% hObject    handle to Scan_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scan_Range as text
%        str2double(get(hObject,'String')) returns contents of Scan_Range as a double


% --- Executes during object creation, after setting all properties.
function Scan_Range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scan_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
