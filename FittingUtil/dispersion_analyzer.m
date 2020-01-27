function varargout = dispersion_analyzer(varargin)
% DISPERSION_ANALYZER MATLAB code for dispersion_analyzer.fig
%      DISPERSION_ANALYZER, by itself, creates a new DISPERSION_ANALYZER or raises the existing
%      singleton*.
%
%      H = DISPERSION_ANALYZER returns the handle to a new DISPERSION_ANALYZER or the handle to
%      the existing singleton*.
%
%      DISPERSION_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPERSION_ANALYZER.M with the given input arguments.
%
%      DISPERSION_ANALYZER('Property','Value',...) creates a new DISPERSION_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dispersion_analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dispersion_analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dispersion_analyzer

% Last Modified by GUIDE v2.5 26-Dec-2019 19:52:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dispersion_analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @dispersion_analyzer_OutputFcn, ...
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


% --- Executes just before dispersion_analyzer is made visible.
function dispersion_analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dispersion_analyzer (see VARARGIN)

% Choose default command line output for dispersion_analyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dispersion_analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dispersion_analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ********************************
% Plot window
% ********************************
function display_window_CreateFcn(hObject, eventdata, handles)
xlabel(hObject, 'Mode Number');
xlim(hObject, [-500 500]);
ylabel(hObject, 'Frequency (MHz)');
ylim(hObject, [-10000 10000]);
function display_window_ButtonDownFcn(hObject, eventdata, handles)
pt = hObject.CurrentPoint;
if handles.offset_set.Value
    offset=FromDigits_offset(handles);
    ToDigits_offset(handles,offset-pt(1,2));
    handles.offset_set.Value=0;
elseif handles.FSR_set.Value
    FSR=FromDigits_FSR(handles);
    ToDigits_FSR(handles,FSR+pt(1,2)/pt(1,1));
    handles.FSR_set.Value=0;
elseif handles.D2_set.Value
    ToDigits_D2(handles,2*1000*pt(1,2)/pt(1,1)^2);
    handles.D2_set.Value=0;
end
RefreshPlot(handles);

% ********************************
% Load Panel
% ********************************
function load_load_Callback(hObject, eventdata, handles)
global dispersion_data Data Config;
fullpath=handles.load_file_path.String;
if strcmp(fullpath,'')
    fullpath = [Data.Currfilename '.mat'];
    handles.load_file_path.String = fullpath;
    ToDigits_FSR(handles,str2double(Config.Disk_FSR));
    handles.plot_MZI_coeff.String=['[' Config.D1 ' ' Config.D2 ' ' Config.D3 ']'];
    if isfield(Config, 'ReverseScan') && Config.ReverseScan
        handles.plot_scan_range.String = ['[' Config.Scan_end ' ' Config.Wavelength ' ' Config.Scan_start ']'];
    else
        handles.plot_scan_range.String = ['[' Config.Scan_start ' ' Config.Wavelength ' ' Config.Scan_end ']'];
    end
end
if exist(fullpath,'file')
    load(fullpath);
    if exist('data_matrix','var')
        dispersion_data.data_matrix=data_matrix;
        dispersion_data.mode_hopping_spec=[];
        handles.data_status.String='Data loaded';
        MS_process(handles);
        RefreshPlot(handles);
    else
        handles.data_status.String='Data not found';
    end
else
    handles.data_status.String='File not exist';
end
function load_uiload_Callback(hObject, eventdata, handles)
[filename, pathname]=uigetfile;
if filename
    handles.load_file_path.String=[pathname filename];
    load_load_Callback(hObject, eventdata, handles)
end
function load_clear_Callback(hObject, eventdata, handles)
cla(handles.display_window);
cla(handles.matching_window);
clear global dispersion_data;
handles.load_file_path.String='';
handles.data_status.String='No data';

% ********************************
% Process panel
% ********************************
function process_Qmode_select_Callback(hObject, eventdata, handles)
MS_process(handles);
RefreshPlot(handles);
function process_th_peak_Callback(hObject, eventdata, handles)
MS_process(handles);
RefreshPlot(handles);
function process_th_MZI_Callback(hObject, eventdata, handles)
MS_process(handles);
RefreshPlot(handles);
function process_th_peak_p_Callback(hObject, eventdata, handles)
value=eval(handles.process_th_peak.String);
value=value+3;
handles.process_th_peak.String=num2str(value);
MS_process(handles);
RefreshPlot(handles);
function process_th_peak_m_Callback(hObject, eventdata, handles)
value=eval(handles.process_th_peak.String);
value=value-3;
handles.process_th_peak.String=num2str(value);
MS_process(handles);
RefreshPlot(handles);
function process_th_MZI_p_Callback(hObject, eventdata, handles)
value=eval(handles.process_th_MZI.String);
value=value+3;
handles.process_th_MZI.String=num2str(value);
MS_process(handles);
RefreshPlot(handles);
function process_th_MZI_m_Callback(hObject, eventdata, handles)
value=eval(handles.process_th_MZI.String);
value=value-3;
handles.process_th_MZI.String=num2str(value);
MS_process(handles);
RefreshPlot(handles);

