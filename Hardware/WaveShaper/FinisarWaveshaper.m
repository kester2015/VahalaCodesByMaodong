classdef FinisarWaveshaper < handle
    properties(Constant)
        c_const = 299792458
    end
    
    properties (Access = public)
        WS_nickname
        
        atten % function handle of attenuation list
        phase % function handle of phase shift list
        atten_units % is 'THz' by default
        phase_units % is 'THz' by default
    end
    
    properties (Access = public)  % Should be private later
        device
    end
    
    properties (Dependent = true)
        num_pixel % 5025 or 9000, depending on the model of the Waveshaper.
        freq_list % is linspace(startF, stopF, num_pixel)
        
        atten_variable_list % variable list that will be past to atten function handle, dependent on units
        phase_variable_list % variable list that will be past to phase function handle, dependent on units
        % ---------- %
        % Three parameters will send to WriteFinisar function
        % The list always corresponds to frequency list, which is determined by the structure of WriteFinisar3 function.
        atten_list
        phase_list
        port_list
    end
    
    properties (Access = public) % Should be private later
        % ---------- %
        current_atten_list % list keep track of current attenuation list
        current_phase_list % list keep track of current phase shift list
    end
    
    %% Basic encapsulation of the previous Open, Close and Write functions
    methods (Access = public)
        function obj = FinisarWaveshaper(WS)
            % WS should be string choosing from 'WS0', 'WS1', 'WS2', 'WS3'.
            % Configuring the waveshaper model you are connecting to.
            % WS0 = 'SN93_4000S.wsconfig';       %Test config file from Finisar
            % WS1 = 'SN200157.wsconfig';         %4000s C+L Blue
            % WS2 = 'SN082721.wsconfig';         %1000s C
            % WS3 = 'WS079973.wsconfig';         %1000s/sp - 1x1 Single Polarization
            
            % WS4 = 'SN082721.wsconfig';
            if nargin == 0
                WS = 'WS2';
            end
            obj.WS_nickname = WS;
            
            obj.atten = @(x)0;
            obj.phase = @(x)0;
            obj.atten_units = 'THZ';
            obj.phase_units = 'THZ';
        end
        
        function connect(obj)
            if ~obj.isconnected
                fprintf('Waveshaper %s is connecting...... \n',obj.WS_nickname)
                obj.device = obj.OpenFinisar3(obj.WS_nickname);
                fprintf('Waveshaper %s configuration is finished.\n',obj.device.Name)
            else
                fprintf('Waveshaper %s is already connected.\n',obj.device.Name)
            end
            obj.current_atten_list = zeros(size(obj.freq_list));
            obj.current_phase_list = zeros(size(obj.freq_list));
        end
        
        function disconnect(obj)
            obj.CloseFinisar3(obj.device, 1);
        end
        
        function flag = isconnected(obj)
            if isempty(obj.device)
                flag = 0;
            elseif ~isfield(obj.device,'StopF')
                flag = 0;
                warning('Device StopF and StartF not configured. Not properly opened yet.');
            elseif ~(libisloaded('wslib'))
                flag = 0;
                warning('library already unloaded. Should be reloaded.');
            else
                flag = 1;
            end
        end
        
        function status = write2WS(obj)
            if ~obj.isconnected
                error('write2WS: Trying to call WriteFinisar3 before device is connected.')
            end
            status = obj.WriteFinisar3(obj.device, obj.atten_list, obj.phase_list, obj.port_list);
            
            if status == 0 % if the write is successful
                obj.current_atten_list = obj.atten_list;
                obj.current_phase_list = obj.phase_list;
            end
        end
        
        function plot_status(obj, units)
            if nargin == 1
                units = 'THz';
            end
            if ~any(strcmpi(obj.phase_units,{'thz','hz','nm'}))==1
                error('specified plot unit %s not recognized.\n Should choose from THZ|HZ|NM',units)
            end
            
            switch upper(units)
                case 'THZ'
                    plot_x_list = obj.freq_list;
                case 'HZ'
                    plot_x_list = obj.freq_list * 1e12;
                case 'NM'
                    plot_x_list = (obj.c_const./obj.freq_list) / 1e3;
            end
            
            warning('off','MaoDongWarning:ArbitaryFreq_list')
            
            if isempty(obj.current_atten_list)
                warning('None attenuation array has been successfully sent to waveshaper. Preview showing as zero.')
                plot_y2_list = zeros(size(plot_x_list));
            else
                plot_y2_list = obj.current_atten_list;
            end
            if isempty(obj.current_phase_list)
                warning('None phase array has been successfully sent to waveshaper. Preview showing as zero.')
                plot_y4_list = zeros(size(plot_x_list));
            else
                plot_y4_list = ( obj.current_phase_list ); % can unwrap if necessary
            end
            plot_y1_list = obj.atten_list;
            plot_y3_list = ( obj.phase_list ) ; % can unwrap if necessary
            
            % --- Plot begins here --- %
            warning('on','MaoDongWarning:ArbitaryFreq_list')
            
            ylim_scale = 0.05;
            hh = figure('Units','normalized','Position',[0.3 0.3 0.5 0.5]);
            subplot(221)
            plot(plot_x_list, -plot_y1_list)
            title('Preview')
            ylabel('-Attn (dB)')
            if ~range(plot_y1_list)==0
                ylim([min(-plot_y1_list)-ylim_scale*range(plot_y1_list), max(-plot_y1_list)+ylim_scale*range(plot_y1_list)])
            end
            subplot(223)
            plot(plot_x_list, plot_y3_list)
            ylabel('Phase (Rad)')
            xlabel(strcat('(',units,')'))
            if ~range(plot_y3_list)==0
                ylim([min(plot_y3_list)-ylim_scale*range(plot_y3_list), max(plot_y3_list)+ylim_scale*range(plot_y3_list)])
            end
            
            subplot(222)
            plot(plot_x_list, -plot_y2_list)
            title('Current')
            ylabel('-Attn (dB)')
            if ~range(plot_y2_list)==0
                ylim([min(-plot_y2_list)-ylim_scale*range(plot_y2_list), max(-plot_y2_list)+ylim_scale*range(plot_y2_list)])
            end
            subplot(224)
            plot(plot_x_list, plot_y4_list)
            ylabel('Phase (Rad)')
            xlabel(strcat('(',units,')'))
            if ~range(plot_y4_list)==0
                ylim([min(plot_y4_list)-ylim_scale*range(plot_y4_list), max(plot_y4_list)+ylim_scale*range(plot_y4_list)])
            end
        end
    end
    
    %% Get methods of dependent properties
    methods 
        function pp = get.num_pixel(obj)
            if obj.isconnected
                pp = ceil( (obj.device.StopF - obj.device.StartF).*1000 );
            else
                pp = 0;
                warning('get.num_pixels: Device not connected yet.');
            end
        end
        
        function ll = get.freq_list(obj)
            if ~obj.isconnected
                ll = linspace(190,195,1000)';
                warning('MaoDongWarning:ArbitaryFreq_list','freqency list is assigned before device is connected.')
                return
            end
            ll = linspace(obj.device.StartF, obj.device.StopF, obj.num_pixel)';
        end
        
        function ll = get.atten_variable_list(obj)
            if ~any(strcmpi(obj.atten_units,{'thz','hz','nm'}))==1
                error('specified atten_units %s not recognized.\n Should choose from THZ|HZ|NM',obj.atten_units)
            end
            switch upper(obj.atten_units)
                case 'THZ' 
                    ll = obj.freq_list; % obj.freq_list is in THz
                case 'HZ'
                    ll = obj.freq_list * 1e12; % transfer THz to Hz
                case 'NM'
                    ll = (obj.c_const./obj.freq_list) / 1e3;
            end
        end
        
        function ll = get.phase_variable_list(obj)
            if ~any(strcmpi(obj.phase_units,{'thz','hz','nm'}))==1
                error('specified phase_units %s not recognized.\n Should choose from THZ|HZ|NM',obj.phase_units)
            end
            switch upper(obj.phase_units)
                case 'THZ'
                    ll = obj.freq_list; % obj.freq_list is in THz
                case 'HZ'
                    ll = obj.freq_list * 1e12; % transfer THz to Hz
                case 'NM'
                    ll = (obj.c_const./obj.freq_list) / 1e3;
            end
        end
        
        function ll = get.atten_list(obj)
            if ~isa(obj.atten, 'function_handle')
                error('specified atten is not a function handle')
            end
            ll = arrayfun(obj.atten, obj.atten_variable_list);
        end
        
        function ll = get.phase_list(obj)
            if ~isa(obj.phase, 'function_handle')
                error('specified phase is not a function handle')
            end
            ll = arrayfun(obj.phase, obj.phase_variable_list);
        end 
        
        function ll = get.port_list(obj)
            ll = ones(size(obj.freq_list));
        end
    end
    %% Some useful functions. You may add customized functions later.
    methods (Access = public) % phase related
        function fiberDispersion(obj,FiberL)
            % FiberL = 40;   %BOC 39 % The fiber length to be compensated, in m
            beta2 = -21.54e-24 /1e3  * FiberL * (1e12)^2;
            beta3 = 0.166e-36 /1e3 * FiberL * (1e12)^3; % previous was 0.166e-36 /1e3 * -20, I believe is wrong
            
            obj.phase_units = 'THz';
            freq_mid = median(obj.freq_list);
            phase_array = @(freq_ws) (beta2*((freq_ws-freq_mid)*2*pi).^2/2 + beta3*((freq_ws-freq_mid)*2*pi).^3/6);
            % phase_array = (beta2*((freq_ws-freq_mid)*2*pi).^2/2 + beta3*((freq_ws-freq_mid)*2*pi).^3/6);
            obj.phase = @(x)rem(phase_array(x)+abs(floor(min(phase_array(x))/2/pi))*2*pi,2*pi);
            % phase_array = rem(phase_array+abs(floor(min(phase_array)/2/pi))*2*pi,2*pi);
            
            fprintf('%.2f meters fiber dispersion compensation Up to third order. beta2 = %.4f (rad/(2pi*THz)^2), beta3 = %.4f (rad/(2pi*THz)^3)\n', FiberL,beta2,beta3);
        end
        
        function secondDispersion(obj, disp2, center, center_units)
            % disp2 in units of ps/nm
            if nargin == 3
                center_units = 'thz';
            end
            
            obj.phase_units = 'THz';
            switch upper(center_units)
                case 'THZ' % if given center is in THz
                    freq_mid = center ; % transfer to THz
                case 'NM'
                    freq_mid = obj.c_const/center * 1e-3; % frequency in Hz
                case 'HZ'
                    freq_mid = center / 1e12 ; % transfer to THz
                otherwise
                    error('secondDispersion function accepts ONLY NM|THz as center unit. units %s unrecognized.',center_units)
            end
            
            beta2 = (obj.c_const/freq_mid)^2/(2*pi*obj.c_const)*(disp2*1e-3);
            obj.phase = @(y) ( beta2*((y-freq_mid)*2*pi).^2/2 ) ;
            
            fprintf('beta2 = %.4f (rad/(2pi*THz)^2). Center %.2f %s. Second order dispersion.\n', beta2, center, center_units)
        end
    end
    methods (Access = public) % attenuation related
        function bandPass(obj, low_band, high_band, filtAtten, units)
            if nargin == 4
                units = 'THz';
            end
            obj.atten_units = units;
            obj.atten = @(x) filtAtten*(x<low_band | x>high_band);
            
            fprintf('Low edge %.1f %s. High edge %.1f %s. Band PASS filter. Outer atten %.1f dB\n',low_band, units, high_band, units, filtAtten)
        end
        
        function bandStop(obj, low_band, high_band, filtAtten, units)
            if nargin == 4
                units = 'THz';
            end
            obj.atten_units = units;
            obj.atten = @(x) filtAtten*(x>low_band & x<high_band);
            
            fprintf('Low edge %.1f %s. High edge %.1f %s. Band STOP filter. Inner atten %.1f dB\n',low_band, units, high_band, units, filtAtten)
        end
        
        function inverseAtten(obj,osa_wl,osa_pw)
            % take OSA readings directly and conpensate any wavelength dependence
            % osa_wl: wavelength from OSA. in nm
            % osa_pw: power from OSA, in dBm
            NoiseLevel = -48;%dbm
            pump = 1550;%nm
            FSR = 18;%GHz
            FSR_nm = pump-1/(1/pump+FSR/obj.c_const);
            [PKS,LOCS] = findpeaks(osa_pw, osa_wl, 'MinPeakHeight', NoiseLevel,'MinPeakDistance',FSR_nm * 0.9);
            
            figure
            hold on
            plot(osa_wl,osa_pw)
            scatter(LOCS,PKS)
            xlabel('(nm)')
            ylabel('(dbm)')
            title('Spectrum Peak search - Quality check')

            obj.atten_units = 'nm';
            obj.atten = @(x) interp1(LOCS, PKS, x);
            min_interpfun_atten = min(obj.atten_list);
            obj.atten = @(x) interp1(LOCS, PKS, x) - min_interpfun_atten;
            
            fprintf('Inverse attenuation to compensate apectrum dependence applied.\n');
        end
        
    end
    
    %% DONOT MODIFY! Some basic functions. Copied from previous control code. 
    % % This section should not be modified unless you really understand what you want to do.
    methods (Access = private)
        function status = WriteFinisar3(obj,WaveShaper,amp,phase,port)
            % Write the amp and phase, and port vectors to the Finisar Waveshaper
            %  Example call:  status = WriteFinisar3(WaveShaper,amp,phase,port)
            %        where amp, phase, and port are vectors that specify the
            %        attenuation, phase, and output port at each frequency.  WaveShaper
            %        is the WaveShaper device name (from the CreateWaveShaper
            %        function).  Returns the status = 0 if the function works.

            %D.E. Leaird, 29-Jul-10; update 4-Aug-10 to set Maximum attenuation to 60
            % Updated 13-Mar-12 to utilize expanded amplitude sensitivty available with
            % API 2.0.4; also using the check of the WS frequency range.
            % Updated 3-Sep-12, Update to specifically check which WaveShaper device the vectors
            %are being sent to; also include the port information.  Simulation mode
            %included - Note that this is not general.  Simulation is invoked when no
            %WaveShaper is connected; if a WaveShaper is connected normal communication
            %occurs.

            %Starting with API V2.0.4 it is possible to speed up the communication with
            %the WaveShaper CONSIDERABLY by only writing values that change!  Here we
            %are writing ALL values very time.  We should consider writing a different
            %script to take into account this available functionality!

            %Check to make sure the vectors amp, phase, and port are the correct dimensions,
            %and have values within the correct range.
            NumPixels = ceil((WaveShaper.StopF-WaveShaper.StartF).*1000);
            if (~ismatrix(amp))                   %This function only works on vectors.
                fprintf(1,'The Amplitude values must be a vector!\n');
                status = -104;
                return
            end
            if (min(size(amp)) ~= 1)              %Make sure VALUE is not 2x2
                fprintf(1,'The Amplitude values must be a vector!\n');
                status = -104;
                return
            end
            if (length(amp) ~= NumPixels)               %Must use the correct number of elements.
                fprintf(1,'The length of the Amplitude vector must be %i!\n', NumPixels);
                status = -105;
                return
            end
            if (max(amp) > 60)                  %Maximum attenuation exceeded.
                fprintf(1,'The maximum of the Amplitude vector is 60!\n');
                status = -102;
                return
            end
            if (min(amp) < 0)                     %Minimum attenuation limit
                fprintf(1,'The minimum of the Amplitude vector is 0!\n');
                status = -103;
                return
            end

            if (~ismatrix(phase))                   %This function only works on vectors.
                fprintf(1,'The Phase values must be a vector!\n');
                status = -104;
                return
            end
            if (min(size(phase)) ~= 1)              %Make sure VALUE is not 2x2
                fprintf(1,'The Phase values must be a vector!\n');
                status = -104;
                return
            end
            if (length(phase) ~= NumPixels)               %Must use the correct number of elements.
                fprintf(1,'The length of the Phase vector must be %i!\n', NumPixels);
                status = -105;
                return
            end
            if (max(phase) > (2*pi))                  %Maximum phase exceeded.
                fprintf(1,'The maximum of the Phase vector is 2pi!\n');
                status = -102;
                return
            end
            if (min(phase) < 0)                     %Minimum phase limit
                fprintf(1,'The minimum of the Phase vector is 0!\n');
                status = -103;
                return
            end

            if (~ismatrix(port))                   %This function only works on vectors.
                fprintf(1,'The Port values must be a vector!\n');
                status = -104;
                return
            end
            if (min(size(port)) ~= 1)              %Make sure VALUE is not 2x2
                fprintf(1,'The Port values must be a vector!\n');
                status = -104;
                return
            end
            if (length(port) ~= NumPixels)               %Must use 5026 elements.
                fprintf(1,'The length of the Port vector must be %i!\n', NumPixels);
                status = -105;
                return
            end
            if (max(port) > WaveShaper.NumPorts)                  %Maximum Port exceeded.
                fprintf(1,'The maximum number of Ports is %i!\n', WaveShaper.NumPorts);
                status = -106;
                return
            end
            if (min(port) < 1)                     %Minimum Port limit
                fprintf(1,'The minimum of the Port vector is 1!\n');
                status = -107;
                return
            end


            %Create the buffer
            % The format is freq (xxx.xxx) TAB amp (xx.xxx) TAB phase (x.xxxxxx) TAB port (x) NL
            % (24 char per line)
            buffer = [num2str(WaveShaper.StartF,'%7.3f') char(9) num2str(amp(1),'%6.3f') char(9) num2str(phase(1),'%8.6f') char(9) num2str(port(1),'%1i') char(10)];
            for k = 2:NumPixels
                buffer = [buffer num2str((WaveShaper.StartF+0.001*k-0.001),'%7.3f') char(9) num2str(amp(k),'%6.3f') char(9) num2str(phase(k),'%8.6f') char(9) num2str(port(k),'%1i') char(10)];
            end

            [errcode, ~, temp2] = calllib('wslib','ws_load_profile',WaveShaper.Name, buffer);
            if (errcode < 0)
                fprintf(1,'Error sending data to the Device...error %i\n.',errcode);
                status = errcode;
                return
            end

            if (WaveShaper.Simulation)                  %Execute the model
                [errcode, ~, ~, temp3] = calllib('wslib','ws_load_profile_for_modeling',WaveShaper.Name, buffer, 1, 0);
                if (errcode < 0)
                    fprintf(1,'Error Executing the Model...error %i\n.',errcode);
                    status = errcode;
                    return
                end
            end

            status = 0;
            return
        end
        
        function WSdevice = OpenFinisar3(obj,WS)
            % Load the Finisar Waveshaper library, create the device object, and open
            % The directory WaveManger installation path and it's sub-directories must
            % be in the Matlab path (after the driver is installed).
            % D.E. Leaird 29-Jul-10
            % 17-Oct-11 Updated for changes in the way the WaveManger API installs
            % 11-Mar-12 Updated to include simulation (no connected WaveShaper) option -
            %  requires WaveManager API 2.0.4, and set the WaveShaper to Transmit All
            %  at startup
            % 3-Sep-12 Updated to generalize the installation path / AWG config file,
            % allow for multiple AWG's, and return an AWGdevice object that will be
            % REQUIRED on Write functions...so we can tell if the write is 'real' or
            % 'simulation', as well as determine the port count of the device, and frequency
            % range, as well as the device name.
            % 17-Oct-12 Updated to include WS3 device;
            % 14-Nov-12 Updated to check the Registry path for 64 bit vs. 32-bit
            % 23-Jan-13 Updated the wsconfig filename of WS2
            % 24-Jan-13 Changed path of the .wsconfig file to the 'standard' used by
            %  Finisar, it is no longer necessary to copy these files to the install
            %  WaveManager path as was done previously
            %
            %       Example call:  device = OpenFinisar3('WS1');     % 'WS1'
            %       corresponds to the 1000s, 1x1 WaveShaper.

            WS0 = 'SN93_4000S.wsconfig';       %Test config file from Finisar
            WS1 = 'SN200157.wsconfig';         %4000s C+L Blue
            WS2 = 'SN082721.wsconfig';         %1000s C
            WS3 = 'WS079973.wsconfig';         %1000s/sp - 1x1 Single Polarization
            
            WS4 = 'SN082721.wsconfig';
            
            % Find the WaveManager install path from the registry
            try
                WaveManagerInstallPath = winqueryreg('HKEY_LOCAL_MACHINE','Microsoft\Windows\CurrentVersion\WaveManager','Path');      
            catch ME
                if (strcmp(ME.message,'Specified key is invalid.'))
                    try
                        WaveManagerInstallPath = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Wow6432Node\WaveManager','Path');
                    catch ME1
                        if (strcmp(ME1.message,'Specified key is invalid.'))
                            try
                                WaveManagerInstallPath = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Wavemanager','Path');
                            catch ME2
                                if (strcmp(ME2.message,'Specified key is invalid.'))
                                    try
                                        WaveManagerInstallPath = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Wow6432Node\WaveShaper Software','Path');
                                    catch ME3
                                        if (strcmp(ME3.message,'Specified key is invalid.'))
                                            fprintf(1,'Error in determining the registry key; terminating.\n');
                                        else
                                            fprintf(1','Error in determining the Wavemanager path from the registry (#4); terminating.\n');
                                            return
                                        end
                                    end
                                else
                                    fprintf(1','Error in determining the Wavemanager path from the registry (#3); terminating.\n');
                                    return
                                end
                            end
                        else
                            fprintf(1,'Error in determing the Wavemanager path from the Registry (#2); terminating.\n');
                            return
                        end
                    end
                else
                    fprintf(1,'Error in determing the Wavemanager Path from the Registry; terminating.\n');
                    return
                end
            end
            %  Determine the Current version of WaveManager
            try
                WaveManagerVersion = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WaveManager','DisplayVersion');
            catch ME
                if (strcmp(ME.message,'Specified key is invalid.'))
                    try
                        WaveManagerVersion = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WaveManager','DisplayVersion');
                    catch ME1
                        if (strcmp(ME1.message,'Specified key is invalid.'))
                            WaveManagerVersion = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WaveShaper Software','DisplayVersion');
                        end
                    end
                else
                    fprintf(1,'Error in determing the Wavemanager Version from the Registry; terminating.\n');
                    return
                end
            end
            %  Find %appdata% from the Registry
            try
                AppDataDirectory = winqueryreg('HKEY_CURRENT_USER','Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','AppData');
            catch ME
                if (strcmp(ME.message,'Specified key is invalid.'))
                    fprintf(1,'Error determining the AppData directory from the Registry; terminating.\n');
                    return
                end
            end

            PeriodLocation = strfind(WaveManagerVersion,'.');
            MajorVersion = eval(WaveManagerVersion(1:PeriodLocation(1)-1));
            MinorVersion = eval(WaveManagerVersion(PeriodLocation(1)+1:PeriodLocation(2)-1));
            SubVersion   = eval(WaveManagerVersion(PeriodLocation(2)+1:length(WaveManagerVersion)));
            if ~((MajorVersion > 2) || ...
                 ((MajorVersion >= 2) && (MinorVersion > 0)) || ...
                 ((MajorVersion >= 2) && (MinorVersion >= 0) && (SubVersion >= 4)))
                fprintf(1,'The WaveManager version must be 2.0.4 or higher...exiting.\n');
                warning('MaodongWarning:lowVersion','current version %s is lower than minimum required 2.0.4',WaveManagerVersion)
                % return
            end

            if (strcmp(WS,'WS0'))          %Check user configuration selection, and point to the Config FILE
                WS = WS0;
            elseif (strcmp(WS,'WS1'))
                WS = WS1;
            elseif (strcmp(WS,'WS2'))
                WS = WS2;
            elseif (strcmp(WS,'WS3'))
                WS = WS3;
            elseif (strcmp(WS,'WS4'))
                WS = WS4;    
            else
                fprintf(1,'\nIncorrect WaveShaper configuration selected; exiting.\n');
                return;
            end

            %Load the external library required for communication with the WaveShaper
            % only if the library is NOT already loaded
            if ~(libisloaded('wslib'))
                loadlibrary('wsapi','include/ws_api.h','alias','wslib');
            end

            %Create the WaveShaper device
            %  First make the unique name from the config file name (which has the
            %  serial number)
            PeriodLocation = strfind(WS,'.');
            WSname = strcat('ws',WS(1:PeriodLocation-1));
            WSdevice.Name = WSname;                        %WSdevice structure - name field

            %Create the WaveShaper
            [errcode, ~, ~] = calllib('wslib','ws_create_waveshaper',WSname,strcat(AppDataDirectory,'\WaveManager\wsconfig\',WS));
            if (errcode < 0)
                fprintf(1,'Error Creating the Device...error %i\n.',errcode);
                return
            end

            %Attempt to Open the WaveShaper device
            [errcode,~] = calllib('wslib','ws_open_waveshaper',WSname);
            WSdevice.Simulation = false;               %Simulation = False is the default
            if (errcode == -38)         %WS not Found...Delete the ws object, and re-create / open for simulation
                [errcode,~] = calllib('wslib','ws_delete_waveshaper',WSname);
                if ((errcode < 0) && (errcode ~= -38))
                    fprintf(1,'Error Deleteing the waveshaper...error %i\n.',errcode);
                    return
                end
                [errcode, ~, ~] = calllib('wslib','ws_create_waveshaper_forsimulation',WSname,strcat(AppDataDirectory,'\WaveManager\wsconfig\',WS));
                if (errcode < 0)
                    fprintf(1,'Error Creating the Device for Simulation...error %i\n.',errcode);
                    return
                end
                [errcode,~] = calllib('wslib','ws_open_waveshaper',WSname);
                if (errcode < 0)
                    fprintf(1,'Error Opening the waveshaper for simulation...error %i\n.',errcode);
                    return
                end    
                WSdevice.Simulation = true;
            elseif (errcode < 0)
                fprintf(1,'Error Opening the waveshaper...error %i\n.',errcode);
                return
            end

            %Get the port count
            [errcode, ~, NumPorts] = calllib('wslib','ws_get_portcount',WSname, 0);
            if (errcode < 0)
                fprintf(1,'Error getting the number of ports...error %i\n.',errcode);
                return
            end
            WSdevice.NumPorts = NumPorts;

            %Get the frequency range
            [errcode, ~, startf, stopf] = calllib('wslib','ws_get_frequencyrange',WSname, 0, 0);
            if (errcode < 0)
                fprintf(1,'Error getting the frequency range...error %i\n.',errcode);
                return
            end
            WSdevice.StartF = startf;
            WSdevice.StopF = stopf;

            %Load a predefined profile - transmit all, on Port 1
            [errcode,~] = calllib('wslib','ws_load_predefinedprofile',WSname,2,0,0,0,1);      %Transmit, Ignore Center, BW, Amp, Set Port =1
            if (errcode < 0)
               fprintf(1,'Error Loading Transmit All Predefined Profile...error %i\n.',errcode);
               return
            end  

            return
        end
        
        function CloseFinisar3(obj,Device,Unload)
            % Close the Finisar Waveshaper, unload the library if requested
            % D.E. Leaird, 29-Jul-10; Updated 7-Sep-12 to include a specific device
            %     Example call: CloseFinisar3(device,1)       %device came from OpenFinisar3, 1=unload library
            %                        0 = do not unload the library (may be using
            %                        another WaveShaper).

            [errcode, temp1] = calllib('wslib','ws_close_waveshaper',Device.Name);
            if (errcode < 0)
                fprintf(1,'Error Closing the Device...error %i\n.',errcode);
                return
            end
            [errcode,temp1] = calllib('wslib','ws_delete_waveshaper',Device.Name);
            if (errcode < 0)
                fprintf(1,'Error Deleteing the waveshaper...error %i\n.',errcode);
                return
            end

            if (Unload)
                unloadlibrary('wslib');
            end

            return
        end
    end
    %% Forced disconnect. Will be useful if a connected device variable is lost
    methods(Static)
        function Forced_Reset()
            % Close the Finisar Waveshaper, unload the library if requested
            % D.E. Leaird, 29-Jul-10; Updated 7-Sep-12 to include a specific device
            %     Example call: CloseFinisar3(device,1)       %device came from OpenFinisar3, 1=unload library
            %                        0 = do not unload the library (may be using
            %                        another WaveShaper).
            
            % ---- Modified by Maodong ---- 
            % close all possible Devices
            Unload = 1;
            NameList = {'wsSN200157','wsSN082721','wsWS079973','wsSN93_4000S'};
            
            if ~(libisloaded('wslib'))
                loadlibrary('wsapi','include/ws_api.h','alias','wslib');
            end
            
            for name = NameList
                [errcode, temp1] = calllib('wslib','ws_close_waveshaper',name{1});
                if (errcode < 0)
                    fprintf(1,'Error Closing the Device...error %i.\n',errcode);
                end
                [errcode,temp1] = calllib('wslib','ws_delete_waveshaper',name{1});
                if (errcode < 0)
                    fprintf(1,'Error Deleteing the waveshaper...error %i.\n',errcode);
                end
            end

            if (Unload)
                unloadlibrary('wslib');
            end

            return
        end
    end
end
