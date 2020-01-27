function varargout = ExperimentGUI(varargin)
% EXPERIMENTGUI MATLAB code for ExperimentGUI.fig
%      EXPERIMENTGUI, by itself, creates a new EXPERIMENTGUI or raises the existing
%      singleton*.
%
%      H = EXPERIMENTGUI returns the handle to a new EXPERIMENTGUI or the handle to
%      the existing singleton*.
%
%      EXPERIMENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTGUI.M with the given input arguments.
%
%      EXPERIMENTGUI('Property','Value',...) creates a new EXPERIMENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExperimentGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExperimentGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ExperimentGUI

% Last Modified by GUIDE v2.5 04-Jan-2020 14:57:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExperimentGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ExperimentGUI_OutputFcn, ...
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


% --- Executes just before ExperimentGUI is made visible.
function ExperimentGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExperimentGUI (see VARARGIN)

% Choose default command line output for ExperimentGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExperimentGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

mfileloc = mfilename('fullpath');
cd(mfileloc(1:end-14));

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

% --- Outputs from this function are returned to the command line.
function varargout = ExperimentGUI_OutputFcn(hObject, eventdata, handles) %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

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

function Directory_Callback(hObject, eventdata, handles)
if ~isempty(hObject.String) && hObject.String(end) ~= '\'
    hObject.String = [hObject.String '\'];
end

function Directory_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Prefix_Callback(hObject, eventdata, handles)

function Prefix_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Condition_Callback(hObject, eventdata, handles)

function Condition_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B_Goto_Callback(hObject, eventdata, handles)
% Open current directory
winopen([handles.Directory.String, handles.Prefix.String]);

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

function Method_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Wavelength_Callback(hObject, eventdata, handles)

function Wavelength_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MZI_FSR_Callback(hObject, eventdata, handles)

function MZI_FSR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Scan_start_Callback(hObject, eventdata, handles)

function Scan_start_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Scan_end_Callback(hObject, eventdata, handles) %#ok<*INUSD>

function Scan_end_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MZI_D1_Callback(hObject, eventdata, handles)

function MZI_D1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MZI_D2_Callback(hObject, eventdata, handles)

function MZI_D2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MZI_D3_Callback(hObject, eventdata, handles)

function MZI_D3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Disk_FSR_Callback(hObject, eventdata, handles)

function Disk_FSR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pos_Callback(hObject, eventdata, handles)

function pos_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mag_Callback(hObject, eventdata, handles)

function mag_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Configuration Setting
function B_Clear_Callback(hObject, eventdata, handles)
global Data;
if isfield(Data,'Disper')
    Data = rmfield(Data,'Disper');
end
EnableDispersionProcess(handles,'off');
instrreset;

function B_SaveSetting_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
global Config;
Config.Directory = handles.Directory.String;
Config.Condition = handles.Condition.String;
save('config.mat','Config','-append');

%% Laser Setting
function Scan_Callback(hObject, eventdata, handles)

function Scan_Range_Callback(hObject, eventdata, handles)

function Scan_Range_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B_Move_Callback(hObject, eventdata, handles)
global Device;
if isfield(Device,'fg')
    Device.fg.CH1(0);
end
Device.laser1.Move2Wavelength(str2double(handles.Wavelength.String));
if isfield(Device,'fg')
    Device.fg.CH1(1);
end

function B_LaserOn_Callback(hObject, eventdata, handles)
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
    Device.laser1.Current = handles.Current.String;
end
hObject.Enable = 'on';

%% OSC Setting
function Points_Callback(hObject, eventdata, handles)

function Points_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Srate_Callback(hObject, eventdata, handles)

function Srate_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Scale_Callback(hObject, eventdata, handles)

function Scale_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Delay_Callback(hObject, eventdata, handles)

function Delay_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SetWhenRun_Callback(hObject, eventdata, handles)

function B_Set_Callback(hObject, eventdata, handles)
global Device;

switch handles.Method.Value
    case 1
        Device.osc.Qsetting;
        if isfield(Device,'fg')
            Device.fg.CH1(1);
        end
        Device.osc.Run;
    case 2
        Device.osc.dispersionsetting;
        if isfield(Device,'fg')
            Device.fg.CH1(0);
        end
    case 3
        Device.osc.ringdownsetting;
end

Device.osc.SetScale(handles.Scale.String, handles.Points.String, handles.Srate.String)

%% Experiment Section
function Corr_Callback(hObject, eventdata, handles)

function Corr_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
            ReadTrace(filename,Device.osc,point,Config.trans_ch,Config.mzi_ch,0,str2double(handles.edit34.String) );
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
        ReadTrace(filename,Device.osc,point,Config.trans_ch,Config.mzi2_ch,0,str2double(handles.edit34.String));
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

%% Dispersion Process
function Disper = ProcessDispersion(handles,filename)
load([filename '.mat']);
if exist('data_matrix','var')
    if size(data_matrix,2) == 2 % old format
        trans = data_matrix(:,1);
        mzi = data_matrix(:,2);
    else
        trans = data_matrix(:,2);
        mzi = data_matrix(:,3);
    end
end
if exist(handles.Condition.String,'var')
    eval(['trans = ' handles.Condition.String '(:,1);']);
    eval(['mzi = ' handles.Condition.String '(:,2);']);
end
disk_fsr = str2double(handles.Disk_FSR.String);
if handles.ReverseScan.Value
    scan_start = str2double(handles.Scan_end.String);
    scan_end = str2double(handles.Scan_start.String);
else
    scan_start = str2double(handles.Scan_start.String);
    scan_end = str2double(handles.Scan_end.String);
end
center = str2double(handles.Wavelength.String);
D1_MZI_0 = str2double(handles.MZI_D1.String);
D2_MZI_0 = str2double(handles.MZI_D2.String);
D3_MZI_0 = str2double(handles.MZI_D3.String);
Disper = Dispersion_process(trans,mzi,disk_fsr,scan_start,scan_end,center,D1_MZI_0,D2_MZI_0,D3_MZI_0);
Disper.process;
save([filename '-processed.mat'],'Disper');

function ReverseScan_Callback(hObject, eventdata, handles)

function Offset_Callback(hObject, eventdata, handles)

function Offset_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function D1_Callback(hObject, eventdata, handles)

function D1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function D2_Callback(hObject, eventdata, handles)

function D2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function D3_Callback(hObject, eventdata, handles)

function D3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function D4_Callback(hObject, eventdata, handles)

function D4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function u0_Callback(hObject, eventdata, handles)

function u0_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function u_min_Callback(hObject, eventdata, handles)

function u_min_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function u_max_Callback(hObject, eventdata, handles)

function u_max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B_load_Callback(hObject, eventdata, handles)
global Data;
filename = [handles.Directory.String, handles.Prefix.String, handles.Condition.String , ...
    '-',handles.Scan_start.String,'-',handles.Scan_end.String,'nm'];
if ~exist([filename '.mat'],'file')
    filename = [handles.Directory.String, handles.Prefix.String, handles.Condition.String , ...
        '_',handles.Scan_start.String,'-',handles.Scan_end.String,'nm'];
end
Data.Currfilename = filename;
if exist([filename '-processed.mat'],'file')
    disp('loading...');
    load([filename '-processed.mat']);
else
    Disper = ProcessDispersion(handles,filename);
end
handles.Modeidx.Value = Disper.lastidx;
disk_FSR = Disper.curr_mode.D1;Disper.plot_results;
saveas(gcf,[filename,'_scatter_D1=', num2str(disk_FSR/10^3,7),'GHz.fig'])
saveas(gcf,[filename,'_scatter_D1=', num2str(disk_FSR/10^3,7),'GHz.png'])
Disper.plot_results('color');
saveas(gcf,[filename,'_dispersion_color_D1=', num2str(disk_FSR/10^3,7),'GHz.fig'])
saveas(gcf,[filename,'_dispersion_color_D1=', num2str(disk_FSR/10^3,7),'GHz.png'])
Data.Disper = Disper;
EnableDispersionProcess(handles,'on');
disp('Done');

function EnableDispersionProcess(handles,b)
handles.B_Removehopping.Enable = b;
handles.B_Back.Enable = b;
handles.B_Plot.Enable = b;
handles.B_Fit.Enable = b;
handles.B_Colorplot.Enable = b;
handles.B_Extract.Enable = b;
handles.Modeidx.Enable = b;
if strcmp(b,'on')
    Load_Mode(handles);
else
    handles.Modeidx.Value = 1;
end

function B_Removehopping_Callback(hObject, eventdata, handles)
global Data;
if isfield(Data,'Disper')
    if isempty(handles.pos.String) || isempty(handles.mag.String)
        close all;
        Data.Disper.plot_results;
    else
        pos = str2double(handles.pos.String);
        mag = str2double(handles.mag.String);
        Data.Disper.add(pos,mag);
    end
end

function B_Back_Callback(hObject, eventdata, handles)
global Data;
if isfield(Data,'Disper')
    Data.Disper.remove;
end

function B_Save_Callback(hObject, eventdata, handles)
global Data;
if isfield(Data,'Disper')
    Disper = Data.Disper;
    save([Data.Currfilename '-processed.mat'],'Disper');
    display_offset = -Disper.curr_mode.D1/2;
    x = floor(Disper.peaks_frq/Disper.curr_mode.D1);
    y = Disper.peaks_frq - x * Disper.curr_mode.D1 + display_offset;
    save([Data.Currfilename '-xy.mat'],'x','y');
    disp('Saved');
else
    disp('No data');
end

function Modeidx_Callback(hObject, eventdata, handles)
global Data;
if hObject.Value <= numel(Data.Disper.modefamily)
    Load_Mode(handles);
else
    Data.Disper.modefamily{end + 1} = Data.Disper.modefamily{1};
    disp('New mode!');
end

function Modeidx_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B_Plot_Callback(hObject, eventdata, handles)
global Data;
Save_Mode(handles);
Load_Mode(handles);
close all;
Data.Disper.plot_results('raw');

function B_Fit_Callback(hObject, eventdata, handles)
global Data;
Save_Mode(handles);
Load_Mode(handles);
close all;
Data.Disper.plot_results('fit');

function B_Colorplot_Callback(hObject, eventdata, handles)
global Data
Save_Mode(handles);
Load_Mode(handles);
close all;
Data.Disper.plot_results('color');

function Load_Mode(handles) % Load mode to UI
global Data;
Data.Disper.lastidx = handles.Modeidx.Value;
if numel(handles.Modeidx.String) ~= numel(Data.Disper.modefamily) + 1  %refresh Modeidx Items
    handles.Modeidx.String = cell([numel(Data.Disper.modefamily) + 1,1]);
    for ii = 1:numel(Data.Disper.modefamily)
        handles.Modeidx.String{ii} = ['Mode' num2str(ii)];
    end
    handles.Modeidx.String{end} = 'New';
end
mode = Data.Disper.curr_mode;
handles.D1.String = num2str(mode.D1);
handles.Offset.String = num2str(mode.Offset);
if isfield(mode,'D2')
    handles.D2.String = num2str(mode.D2 * 1e3);
    if isfield(mode,'D3')
        handles.D3.String = num2str(mode.D3 * 1e6);
        if isfield(mode,'D4')
            handles.D4.String = num2str(mode.D4 * 1e9);
        end
    end
end
if isfield(mode,'u0')
    handles.u0.String = num2str(mode.u0);
end

function Save_Mode(handles) % Save mode from UI
global Data;
modeidx = handles.Modeidx.Value;
Data.Disper.lastidx = handles.Modeidx.Value;
mode.D1 = str2double(handles.D1.String);
mode.Offset = str2double(handles.Offset.String);
mode.D2 = 0;
mode.D3 = 0;
mode.D4 = 0;
if ~isempty(handles.D2.String)
    mode.D2 = str2double(handles.D2.String) / 1e3;
    if ~isempty(handles.D3.String)
        mode.D3 = str2double(handles.D3.String) / 1e6;
        if ~isempty(handles.D4.String)
            mode.D4 = str2double(handles.D4.String) / 1e9;
        end
    end
end
if ~isempty(handles.u0.String)
    mode.u0 = str2double(handles.u0.String);
else
    mode.u0 = 0;
end
Data.Disper.modefamily{modeidx} = mode;

function B_Extract_Callback(hObject, eventdata, handles)
global Data
Load_Mode(handles);
close all;
Data.Disper.plot_local(str2double(handles.u_min.String),str2double(handles.u_max.String));


function QSens_Callback(hObject, eventdata, handles)


function QSens_CreateFcn(hObject, eventdata, handles)

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



function Piezo_Callback(hObject, eventdata, handles)
% hObject    handle to Piezo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Piezo as text
%        str2double(get(hObject,'String')) returns contents of Piezo as a double


% --- Executes during object creation, after setting all properties.
function Piezo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Piezo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in B_SetPZT.
function B_SetPZT_Callback(hObject, eventdata, handles)
% hObject    handle to B_SetPZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Device
% hObject    handle to B_SetCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.Piezo.String)&& str2double(handles.Piezo.String)<100
    Device.laser1.Move2Piezo(str2double(handles.Piezo.String));
end



% --- Executes on button press in B_SetCurrent.
function B_SetCurrent_Callback(hObject, eventdata, handles)
global Device
% hObject    handle to B_SetCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.Current.String)&& str2double(handles.Current.String)<=200
    Device.laser1.Current = str2double(handles.Current.String);
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over QSens.
function QSens_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to QSens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on QSens and none of its controls.
function QSens_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to QSens (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