% ********************************
% Plot panel
% ********************************
function plot_laser_select_CreateFcn(hObject, eventdata, handles)
global laser_config;
laser_config=load('laser_config.mat');
laser_config=laser_config.laser_config;
hObject.String=laser_config(1,:);
function plot_laser_select_Callback(hObject, eventdata, handles)
global laser_config;
handles.plot_scan_range.String=mat2str(laser_config{2,hObject.Value});
RefreshPlot(handles);
function plot_scan_range_CreateFcn(hObject, eventdata, handles)
global laser_config;
laser_config=load('laser_config.mat');
laser_config=laser_config.laser_config;
hObject.String=mat2str(laser_config{2,1});
function plot_scan_range_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function plot_MZI_select_CreateFcn(hObject, eventdata, handles)
global MZI_config;
MZI_config=load('MZI_config.mat');
MZI_config=MZI_config.MZI_config;
hObject.String=MZI_config(1,:);
function plot_MZI_select_Callback(hObject, eventdata, handles)
global MZI_config;
MZI_id=hObject.Value;
handles.plot_MZI_coeff.String=mat2str(MZI_config{2,MZI_id});
RefreshPlot(handles);
function plot_MZI_coeff_CreateFcn(hObject, eventdata, handles)
global MZI_config;
MZI_config=load('MZI_config.mat');
MZI_config=MZI_config.MZI_config;
hObject.String=mat2str(MZI_config{2,1});
function plot_MZI_coeff_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function plot_check_color_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function plot_check_10xY_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function plot_hopping_removal_Callback(hObject, eventdata, handles)
global dispersion_data;
dispersion_data.mode_hopping_spec(end+1,1)=eval(handles.plot_hopping_position.String);
dispersion_data.mode_hopping_spec(end,2)=eval(handles.plot_hopping_count.String);
handles.plot_hopping_undo.Enable='on';
RefreshPlot(handles);
function plot_hopping_undo_Callback(hObject, eventdata, handles)
global dispersion_data;
dispersion_data.mode_hopping_spec=dispersion_data.mode_hopping_spec(1:end-1,:);
RefreshPlot(handles);
if isempty(dispersion_data.mode_hopping_spec)
    hObject.Enable='off';
end

% ********************************
% Offset panel
% ********************************
function offset_set_Callback(hObject, eventdata, handles)
handles.FSR_set.Value=0;
handles.D2_set.Value=0;
function offset_head_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=max(value,0);
hObject.String=num2str(value);
RefreshPlot(handles);
function offset_d3_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function offset_d2_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function offset_d1_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function offset_p3_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value+100;
ToDigits_offset(handles,value);
RefreshPlot(handles);
function offset_m3_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value-100;
ToDigits_offset(handles,value);
RefreshPlot(handles);
function offset_p2_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value+10;
ToDigits_offset(handles,value);
RefreshPlot(handles);
function offset_m2_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value-10;
ToDigits_offset(handles,value);
RefreshPlot(handles);
function offset_p1_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value+1;
ToDigits_offset(handles,value);
RefreshPlot(handles);
function offset_m1_Callback(hObject, eventdata, handles)
value=FromDigits_offset(handles);
value=value-1;
ToDigits_offset(handles,value);
RefreshPlot(handles);

% ********************************
% FSR panel
% ********************************
function FSR_set_Callback(hObject, eventdata, handles)
handles.offset_set.Value=0;
handles.D2_set.Value=0;
function FSR_head_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=max(value,0);
hObject.String=num2str(value);
RefreshPlot(handles);
function FSR_d3_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function FSR_d2_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function FSR_d1_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function FSR_p3_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value+1;
ToDigits_FSR(handles,value);
RefreshPlot(handles);
function FSR_m3_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value-1;
ToDigits_FSR(handles,value);
RefreshPlot(handles);
function FSR_p2_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value+0.1;
ToDigits_FSR(handles,value);
RefreshPlot(handles);
function FSR_m2_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value-0.1;
ToDigits_FSR(handles,value);
RefreshPlot(handles);
function FSR_p1_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value+0.01;
ToDigits_FSR(handles,value);
RefreshPlot(handles);
function FSR_m1_Callback(hObject, eventdata, handles)
value=FromDigits_FSR(handles);
value=value-0.01;
ToDigits_FSR(handles,value);
RefreshPlot(handles);

