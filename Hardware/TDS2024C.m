classdef TDS2024C < handle
    properties
        visaObj;
        visaResourceString;
        InputBufferSize=1.5e7;
    end
    
    methods
        function obj = TDS2024C(visaAddress)
            if nargin > 0
                obj.visaResourceString = visaAddress;
            else
                obj.visaResourceString = 'USB0::0x0699::0x03A6::C031910::INSTR';
            end
            % obj.visaObj = visa('agilent',obj.visaResourceString);
            obj.visaObj = visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout = 30;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('TDS2024C OSCilloscope connected');
        end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('TDS2024C OSCilloscope disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj,command)
            fprintf(Obj.visaObj, command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
    end
    
    methods
        function wvfm = ReadTrace(obj, trace)
            % trace = 1|2|3|4
            obj.Write(strcat("DAT:SOU CH", num2str(trace))); % select trace
            % obj.Write('DAT:ENC RIBinary');
            % obj.Write('WFMPre:BN_Fmt RI')
            obj.Write('DAT:ENC ASCI');
            obj.Write('WFMPre:PT_Fmt Y')
            obj.Write('DAT:WID 2'); % bytes per point, nbits = 8*nbytes
            obj.Write('DAT:STAR 1');
            obj.Write('DAT:STOP 2500');
            
            wvfm.preamble = obj.Query('WFMP?');
            wvfm.curve = obj.Query('CURV?');
            
            pream = strsplit(wvfm.preamble,';');
            wvfm.BYT_Nr = str2double(pream(1)); % bytes per point
            wvfm.BIT_Nr = str2double(pream(2)); % bits per point, = BYT_Nr*8
            wvfm.ENCd = pream(3); %ASC|BIN
            wvfm.BN_Fmt = pream(4); %RI|RP
            wvfm.BYT_Or = pream(5); % LSB|MSB
            wvfm.NR_Pt = str2double(pream(6)); % num of points, 2500
            wvfm.WFID = pream(7);
            wvfm.PT_FMT = pream(8); % ENV|Y
            wvfm.XINcr =  str2double(pream(9)); % X increment
            wvfm.PT_Off = str2double(pream(10));
            wvfm.XZEro = str2double(pream(11));
            wvfm.XUNit = pream(12);
            wvfm.YMUlt = str2double(pream(13));
            wvfm.YZEro = str2double(pream(14));
            wvfm.YOFF = str2double(pream(15));
            wvfm.YUNit = pream(16);
            
            Y = strsplit(wvfm.curve, ',');
            Y = str2double(Y)';
            wvfm.Y = wvfm.YZEro + wvfm.YMUlt*(Y - wvfm.YOFF);
            wvfm.X = wvfm.XZEro + wvfm.XINcr*((0:(wvfm.NR_Pt-1))' - wvfm.PT_Off);
        end
        
        function wvfm = saveTrace(obj,trace,filename)
            filename = char(filename);
            if strcmpi(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
            [dir,nn,~] = fileparts(filename);
            if ~isfolder(dir)
                warning('Folder does not exist, new folder created.')
                mkdir(dir)
            end
            
            wvfm = obj.ReadTrace(trace);
            X = wvfm.X;
            Y = wvfm.Y;
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
                % if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
                % end
            end
            
            save(strcat(filename, '.mat') ,'wvfm','X','Y')
            fprintf('OSCilloscope Data (channel %.0f) file saved as %s\n', trace, strcat(filename, '.mat') )
                figure
                plot(X, Y)
                title( sprintf('OSC Data (CH %.0f) \n saved name: %s', trace, nn ))
        end
        
    end
end