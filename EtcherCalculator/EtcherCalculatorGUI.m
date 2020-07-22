function varargout = EtcherCalculatorGUI(varargin)
%ETCHERCALCULATORGUI MATLAB code file for EtcherCalculatorGUI.fig
%      ETCHERCALCULATORGUI, by itself, creates a new ETCHERCALCULATORGUI or raises the existing
%      singleton*.
%
%      H = ETCHERCALCULATORGUI returns the handle to a new ETCHERCALCULATORGUI or the handle to
%      the existing singleton*.
%
%      ETCHERCALCULATORGUI('Property','Value',...) creates a new ETCHERCALCULATORGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to EtcherCalculatorGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ETCHERCALCULATORGUI('CALLBACK') and ETCHERCALCULATORGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ETCHERCALCULATORGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EtcherCalculatorGUI

% Last Modified by GUIDE v2.5 08-Mar-2020 17:52:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EtcherCalculatorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @EtcherCalculatorGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before EtcherCalculatorGUI is made visible.
function EtcherCalculatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for EtcherCalculatorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EtcherCalculatorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Move to center of the screen
movegui( hObject, 'center' );


% --- Outputs from this function are returned to the command line.
function varargout = EtcherCalculatorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Calculate.
function Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    uc = eval( handles.uc.String ); % um
    L = eval( handles.L.String ); % mm
    W = eval( handles.W.String ); % mm
    A = eval( handles.A.String ); % mm^2
    P = eval( handles.P.String ); % mm
    [totalVol,boundaryVol,bareVol,ucVol] = ...
        etchVolume('size',[L W],'bareArea',A,'etchPerimeter',P,'uc',uc);
    handles.totVol.String = num2str(totalVol);
    %---------- Begin Update Output Message ----------%
    outputMessage = "";
    outputMessage = strcat(outputMessage,sprintf("Boundary Si Volume:\t %.4f mm^3\n",boundaryVol));
    outputMessage = strcat(outputMessage,sprintf("Exposed Si Volume:\t %.4f mm^3\n",bareVol));
    outputMessage = strcat(outputMessage,sprintf("Undercut Si Volume:\t %.4f mm^3\n",ucVol));
    outputMessage = strcat(outputMessage,sprintf("Total Si Volume:\t %.4f mm^3\n",totalVol));
    outputMessage = strcat(outputMessage,sprintf("--------------------------------------\n"));
    handles.OutputText.String = outputMessage;
    %---------- Update Output Message finished ----------%
    
    fileDir = handles.FileDir.String;
    if handles.OldEtcher.Value
        fileName = strcat(fileDir,"\","OldEtchRate.mat");
        if isfile(fileName)
            load(fileName,'OldEtchRate','EtchDate');
        else
            EtchDate = {string(datestr(now,2))};
            inputRate = inputdlg({sprintf("Specified file: \n %s don't exist.\n Please input volume(mm^3) per cycle",fileName)},"Input Etch Rate");
            if isempty(inputRate)
                errordlg('Calculate Cancelled','Cancelled');
                return
            else
                try
                    OldEtchRate = [eval(inputRate{1}) 1];
                catch
                    errordlg('Invalid Input','Invalid');
                    return
                end
            end
        end
        [avgEtchRate, usedEtchRate, usedEtchDate] = getEtchRate(OldEtchRate,EtchDate);
    else
        fileName = strcat(fileDir,"\","NewEtchRate.mat");
        if isfile(fileName)
            load(fileName,'NewEtchRate','EtchDate');
        else
            EtchDate = {string(datestr(now,2))};
            inputRate = inputdlg({sprintf("Specified file: \n %s don't exist.\n Please input volume(mm^3) per cycle",fileName)},"Input Etch Rate");
            if isempty(inputRate)
                errordlg('Calculate Cancelled','Cancelled');
                return
            else
                try
                    NewEtchRate = [eval(inputRate{1}) 1];
                catch
                    errordlg('Invalid Input','Invalid');
                    return
                end
            end
        end
        [avgEtchRate, usedEtchRate, usedEtchDate] = getEtchRate(NewEtchRate,EtchDate);
    end
    NC = totalVol/avgEtchRate;
    handles.NC.String = num2str(NC);
    
    %---------- Begin Update Output Message ----------%
    outputMessage = "";
    outputMessage = strcat(outputMessage,sprintf("Boundary Si Volume:\t %.4f mm^3\n",boundaryVol));
    outputMessage = strcat(outputMessage,sprintf("Exposed Si Volume:\t %.4f mm^3\n",bareVol));
    outputMessage = strcat(outputMessage,sprintf("Undercut Si Volume:\t %.4f mm^3\n",ucVol));
    outputMessage = strcat(outputMessage,sprintf("Total Si Volume:\t %.4f mm^3\n",totalVol));
    outputMessage = strcat(outputMessage,sprintf("--------------------------------------\n"));
    
    outputMessage = strcat(outputMessage,sprintf("Calibration Standards:\n"));
    % outputMessage = strcat(outputMessage,sprintf("Volume/mm^3 \t Num Cycle \t Date \n"));
    % outputMessage = strcat(outputMessage,sprintf("7.286 mm^3 \t 45 Cycles \t 0.1619 \t 20-03-07 \n"));
    for ii = 1:size(usedEtchRate,1)
        outputMessage = strcat(outputMessage,sprintf("No.%.0f: \t %.3f mm^3 \t %.0f Cycles \t %.4f \t %s\n",...
            ii, usedEtchRate(ii,1),usedEtchRate(ii,2),usedEtchRate(ii,1)/usedEtchRate(ii,2),...
            usedEtchDate{ii} ));
    end
    outputMessage = strcat(outputMessage,sprintf("--------------------------------------\n"));
    
    outputMessage = strcat(outputMessage,sprintf("Chip Size:\t %.2f mm * %.2f mm \n",L,W));
    outputMessage = strcat(outputMessage,sprintf("Exposed Si Area:\t %.4f mm^2 \n",A));
    outputMessage = strcat(outputMessage,sprintf("Desired UnderCut:\t %.2f um \n",uc));
    outputMessage = strcat(outputMessage,sprintf("--------------------------------------\n"));
    if handles.OldEtcher.Value
        outputMessage = strcat(outputMessage,sprintf("Using Old Etcher\n"));
    elseif handles.NewEtcher.Value
        outputMessage = strcat(outputMessage,sprintf("Using New Etcher\n"));
    else
        outputMessage = strcat(outputMessage,sprintf("Error: Etcher NOT selected??\n"));
    end
    outputMessage = strcat(outputMessage,sprintf("Calculated Num of Cycle:\t %.2f \n",NC));
    handles.OutputText.String = outputMessage;


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if eval(handles.totVol.String) == 0
        uc = eval( handles.uc.String ); % um
        L = eval( handles.L.String ); % mm
        W = eval( handles.W.String ); % mm
        A = eval( handles.A.String ); % mm^2
        P = eval( handles.P.String ); % mm
        [totalVol,~,~,~] = ...
            etchVolume('size',[L W],'bareArea',A,'etchPerimeter',P,'uc',uc);
    else
        totalVol = eval(handles.totVol.String);
    end
    numOfCycle = eval(handles.NC.String);
    
    fileDir = handles.FileDir.String;
    if handles.OldEtcher.Value
        fileName = strcat(fileDir,"\","OldEtchRate.mat");
        if isfile(fileName)
            load(fileName,'OldEtchRate','EtchDate');
        else
            OldEtchRate = [];
            EtchDate = {};
        end
        [avgEtchRate, ~,~] = getEtchRate(OldEtchRate,EtchDate);
        warnText = sprintf("Previous rate: %.2f,\n This rate: %.2f.\n Are you sure to ADD to OLD ETCHER? \n totVol: %.2f, NC: %.2f",...
            avgEtchRate,totalVol/numOfCycle,totalVol,numOfCycle);
        button=questdlg(warnText,'Save Confirm','Yes','Cancel','Cancel');
        if strcmp(button,'Yes')
            OldEtchRate(end+1,:) = [totalVol numOfCycle];
            EtchDate{end+1} = string(datestr(now,2));
            save(fileName,'OldEtchRate','EtchDate');
        end
    else
        fileName = strcat(fileDir,"\","NewEtchRate.mat");
        if isfile(fileName)
            load(fileName,'NewEtchRate','EtchDate');
        else
            NewEtchRate = [];
            EtchDate = {};
        end
        [avgEtchRate, ~,~] = getEtchRate(NewEtchRate,EtchDate);
        warnText = sprintf("Previous rate: %.2f,\n This rate: %.2f.\n Are you sure to ADD to NEW ETCHER? \n totVol: %.2f, NC: %.2f",...
            avgEtchRate,totalVol/numOfCycle,totalVol,numOfCycle);
        button=questdlg(warnText,'Save Confirm','Yes','Cancel','Cancel');
        if strcmp(button,'Yes')
            NewEtchRate(end+1,:) = [totalVol numOfCycle string(datestr(now,2))];
            EtchDate{end+1} = string(datestr(now,2));
            save(fileName,'NewEtchRate','EtchDate');
        end
    end


function uc_Callback(hObject, eventdata, handles)
% hObject    handle to uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uc as text
%        str2double(get(hObject,'String')) returns contents of uc as a double


% --- Executes during object creation, after setting all properties.
function uc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L_Callback(hObject, eventdata, handles)
% hObject    handle to L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L as text
%        str2double(get(hObject,'String')) returns contents of L as a double


% --- Executes during object creation, after setting all properties.
function L_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function W_Callback(hObject, eventdata, handles)
% hObject    handle to W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of W as text
%        str2double(get(hObject,'String')) returns contents of W as a double


% --- Executes during object creation, after setting all properties.
function W_CreateFcn(hObject, eventdata, handles)
% hObject    handle to W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function A_Callback(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A as text
%        str2double(get(hObject,'String')) returns contents of A as a double


% --- Executes during object creation, after setting all properties.
function A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P_Callback(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P as text
%        str2double(get(hObject,'String')) returns contents of P as a double


% --- Executes during object creation, after setting all properties.
function P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NC_Callback(hObject, eventdata, handles)
% hObject    handle to NC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NC as text
%        str2double(get(hObject,'String')) returns contents of NC as a double


% --- Executes during object creation, after setting all properties.
function NC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalculateCycle.
function CalculateCycle_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CalculateCycle
    handles.Save.Visible = 'Off';
    handles.Calculate.Visible = 'On';
    handles.totVol.Visible = 'Off';
    handles.text_totVol.Visible = 'Off';
    handles.text_totVol_unit.Visible = 'Off';
    handles.uc.Visible = "On";
    handles.text_uc.Visible = "On";
    handles.text_uc_unit.Visible = "On";
    handles.L.Visible = "On";
    handles.text_L.Visible = "On";
    handles.text_L_unit.Visible = "On";
    handles.W.Visible = "On";
    handles.text_W.Visible = "On";
    handles.text_W_unit.Visible = "On";
    handles.A.Visible = "On";
    handles.text_A.Visible = "On";
    handles.text_A_unit.Visible = "On";
    handles.P.Visible = "On";
    handles.text_P.Visible = "On";
    handles.text_P_unit.Visible = "On";
    
% --- Executes on button press in AddCalibration.
function AddCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to AddCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AddCalibration
    handles.Save.Visible = 'On';
    handles.Calculate.Visible = 'Off';
    handles.totVol.Visible = 'On';
    handles.text_totVol.Visible = 'On';
    handles.text_totVol_unit.Visible = 'On';
    handles.uc.Visible = "Off";
    handles.text_uc.Visible = "Off";
    handles.text_uc_unit.Visible = "Off";
    handles.L.Visible = "Off";
    handles.text_L.Visible = "Off";
    handles.text_L_unit.Visible = "Off";
    handles.W.Visible = "Off";
    handles.text_W.Visible = "Off";
    handles.text_W_unit.Visible = "Off";
    handles.A.Visible = "Off";
    handles.text_A.Visible = "Off";
    handles.text_A_unit.Visible = "Off";
    handles.P.Visible = "Off";
    handles.text_P.Visible = "Off";
    handles.text_P_unit.Visible = "Off";

function totVol_Callback(hObject, eventdata, handles)
% hObject    handle to totVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totVol as text
%        str2double(get(hObject,'String')) returns contents of totVol as a double


% --- Executes during object creation, after setting all properties.
function totVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileDir_Callback(hObject, eventdata, handles)
% hObject    handle to FileDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileDir as text
%        str2double(get(hObject,'String')) returns contents of FileDir as a double


% --- Executes during object creation, after setting all properties.
function FileDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    currPath = fileparts(mfilename('fullpath'));% get current path 
    set(hObject,'String',currPath);

function [avgEtchRate, usedEtchRate, usedEtchRateDate] = getEtchRate(etchRateList,etchRateDate)
    if isempty(etchRateList)
        usedEtchRate = [];
        usedEtchRateDate = [];
        avgEtchRate = "NAN";
        return
    end
    usedEtchRate = etchRateList(1+end-min(size(etchRateList,1),5):end,:);
    usedEtchRateDate = {etchRateDate{1+end-min(size(etchRateList,1),5):end}};
    avgEtchRate = mean(usedEtchRate(:,1)./usedEtchRate(:,2));
    
function [totalVol,boundaryVol,bareVol,ucVol] = etchVolume(varargin)
    % all length except for undercut is in unit of mm!
    
    ip = inputParser;
    ip.addParameter('size', [0 0], @isnumeric); 
    % width and length of the chip, in unit of mm, boundary length times pi*uc^2/4 later.
    
    ip.addParameter('bareArea', 0, @isnumeric); 
    % area of exposed Si, in unit of mm^2, times uc later
    
    ip.addParameter('etchPerimeter', 0, @isnumeric); 
    % perimeter of undercut boundarys, in unit of mm, times pi*uc^2/4 later!
    % adjacent two boundaries should be counted twice here.
    
    ip.addParameter('uc', 0, @isnumeric); 
    % undercut, in unit of um!
    
    ip.parse(varargin{:});
    size          = ip.Results.size;
    bareArea      = ip.Results.bareArea;
    etchPerimeter = ip.Results.etchPerimeter;
    uc            = ip.Results.uc * 1e-3; % transfer to mm, do all calculations in mm.
    
    
    boundaryVol = ( sum(size)*2 ) * pi*uc^2/4;
    bareVol = bareArea * uc;
    ucVol = etchPerimeter * pi*uc^2/4;
    totalVol = boundaryVol + bareVol + ucVol;