% ********************************
% D2 panel
% ********************************
function D2_set_Callback(hObject, eventdata, handles)
handles.offset_set.Value=0;
handles.FSR_set.Value=0;
function D2_head_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=max(value,0);
hObject.String=num2str(value);
RefreshPlot(handles);
function D2_d2_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function D2_d1_Callback(hObject, eventdata, handles)
value=round(eval(hObject.String));
value=min(max(value,0),9);
hObject.String=num2str(value);
RefreshPlot(handles);
function D2_p2_Callback(hObject, eventdata, handles)
value=FromDigits_D2(handles);
value=value+1;
ToDigits_D2(handles,value)
RefreshPlot(handles);
function D2_m2_Callback(hObject, eventdata, handles)
value=FromDigits_D2(handles);
value=value-1;
ToDigits_D2(handles,value)
RefreshPlot(handles);
function D2_p1_Callback(hObject, eventdata, handles)
value=FromDigits_D2(handles);
value=value+0.1;
ToDigits_D2(handles,value)
RefreshPlot(handles);
function D2_m1_Callback(hObject, eventdata, handles)
value=FromDigits_D2(handles);
value=value-0.1;
ToDigits_D2(handles,value)
RefreshPlot(handles);

% ********************************
% Fit panel
% ********************************
function fit_D3_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function fit_D4_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function fit_tol_Callback(hObject, eventdata, handles)
RefreshPlot(handles);
function fit_order_Callback(hObject, eventdata, handles)
if hObject.Value>1
    handles.fit_sync.Enable='on';
else
    handles.fit_sync.Enable='off';
end
RefreshPlot(handles);
function fit_sync_Callback(hObject, eventdata, handles)
global dispersion_data;
if handles.fit_order.Value>=2
    coeff=coeffvalues(dispersion_data.current_fit);
    D0=FromDigits_offset(handles);
    D0=D0-coeff(1);
    ToDigits_offset(handles,D0);
    D1=FromDigits_FSR(handles);
    D1=D1+coeff(2);
    ToDigits_FSR(handles,D1);
    ToDigits_D2(handles,coeff(3)*1000);
    if handles.fit_order.Value>=3
        handles.fit_D3.String=num2str(round(coeff(4)*1e6));
    else
        handles.fit_D3.String='0';
    end
    if handles.fit_order.Value>=4
        handles.fit_D4.String=num2str(round(coeff(5)*1e9));
    else
        handles.fit_D4.String='0';
    end
RefreshPlot(handles);    
end

% ********************************
% Match panel
% ********************************
function match_popup_Callback(hObject, eventdata, handles)
RefreshPlot(handles,'Match')

% ********************************
% Save & Export panel
% ********************************
function export_Q_Callback(hObject, eventdata, handles)
RefreshPlot(handles,'FitQ')

function export_depth_Callback(hObject, eventdata, handles)
RefreshPlot(handles,'Depth')

% ********************************
% Toolbar
% ********************************
function toolbar_save_ClickedCallback(hObject, eventdata, handles)
global dispersion_data;
fullpath=strrep(handles.load_file_path.String,'.mat','.fig');
[filename, pathname]=uiputfile(fullpath,'Save figure as');
if filename
    figure;
    MS_plot=dispersion_data.MS_plot;
    if handles.plot_check_color.Value
        scatter(MS_plot(:,2),MS_plot(:,3),4,1-MS_plot(:,4),'linewidth',1);
        colorbar;
        colormap(flipud(bone));
        caxis([0 1]);
        grid('off');
    else
        scatter(MS_plot(:,2),MS_plot(:,3),'b','linewidth',1);
        grid('on');
    end
    hold('on');
    if handles.fit_order.Value>1
        xbase=min(MS_plot(:,2)):max(MS_plot(:,2));
        plot(xbase,dispersion_data.current_fit(xbase),'m','linewidth',2);
    end
    hold('off');
    xlabel(handles.display_window, 'Mode Number');
    ylabel(handles.display_window, 'Frequency (MHz)');
    saveas(gcf,[pathname filename]);
    close(gcf);
end

