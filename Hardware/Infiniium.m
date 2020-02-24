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
    end
    
    properties (Access = private)
        setting
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
        
        function set.InputBufferSize(Obj,size)
            fclose(Obj.visaObj);
            Obj.visaObj.InputBufferSize = size;
            fopen(Obj.visaObj);
        end
        
        function wait(Obj)
            operationComplete = str2double(Obj.Query('*OPC?'));
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
        
        function read(Obj,channel,point)
            % Reading
            chan=['CHAN',num2str(channel)];
            if ~isempty(point)
                Obj.InputBufferSize = point*2.1;
                Obj.wait;
            else
                Obj.InputBufferSize = 4e5*2.1;
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
            Obj.read(channel,point);
            
            
            XData = Obj.Waveform.XData;
            YData = Obj.Waveform.YData;
        end
        
        function [XData,YreturnData] = readmultipletrace(Obj,channel,point)
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
        
        function write2osc(Obj,filename)
            Obj.Write([':DISK:SAVE:WAVeform ALL,"',filename,'",BIN']);
        end
        
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
        
        function HighRes(Obj)
            Obj.Write(':ACQ:MODE HRES');
        end
        
        function AutoMemoryDepth(Obj)
            Obj.Write(':ACQ:POIN:ANAL AUTO');
        end
        
    end
    
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
