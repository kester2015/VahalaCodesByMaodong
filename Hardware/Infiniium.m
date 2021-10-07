classdef Infiniium < handle
    % Keysight Infiniium Oscilloscope
    properties
        visaObj
        Address
        Waveform
        OldVer
        trigger_ch = 'AUX'
        trigger_level = 0.5;
    end
    
    properties (Dependent = true)
        InputBufferSize
        
        % --- osc settings related --- %
        srate % sampling rate, is a number or "AUTO"
        memoDepth % Memory Depth, is a number or "AUTO"
        
        tcenter % time center
        tspan % time axis total span. tspan/10 = horizontal scale
        % time center and span are core. Other are derived.
        tscale % = tspan/10;
        tstart
        tend
    end
    
    properties (Access = private)
        setting
        NUM_DIV_HOR = 10; % number of horiztiontal division, =10
        NUM_DIV_VER = 8; % number of vertical division, =8
    end
    
    methods
        function Obj = Infiniium(addr,OldVer)
            Obj.Address = addr;
            Obj.visaObj = visa('AGILENT', Obj.Address);
            Obj.visaObj.Timeout = 100;
            Obj.visaObj.ByteOrder = 'littleEndian';
            if nargin == 2
                Obj.OldVer = OldVer;
            end
        end
        
        function delete(Obj)
            Obj.disconnect();
        end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('Infiniium Oscilloscope connected');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Infiniium Oscilloscope disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj,command)
            fprintf(Obj.visaObj,command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
        %%
        function set.InputBufferSize(Obj,size)
            fclose(Obj.visaObj);
            Obj.visaObj.InputBufferSize = size;
            fopen(Obj.visaObj);
        end
        
        function set.srate(Obj, srate)
            if strcmpi(srate, 'AUTO')
                Obj.Write(":ACQ:SRAT:ANAL AUTO");
                return
            elseif isnumeric(srate)
                tt1 = strcat(":ACQ:SRAT:ANAL ",num2str(srate/1e6),'E+6');
                Obj.Write(tt1);
            else
                error("Un-reconigized sample rate command. srate should be 'AUTO' or (a number)")
            end
        end
        
        function ss = get.srate(Obj)
            if str2double( Obj.Query(":ACQ:SRAT:AUTO?") )
                ss = "AUTO";
            else
                ss = str2double( Obj.Query(":ACQ:SRAT?") );
            end
        end
        
        function set.memoDepth(Obj, memodept)
            if strcmpi(memodept, 'AUTO')
                Obj.AutoMemoryDepth;
                return
            elseif isnumeric(memodept)
                tt1 = strcat(":ACQ:POIN:ANAL ",num2str(memodept/1e6),'E+6');
                Obj.Write(tt1);
            else
                error("Un-reconigized memory depth command. memoDepth should be 'AUTO' or (a number)")
            end
        end
        
        function tt = get.memoDepth(Obj)
            if str2double( Obj.Query(":ACQ:POIN:AUTO?") )
                tt = "AUTO";
            else
                tt = str2double( Obj.Query(":ACQ:POIN:ANAL?") );
            end
        end
        
        % --- Horizontal control ---
        function set.tcenter(Obj, center_pos) % center_pos in units of s
            tt1 = strcat(":TIM:POS ",num2str(center_pos));
            Obj.Write(tt1);
        end
        
        function tt = get.tcenter(Obj)
            tt = str2double( Obj.Query(":TIM:POS?") );
        end
        
        function set.tspan(Obj, span) % span in unit of s
            tt2 = strcat(":TIM:RANG ",num2str(span));
            Obj.Write(tt2);
        end
        
        function tt = get.tspan(Obj)
            tt = str2double( Obj.Query(":TIM:RANG?") );
        end
        
        function set.tscale(Obj, scale)
            Obj.tspan = Obj.NUM_DIV_HOR * scale;
        end
        
        function tt = get.tscale(Obj)
            tt = Obj.tspan / Obj.NUM_DIV_HOR;
        end
        
        function set.tstart(Obj, tstart)
            % oldtstart = Obj.tcenter - Obj.tspan/2;
            oldtend = Obj.tcenter + Obj.tspan/2;
            newstart = tstart;
            if ~(newstart < oldtend)
                newend = newstart + 10e-3; % if move too far, 10ms span default
            else
                newend = oldtend;
            end
            newspan = (newend - newstart); 
            newcenter = (newend + newstart)/2;
            Obj.tcenter = newcenter;
            Obj.tspan = newspan;
        end
        function tt = get.tstart(Obj)
            tt = Obj.tcenter - Obj.tspan/2;
        end
        
        function set.tend(Obj, tend)
            oldtstart = Obj.tcenter - Obj.tspan/2;
            % oldtend = Obj.tcenter + Obj.tspan/2;
            newend = tend;
            if ~(newend > oldtstart)
                newstart = newend - 10e-3; % if move too far, 10ms span default
            else
                newstart = oldtstart;
            end
            newspan = (newend - newstart); 
            newcenter = (newend + newstart)/2;
            Obj.tcenter = newcenter;
            Obj.tspan = newspan;
        end
        function tt = get.tend(Obj)
            tt = Obj.tcenter + (Obj.NUM_DIV_HOR/2) *Obj.tspan;
        end
        %%
       function wait(Obj)
            operationComplete = str2double(Obj.Query('*OPC?'));
            while isnan(operationComplete) % this may happen when last save action are still not finished
                warning("Infinium OSC wait operation failed, retry in 5 seconds.");
                pause(5)
                operationComplete = str2double(Obj.Query('*OPC?'));
            end
            while ~operationComplete
                operationComplete = str2double(Obj.Query('*OPC?'));
            end
        end
        
        function checkerror(Obj)
            instrumentError = Obj.Query(':SYSTEM:ERR? STR');
            while ~isequal(instrumentError,['0,"No error"' char(10)])
                disp(['Instrument Error: ' instrumentError]);
                instrumentError = Obj.Query(':SYSTEM:ERR? STR');
            end
        end
        
        %%
        function Stop(Obj)
            Obj.Write(':STOP');
            Obj.wait;
        end
        
        function Run(Obj)
            Obj.Write(':CHAN1:DISP ON');
            Obj.Write(':CHAN2:DISP ON');
            Obj.Write(':CHAN3:DISP ON');
            Obj.wait;
            Obj.Write(':RUN');
        end
        
        function Single(Obj)
            Obj.Write(':SING');
            Obj.wait;
        end
        
        function status = ischannelOn(Obj,channel)
            tt = strcat(":CHAN", num2str(channel), ":DISP?");
            status = str2double( Obj.Query( tt ) );
        end
        function ChannelOn(Obj,channel)
            if ~Obj.ischannelOn(channel)
                tt = strcat(":CHAN", num2str(channel), ":DISP ON");
                Obj.Write(tt);
            end
            fprintf("Infinium oscilloscope Channel %1f display ON\n",channel)
        end
        function ChannelOff(Obj,channel)
            if Obj.ischannelOn(channel)
                tt = strcat(":CHAN", num2str(channel), ":DISP OFF");
                Obj.Write(tt);
            end
            fprintf("Infinium oscilloscope Channel %1.f display OFF\n",channel)
        end
        
        %%
        
        function waveform = read(Obj,channel,point)
            % Reading
            chan=['CHAN',num2str(channel)];
            if nargin == 3
                if ~isempty(point)
                    Obj.InputBufferSize = point*2.1*1 ;
                    Obj.wait;
                else
                    Obj.InputBufferSize = 4e5*2.1*10 ; 
                end
            elseif nargin == 2
                point = Obj.srate * Obj.tspan * 1.05;
                waveform = Obj.read(channel,point);
            end
            
            % Specify data from Channel n
            Obj.Write([':WAVEFORM:SOURCE ',chan]);
            % Set timebase to main
            Obj.Write(':TIMEBASE:VIEW MAIN');
            % Set up acquisition type and count.
            if Obj.OldVer
                Obj.Write(':ACQ:MODE RTIM');
            else
                Obj.Write(':ACQ:MODE HRES');
            end
            if ~isempty(point)
                % Specify 5000 points at a time by :WAV:DATA?
                Obj.Write([':ACQ:POIN ',num2str(point)]);
            end
            % Wait till complete
            Obj.wait;
            % Make sure Channel 1 is still on
            Obj.Write([':',chan,':DISP ON']);
            % Turn off interpolation to limit number of points to 5000
            Obj.Write(':ACQ:INT OFF');
            % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
            Obj.Write(':WAVEFORM:FORMAT WORD');
            % Set the byte order on the instrument as well
            Obj.Write(':WAVEFORM:BYTEORDER LSBFirst');
            % Get the preamble block
            preambleBlock = Obj.Query(':WAVEFORM:PREAMBLE?');
            
            Obj.Write(':WAVEFORM:VIEW MAIN');
            % Now send commmand to read data
            Obj.Write(':WAV:DATA?');
            % read back the BINBLOCK with the data in specified format and store it in
            % the waveform structure. FREAD removes the extra terminator in the buffer
            if Obj.OldVer
                fprintf('Reading Channel%d...\n',channel);
            end
            waveform.RawData = binblockread(Obj.visaObj,'int16'); fread(Obj.visaObj,1);
            Obj.Write(':ACQ:INT ON');
            Obj.checkerror;
            
            % Data processing: Post process the data retreived from the scope
            % Extract the X, Y data and plot it
            
            % Maximum value storable in a INT16
            maxVal = 2^16;
            
            %  split the preambleBlock into individual pieces of info
            preambleBlock = regexp(preambleBlock,',','split');
            
            % store all this information into a waveform structure for later use
            waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
            waveform.Type = str2double(preambleBlock{2});
            waveform.Points = str2double(preambleBlock{3});
            waveform.Count = str2double(preambleBlock{4});      % This is always 1
            waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
            waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
            waveform.XReference = str2double(preambleBlock{7});
            waveform.YIncrement = str2double(preambleBlock{8}); % V
            waveform.YOrigin = str2double(preambleBlock{9});
            waveform.YReference = str2double(preambleBlock{10});
            waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
            waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
            waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
            waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds
            
            % Generate X & Y Data
            waveform.XData = (waveform.XIncrement*(1:length(waveform.RawData))).' - waveform.XIncrement;
            waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin;
            Obj.Waveform = waveform;
        end
        
        function [XData,YData] = readtrace(Obj,channel,point)
            % return X and Y data instead of Waveform struct
            if nargin == 3
                waveform = Obj.read(channel,point);
            elseif nargin == 2
                % point automatically calculated in read function.
                waveform = Obj.read(channel); 
            else
                error("Not enough input arguments. readtrace method Need at least specify channel to read.\n %s"...
                    , "Use readall instead to read all traces out.")
            end
            XData = waveform.XData;
            YData = waveform.YData;
        end
        
        function oscTraces = readall(Obj,point)
            if nargin == 1
                point = Obj.srate * Obj.tspan * 1.05;
            end
            oscTraces.Ch1 = Obj.read(1,point);
            oscTraces.Ch2 = Obj.read(2,point);
            oscTraces.Ch3 = Obj.read(3,point);
            oscTraces.Ch4 = Obj.read(4,point);
        end
        
        function saveall(Obj, filename)
            oscTraces = Obj.readall;
            save(filename, oscTraces);
        end
        
        function [XData,YreturnData] = readmultipletrace(Obj,channel,point)
            % deprecated method. Avoid using this.
            n=length(channel);
            for i=n:-1:1
                Obj.read(channel(i),point);
                XData{i} = Obj.Waveform.XData;
                YData{i} = Obj.Waveform.YData;
                nlength(i)=length(XData{i});
            end
            [nminlength,nmin]=min(nlength);
            XData=XData{nmin};
            for i=n:-1:1
                YreturnData(:,i)=YData{i}(1:nminlength);
            end
        end
        
        function readmultipletrace_save(Obj,filename)
            % deprecated method. Avoid using this.
            filename = char(filename);
            if length(filename)>4 && strcmpi(filename(end-3:end),'.mat')
                filename = filename(1:end-4);
            end
            dir = fileparts(filename);
            if ~isfolder(dir)
                mkdir(dir)
            end
            
            Obj.Stop;
            [X,Y] = Obj.readmultipletrace(1:4,[]);
            figure;
            for ii = 1:4
                chanstr=['Channel ',num2str(ii)];
                plot(X,Y(:,ii),'DisplayName',chanstr);
                legend('-DynamicLegend');
                hold on
            end
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
    %             if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
    %             end
            end
            save([filename '.mat'],'X','Y');
            Obj.Run;
            Obj.HighRes();
        end
        
        function write2osc(Obj,filename)
            Obj.Write(strcat(':DISK:SAVE:WAVeform ALL,"',filename,'",BIN'));
        end
        
        %%
        function Qsetting(Obj)
            if (Obj.setting == 1)
                return
            end
            
            % Trigger
            Obj.Write(':TRIG:SWE TRIG');
            Obj.Write(':TRIG:EDGE:SLOP POS');
            Obj.Write([':TRIG:EDGE:SOUR ' Obj.trigger_ch]);
            Obj.Write([':TRIG:LEV ' Obj.trigger_ch ',',num2str(Obj.trigger_level)]);
            
            % Time base
            Obj.Write(':TIM:POS 0.075');
            
            % Acquire
            if Obj.OldVer
                Obj.Write(':ACQ:MODE RTIM');
            else
                Obj.Write(':ACQ:MODE HRES');
            end
            
            Obj.wait;
            Obj.setting = 1;
        end
        
        function dispersionsetting(Obj)
            if (Obj.setting == 2)
                return
            end
            Obj.Write(':TRIG:SWE AUTO');
            
            % Time base
            Obj.Write(':TIM:POS 0');
            
            Obj.wait;
            Obj.setting = 2;
        end
        
        function ringdownsetting(Obj)
            if (Obj.setting == 3)
                return
            end
            
            % Trigger
            Obj.Write(':TRIG:SWE TRIG');
            Obj.Write(':TRIG:EDGE:SLOP POS');
            Obj.Write([':TRIG:EDGE:SOUR ' Obj.trigger_ch]);
            Obj.Write([':TRIG:LEV ' Obj.trigger_ch ',0']);
            
            % Time base
            Obj.Write(':TIM:POS 0');
            
            Obj.wait;
            Obj.setting = 3;
        end
        
        
        %%
        function SetScale(Obj, Scale, Point, Srate)
            Obj.Write([':TIM:SCAL ', Scale]); % time_Scale
            Obj.Write([':ACQ:SRAT ', Srate]); % Sampling rate
          %  if (Obj.OldVer == 1) && strcmp(Point,'AUTO') && (Obj.setting == 2) % For old infiniium, Single will change # of points at AUTO mode
          %      point = str2double(Scale) * str2double(Srate) * 10;
          %      Obj.Write([':ACQ:POIN ', num2str(point)]);
          %  else
                Obj.Write([':ACQ:POIN ', Point]);  % # of points
          %  end
        end
        
        function SetTime_StartEnd(Obj,start_pos,end_pos)
            center_pos = (start_pos + end_pos)/2;
            span = end_pos - start_pos;
            Obj.SetTime_CenterSpan(center_pos,span);
        end
        
        function SetTime_CenterSpan(Obj,center_pos,span)
            tt1 = strcat(":TIM:POS ",num2str(center_pos));
            tt2 = strcat(":TIM:RANG ",num2str(span));
            Obj.Write(tt1);
            Obj.Write(tt2);
        end
        
        function HighRes(Obj)
            Obj.Write(':ACQ:MODE HRES');
        end
        
        
        function makeDirOnOSC(Obj,fullpath)
            tt = strcat(":DISK:MDIR ","""", fullpath, """");
            Obj.Write(tt);
        end
        
        function SetVertScale(Obj, Chan, scale)
            % Chan is int from 1-4, specify channel
            % scale is a 2-dim array, specify bottom and top voltage.
            if length(scale) ~= 2
                error('invalid input scale, length 2 array required.')
            end
            numOfVertDiv = 8; % 8 divisions on oscilloscope
            voltPerDiv = abs(diff(scale)) / numOfVertDiv;
            voltOffset = mean(scale);
            tt1 = strcat(':CHAN',num2str(Chan),":SCAL ",num2str(voltPerDiv));
            tt2 = strcat(':CHAN',num2str(Chan),":OFFS ",num2str(voltOffset));
            Obj.Write(tt1);
            Obj.Write(tt2);
        end
    end
    
    methods (Access = private)
         function AutoMemoryDepth(Obj)
            % Deprecated from public to private
            % use obj.memoDepth = 'auto' instead.
            Obj.Write(':ACQ:POIN:ANAL AUTO');
        end
    end
    %% static methods
    methods (Static = true)
        function [X,Y] = ReadFromBinary(filename,ToSave)
            if nargin < 2
                ToSave = 0;
            end
            A = fopen(filename);
            X = [];
            Y = [];
            %% Binary header
            Cookie = fread(A,2,'*char').';
            if ~strcmp(Cookie,'AG')
                return
            end
            FileVersion = fread(A,2,'*char').';
            FileSize = fread(A,1,'int32');
            ChannelNum = fread(A,1,'int32');
            for c = 1:ChannelNum
                %% Waveform Header
                HeaderSize = fread(A,1,'int32');
                WaveFormType = fread(A,1,'int32');
                NumWaveFormBuffer = fread(A,1,'int32');
                Count = fread(A,1,'int32');
                fread(A,1,'int32'); %??
                XDisplayRange = fread(A,1,'float');
                XDisplayOrigin = fread(A,1,'double');
                XIncrement = fread(A,1,'double');
                XOrigin = fread(A,1,'double');
                XUnits = fread(A,1,'int32'); % 0 Uknown; 1 Volt 2 Second 3 Const 4 Amp 5 Decibel
                YUnits = fread(A,1,'int32');
                DateTime = fread(A,32,'*char').';
                Frame = fread(A,24,'*char').';
                WaveFormLabel = fread(A,16,'*char').';
                TimeTags = fread(A,1,'double');
                SegmentIndex = fread(A,1,'int32');
                
                %% Waveform Data Header
                DataHeaderSize = fread(A,1,'int32');
                BufferType = fread(A,1,'int16');
                BytesPerPoint = fread(A,1,'int16');
                Bytes = fread(A,1,'int32');
                Points = Bytes/BytesPerPoint;
                X = XOrigin + XIncrement * (1:Points).';
                Y = [Y fread(A,Points,'float')];
            end
            fclose(A);
            if ToSave == 1
                save([filename(1:end-4) '.mat'],'Y','XIncrement','XOrigin');
            end
        end
    end
end