% ********************************
% Modules
% ********************************
function MS_process(handles)
global dispersion_data;
if strcmp(handles.data_status.String,'Data loaded')
    sens_MS=eval(handles.process_th_peak.String); % relative sensitivity of MS, higher = more sensitive, default to 0
    sens_MZI=eval(handles.process_th_MZI.String); % relative sensitivity of MZI, higher = more sensitive, default to 0
    nominal_width=5*10^(handles.process_Qmode_select.Value-1); % estimated peak width, determined by nominal Q values
    trace_MS_raw=dispersion_data.data_matrix(:,end-1);
    trace_MZI_raw=dispersion_data.data_matrix(:,end);
    
    % Filtering
    trace_MS_baseline=sgolayfilt(trace_MS_raw,1,1001); % baseline estimate, using slow-varying envelope
    trace_length=length(trace_MS_raw);
    for index=2:trace_length
        trace_MS_baseline(index)=max([trace_MS_baseline(index) trace_MS_baseline(index-1)*(1-10/trace_length)]);
    end
    for index=trace_length-1:-1:1
        trace_MS_baseline(index)=max([trace_MS_baseline(index) trace_MS_baseline(index+1)*(1-10/trace_length)]);
    end
    trace_MS=trace_MS_raw./trace_MS_baseline;
    trace_MS=sgolayfilt(trace_MS,2,51);
    trace_MZI=(trace_MZI_raw./sgolayfilt(trace_MZI_raw,1,1001))/2;
    trace_MZI=sgolayfilt(trace_MZI,2,51);
    
    % MZI processing
    threshold_MZI=0.5-(quantile(trace_MZI,0.99)-quantile(trace_MZI,0.01))/4/(10.^(sens_MZI/10));
    trace_MZI_diff = diff(trace_MZI); % Find derivative
    ind_dip = find(trace_MZI_diff(1:end-1)<0 & trace_MZI_diff(2:end)>=0)+1; % Find where the derivative changes sign
    ind_dip = ind_dip(trace_MZI(ind_dip)<threshold_MZI); % Apply threshold value
    mag_dip = trace_MZI(ind_dip);
    ind_peak = find(trace_MZI_diff(1:end-1)>0 & trace_MZI_diff(2:end)<=0)+1; % Find where the derivative changes sign
    ind_peak = ind_peak(trace_MZI(ind_peak)>(1-threshold_MZI)); % Apply threshold value
    mag_peak = trace_MZI(ind_peak);
    MZI_extrema=[ind_dip,mag_dip,-ones(size(mag_dip)) ; ind_peak,mag_peak,ones(size(mag_peak))];
    % Three columns store index, magnitude and indicator, +1 for peak and -1 for dip
    MZI_extrema=sortrows(MZI_extrema,1); % Sort by index
    
    % Hopping removal
    MZI_ind0=1; % points to a peak to be compared
    MZI_ind0_type=MZI_extrema(1,3);
    for MZI_ind1=2:length(MZI_extrema) % scan through all peaks
        if MZI_extrema(MZI_ind1,3)~=MZI_ind0_type % correct config
            MZI_ind0=MZI_ind1;
            MZI_ind0_type=-MZI_ind0_type;
        else
            if sign(MZI_extrema(MZI_ind1,2)-MZI_extrema(MZI_ind0,2))==MZI_ind0_type
                % double peak keeps the larger one; double dip keeps the smaller one
                MZI_extrema(MZI_ind0,3)=0;
                MZI_ind0=MZI_ind1;
            else
                MZI_extrema(MZI_ind1,3)=0;
            end
        end
    end
    MZI_index=MZI_extrema(MZI_extrema(:,3)~=0,1);
    % One column store index of peaks & dips
    
    % Transmission processing
    threshold_MS=(quantile(trace_MS,0.99)-quantile(trace_MS,0.5))/(10.^(sens_MS/10));
    trace_MS(trace_MS>1-threshold_MS)=1; % Reject all signals above 1-th
    trace_MS_diff = diff(trace_MS); % Find derivative
    ind_dip = find(trace_MS_diff(1:end-1)<0 & trace_MS_diff(2:end)>=0)+1; % Find where the derivative changes sign
    ind_dip = ind_dip(trace_MS(ind_dip)<(1-2*threshold_MS)); % Reject all peaks above 1-2*th
    mag_dip = trace_MS(ind_dip);
    ind_peak = find(trace_MS_diff(1:end-1)>0 & trace_MS_diff(2:end)<=0)+1; % Find where the derivative changes sign
    ind_peak = ind_peak(trace_MS(ind_peak)<(1-threshold_MS)); % Reject 1s
    mag_peak = trace_MS(ind_peak);
    MS_extrema=[ind_dip,mag_dip,-ones(size(mag_dip)) ; ind_peak,mag_peak,ones(size(mag_peak))];
    % Three columns store index, magnitude and indicator, +1 for peak and -1 for dip
    MS_extrema=sortrows(MS_extrema,1); % Sort by index
    
    % Merging narrow dips together
    for MS_ind=1:length(MS_extrema)-1
        for MS_ind_lookup=MS_ind:length(MS_extrema)
            if MS_extrema(MS_ind_lookup,1)>MS_extrema(MS_ind,1)+nominal_width
                if sign(trace_MS(MS_extrema(MS_ind,1)+nominal_width)-MS_extrema(MS_ind,2))==MS_extrema(MS_ind,3)
                    MS_extrema(MS_ind,3)=0;
                end
                break;
            end
            if sign(MS_extrema(MS_ind_lookup,2)-MS_extrema(MS_ind,2))==MS_extrema(MS_ind,3)
                % peak goes deeper / base goes shallower
                MS_extrema(MS_ind,3)=0;
                break;
            end
        end
    end
    MS_extrema=MS_extrema(MS_extrema(:,3)~=0,:);
    for MS_ind=length(MS_extrema):-1:2
        for MS_ind_lookup=MS_ind:-1:1
            if MS_extrema(MS_ind_lookup,1)<MS_extrema(MS_ind,1)-nominal_width
                if sign(trace_MS(MS_extrema(MS_ind,1)-nominal_width)-MS_extrema(MS_ind,2))==MS_extrema(MS_ind,3)
                    MS_extrema(MS_ind,3)=0;
                end
                break;
            end
            if sign(MS_extrema(MS_ind_lookup,2)-MS_extrema(MS_ind,2))==MS_extrema(MS_ind,3)
                % peak goes deeper / base goes shallower
                MS_extrema(MS_ind,3)=0;
                break;
            end
        end
    end
    MS_extrema=MS_extrema(MS_extrema(:,3)~=0,:);
    
    % Removing low contrast dips
    for MS_ind=2:length(MS_extrema)-1
        if MS_extrema(MS_ind,3)==-1 % scan through all dips
            if MS_extrema(MS_ind-1,3)==1 && MS_extrema(MS_ind-1,2)-MS_extrema(MS_ind,2)<threshold_MS
                MS_extrema(MS_ind,3)=0;
            end
            if MS_extrema(MS_ind+1,3)==1 && MS_extrema(MS_ind+1,2)-MS_extrema(MS_ind,2)<threshold_MS
                MS_extrema(MS_ind,3)=0;
            end
        end
    end
    
    MS_ind=1;
    while MS_extrema(MS_ind,1)<MZI_extrema(1,1)
        MS_extrema(MS_ind,3)=0; % remove peaks outside MZI range
        MS_ind=MS_ind+1;
    end
    MS_ind=length(MS_extrema);
    while MS_extrema(MS_ind,1)>MZI_extrema(end,1)
        MS_extrema(MS_ind,3)=0; % remove peaks outside MZI range
        MS_ind=MS_ind-1;
    end
    MS_index=MS_extrema(MS_extrema(:,3)==-1,1:2);
    % Two columns store dip index and depth
    
    % Peak mapping
    MS_ind=1;
    MS_mu=1;
    MS_mapping=MS_index(:,1);
    MZI_index=[MS_mapping(1)-1;MZI_index];
    MZI_index(end+1)=MS_mapping(end)+1;
    while MS_ind<=length(MS_mapping)
        if MS_mapping(MS_ind)>MZI_index(MS_mu)
            MS_mu=MS_mu+1;
        else
            MS_mapping(MS_ind)=MS_mu-(MZI_index(MS_mu)-MS_mapping(MS_ind))/(MZI_index(MS_mu)-MZI_index(MS_mu-1));
            % linear interpolation to determine mu
            MS_ind=MS_ind+1;
        end
    end
    MS_mapping=[MS_mapping/2,MS_index(:,2)];
    % /2 because both peaks and dips are counted
    % Two columns store MZI mu (count from start) and peak depth
    dispersion_data.MZI_index=MZI_index;
    dispersion_data.MS_mapping=MS_mapping;
end

function RefreshPlot(handles,explot)
global dispersion_data;
if nargin<2
    explot='';
end
if strcmp(handles.data_status.String,'Data loaded')
    MS_mapping=dispersion_data.MS_mapping;
    scan=eval(handles.plot_scan_range.String);
    f_scan_start=299792458/scan(1); % [GHz]
    f_scan_center=299792458/scan(2); % [GHz]
    f_scan_end=299792458/scan(3); % [GHz]
    if f_scan_start>f_scan_end % flip it so MZI mu goes from red to blue
        MS_mapping(:,1)=-MS_mapping(:,1);
    end
    mu_center=MS_mapping(1,1)+(f_scan_center-f_scan_start)/(f_scan_end-f_scan_start)*(MS_mapping(end,1)-MS_mapping(1,1));
    MS_mapping(:,1)=MS_mapping(:,1)-mu_center;
    MS_plot=zeros(size(MS_mapping(:,1)));
    MZI_dispersion=eval(handles.plot_MZI_coeff.String);
    for ind=1:length(MZI_dispersion)
        MS_plot=MS_plot+MZI_dispersion(ind)*MS_mapping(:,1).^ind/factorial(ind);
    end
    if ~isempty(dispersion_data.mode_hopping_spec)
        mode_hopping_pos=[dispersion_data.mode_hopping_spec(:,1)*FromDigits_FSR(handles),dispersion_data.mode_hopping_spec(:,2)*MZI_dispersion(1)];
        for mode_hopping_ind=1:length(mode_hopping_pos(:,1))
            MS_plot=MS_plot-(MS_plot>mode_hopping_pos(mode_hopping_ind,1))*mode_hopping_pos(mode_hopping_ind,2);
        end
    end
    MS_plot(:,1)=MS_plot(:,1)+FromDigits_offset(handles);
    disk_FSR=FromDigits_FSR(handles);
    MS_plot(:,2)=round(MS_plot(:,1)/disk_FSR);
    MS_plot(:,3)=MS_plot(:,1)-MS_plot(:,2)*disk_FSR;
    MS_plot(:,4)=dispersion_data.MS_mapping(:,2);
    MS_plot(:,5)=dispersion_data.MS_mapping(:,1);
    dispersion_data.MS_plot=MS_plot;
    
    % Five columns 
    % corrected freq, resonator mu, freq offset within FSR, depth and MZI mu
    plot(handles.display_window,[0 0],[-1 1]*disk_FSR/2,'k','linewidth',2);
    hold(handles.display_window,'on');
    if handles.plot_check_color.Value
        scatter(handles.display_window,MS_plot(:,2),MS_plot(:,3),4,1-MS_plot(:,4),'linewidth',1);
        grid(handles.display_window,'off');
    else
        scatter(handles.display_window,MS_plot(:,2),MS_plot(:,3),'b','linewidth',1);
        grid(handles.display_window,'on');
    end
    tol=eval(handles.fit_tol.String);
    xbase=min(MS_plot(:,2)):max(MS_plot(:,2));
    ybase=xbase.^2/2*FromDigits_D2(handles)/1e3+xbase.^3/6*eval(handles.fit_D3.String)/1e6+xbase.^4/24*eval(handles.fit_D4.String)/1e9;
    line_group=TorusBreak(xbase,ybase+tol,disk_FSR);
    for ind=1:length(line_group)
        plot(handles.display_window,line_group{ind}(1,:),line_group{ind}(2,:),'c','linewidth',1);
    end
    line_group=TorusBreak(xbase,ybase-tol,disk_FSR);
    for ind=1:length(line_group)
        plot(handles.display_window,line_group{ind}(1,:),line_group{ind}(2,:),'c','linewidth',1);
    end
    if handles.fit_order.Value>1
        MS_merged=TorusMerge(MS_plot(:,2:3),disk_FSR,ybase);
        xfit=MS_merged(:,1);
        yfit=xfit.^2/2*FromDigits_D2(handles)/1e3+xfit.^3/6*eval(handles.fit_D3.String)/1e6+xfit.^4/24*eval(handles.fit_D4.String)/1e9;
        filter=find(abs(MS_merged(:,2)-yfit)<tol);
        xfit=xfit(filter);
        yfit=MS_merged(filter,2);
        if length(xfit)>handles.fit_order.Value
            fitbase={'1' 'x' 'x^2/2' 'x^3/6' 'x^4/24'};
            fitbase=fitbase(1:(1+handles.fit_order.Value));
            F0=fit(xfit,yfit,fittype(fitbase));
            ybase=F0(xbase).';
            line_group=TorusBreak(xbase,ybase,disk_FSR);
            for ind=1:length(line_group)
                plot(handles.display_window,line_group{ind}(1,:),line_group{ind}(2,:),'m','linewidth',2);
            end
            dispersion_data.current_fit=F0;
            handles.fit_sync.Enable='on';
        else
            handles.fit_sync.Enable='off';
        end
    end
    hold(handles.display_window,'off');
    xlabel(handles.display_window, 'Mode Number');
    xlim(handles.display_window,[min(MS_plot(:,2))-20,max(MS_plot(:,2))+20]);
    ylabel(handles.display_window, 'Frequency (MHz)');
    if handles.plot_check_10xY.Value
        ylim(handles.display_window,[-0.05 0.05]*disk_FSR);
    else
        ylim(handles.display_window,[-0.55 0.55]*disk_FSR);
    end
    colorbar(handles.display_window);
    colormap(handles.display_window,flipud(bone));
    caxis(handles.display_window,[0 1]);
    
    handles.display_window.Tag='display_window'; % so that offset, FSR, D2 functions work properly
    handles.display_window.ButtonDownFcn=@(hObject,eventdata)dispersion_analyzer('display_window_ButtonDownFcn',hObject,eventdata,guidata(hObject));
    
    %         MS_merged=TorusMerge(MS_plot(:,2:4),disk_FSR,[-disk_FSR,disk_FSR]/2);
    %         MS_merged=sortrows(MS_merged(MS_merged(:,1)==0,2:3));
    %         MS_merged=MS_merged(abs(MS_merged(:,1))<disk_FSR,:);
    
    MS_match=MS_plot(MS_plot(:,2)==0,3:4);
    line_x=((1-MS_match(:,2))*[0 1 0]).';
    line_x=[0;line_x(:);0];
    line_y=(MS_match(:,1)*[1 1 1]).';
    line_y=[-disk_FSR/2;line_y(:);disk_FSR/2];
    plot(handles.matching_window,line_x,line_y,'b');
    hold(handles.matching_window,'on');
    plot(handles.matching_window,[-1 2],[1 1]*tol,'c');
    plot(handles.matching_window,[-1 2],[-1 -1]*tol,'c');
    
    if f_scan_start<f_scan_end
        match_center_mu=mu_center+(-FromDigits_offset(handles))/MZI_dispersion(1);
        match_start_mu=mu_center+(-FromDigits_offset(handles)-disk_FSR/2)/MZI_dispersion(1);
        match_end_mu=mu_center+(-FromDigits_offset(handles)+disk_FSR/2)/MZI_dispersion(1);
        match_center_index=MuToIndex(match_center_mu,dispersion_data.MZI_index);
        match_range_index=round((MuToIndex(match_end_mu,dispersion_data.MZI_index)-MuToIndex(match_start_mu,dispersion_data.MZI_index))/2);
        mode_matching_trace=dispersion_data.data_matrix(match_center_index-match_range_index:match_center_index+match_range_index,end-1)./max(dispersion_data.data_matrix(:,end-1));
    else
        match_center_mu=-mu_center+(FromDigits_offset(handles))/MZI_dispersion(1);
        match_start_mu=-mu_center+(FromDigits_offset(handles)-disk_FSR/2)/MZI_dispersion(1);
        match_end_mu=-mu_center+(FromDigits_offset(handles)+disk_FSR/2)/MZI_dispersion(1);
        match_center_index=MuToIndex(match_center_mu,dispersion_data.MZI_index);
        match_range_index=round((MuToIndex(match_end_mu,dispersion_data.MZI_index)-MuToIndex(match_start_mu,dispersion_data.MZI_index))/2);
        mode_matching_trace=dispersion_data.data_matrix(match_center_index+match_range_index:-1:match_center_index-match_range_index,end-1)./max(dispersion_data.data_matrix(:,end-1));
    end
    plot(handles.matching_window,mode_matching_trace,...
        linspace(-disk_FSR/2,disk_FSR/2,2*match_range_index+1),'r');
    hold(handles.matching_window,'off');
    xlim(handles.matching_window,[-0.1,1.1]);
    ylim(handles.matching_window,[-1 1]*disk_FSR/2);
    handles.matching_window.XTick=[];
    handles.matching_window.YTick=[];
    
    if strcmp(explot,'Match')
        figure(1234);
        plot(-linspace(-disk_FSR/2,disk_FSR/2,2*match_range_index+1),...
            mode_matching_trace,'r');
        ylim([0 1.1*max(mode_matching_trace)]);
    end
    
    if strcmp(explot,'Depth') && handles.fit_order.Value>1 % Extract depth
        eta = MS_plot(filter,4);
        save('ExtractedData.mat','xfit','yfit','eta','F0');
    end
        
    if strcmp(explot,'FitQ') && handles.fit_order.Value>1 % Extract Q
        targeted_mu=MS_plot(filter,5);
        targeted_freq=zeros(size(targeted_mu));
        targeted_Q0=targeted_freq;
        targeted_Q1=targeted_freq;
        targeted_QL=targeted_freq;
        for ind=1:length(targeted_mu)
            disp(['Processing ' num2str(ind) ' of ' num2str(length(targeted_mu))])
            fitq_center_mu=targeted_mu(ind);
            fitq_start_mu=targeted_mu(ind)-tol/MZI_dispersion(1);
            fitq_end_mu=targeted_mu(ind)+tol/MZI_dispersion(1);
            fitq_center_index=MuToIndex(fitq_center_mu,dispersion_data.MZI_index);
            fitq_range_index=round((MuToIndex(fitq_end_mu,dispersion_data.MZI_index)-MuToIndex(fitq_start_mu,dispersion_data.MZI_index))/2);
            fitq_trace_Q=dispersion_data.data_matrix(fitq_center_index-fitq_range_index:fitq_center_index+fitq_range_index,end-1);
            fitq_trace_MZI=dispersion_data.data_matrix(fitq_center_index-fitq_range_index:fitq_center_index+fitq_range_index,end);
            if f_scan_start<f_scan_end
                targeted_freq(ind)=f_scan_center+(fitq_center_mu-mu_center)*MZI_dispersion(1)/1000;
            else
                targeted_freq(ind)=f_scan_center+(-fitq_center_mu-mu_center)*MZI_dispersion(1)/1000;
            end
            Qobj=Q_trace_fit(fitq_trace_Q,fitq_trace_MZI,MZI_dispersion(1),...
                299792458/targeted_freq(ind),1-0.1*10.^(-eval(handles.process_th_peak.String)/10),'all');
            targeted_Q_matrix=Qobj.get_Q;
            try
                targeted_Q0(ind)=targeted_Q_matrix(1,1);
                targeted_Q1(ind)=targeted_Q_matrix(1,2);
                targeted_QL(ind)=targeted_Q_matrix(1,3);
                if mod(ind,10)==5
                    Qobj.plot_Q_max;
                end
            catch
                continue;
            end
        end
        figure;
        plot(299792458./targeted_freq,([targeted_freq./targeted_Q0,targeted_freq./targeted_Q1,targeted_freq./targeted_QL]/1e3).','.-');
    end
end

function value=FromDigits_offset(handles)
value_char=[handles.offset_sign.String handles.offset_head.String handles.offset_d3.String handles.offset_d2.String handles.offset_d1.String];
value=eval(value_char);
function ToDigits_offset(handles,value)
if value<0
    handles.offset_sign.String='-';
    value=-value;
else
    handles.offset_sign.String='+';
end
value=round(value);
for ind=1:3
    eval(['handles.offset_d' num2str(ind) '.String=' num2str(mod(value,10)) ';']);
    value=floor(value/10);
end
handles.offset_head.String=num2str(value);
function value=FromDigits_FSR(handles)
value_char=[handles.FSR_head.String handles.FSR_d3.String '.' handles.FSR_d2.String handles.FSR_d1.String];
value=eval(value_char);
function ToDigits_FSR(handles,value)
value=round(100*value);
for ind=1:3
    eval(['handles.FSR_d' num2str(ind) '.String=' num2str(mod(value,10)) ';']);
    value=floor(value/10);
end
handles.FSR_head.String=num2str(value);
function value=FromDigits_D2(handles)
value_char=[handles.D2_sign.String handles.D2_head.String handles.D2_d2.String '.' handles.D2_d1.String];
value=eval(value_char);
function ToDigits_D2(handles,value)
if value<0
    handles.D2_sign.String='-';
    value=-value;
else
    handles.D2_sign.String='+';
end
value=round(10*value);
for ind=1:2
    eval(['handles.D2_d' num2str(ind) '.String=' num2str(mod(value,10)) ';']);
    value=floor(value/10);
end
handles.D2_head.String=num2str(value);
function data_cell=TorusBreak(xbase,ybase,period) %base: 1*n
offset=round(ybase(1,:)/period);
ybase(1,:)=ybase(1,:)-offset*period;
xbase=xbase+offset;
data_group=[xbase;ybase];
end_point=find(diff(offset)).';
start_point=[1;end_point+1];
end_point=[end_point;length(xbase)];
data_cell=cell(1,length(start_point));
for ind=1:length(start_point)
    data_cell{ind}=data_group(:,start_point(ind):end_point(ind));
end
function data_merged=TorusMerge(data,period,ybase) %data: n*1, base: 1*n
offset=round(ybase(1,:)/period);
off_max=max(offset);
off_min=min(offset);
data_merged=[];
for ind=off_min:off_max
    data_append=data;
    data_append(:,1)=data_append(:,1)-ind;
    data_append(:,2)=data_append(:,2)+ind*period;
    data_merged=[data_merged;data_append];
end
function ind=MuToIndex(mu,MZI_index) % convert mu to raw index
mu=2*mu;
if mu==round(mu)
    ind=MZI_index(mu);
else
    ind=MZI_index(floor(mu))*(ceil(mu)-mu)+MZI_index(ceil(mu))*(mu-floor(mu));
end
ind=round(ind);
