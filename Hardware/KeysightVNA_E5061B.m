classdef KeysightVNA_E5061B < handle
    properties
        visaResourceString;
        visaObj;
        InputBufferSize=1.5e7;
%         bPointCheck = true;
    end
    
    properties (Dependent = true)
        freq_start
        freq_stop
        IF_bandwidth
        power_dB
        sweep_type % 'LIN' or 'LOG'
        sweep_points 
    end
    
    %% general methods
    methods
        function obj = KeysightVNA_E5061B(visaResourceString)
            if nargin>0
                obj.visaResourceString = visaResourceString;
            else
                obj.visaResourceString = "GPIB0::17::INSTR";
            end
            obj.visaObj=visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout=30;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('Keysight VNA E5061B connected');
        end
        
        % function delete(Obj)
        %     Obj.disconnect();
        % end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Keysight VNA E5061B disconnected');
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
    
    %%
    methods
        function Single(obj)
            obj.Write(":INIT:IMM")
        end
    end
    %% Dependent properties
    methods
        function freq = get.freq_start(obj)
            freq = str2double(obj.Query(':SENS1:FREQ:START?'));
        end
        function set.freq_start(obj,freq)
            obj.Write(strcat(":SENS1:FREQ:START ", num2str(freq)))
        end
        function freq = get.freq_stop(obj)
            freq = str2double(obj.Query(':SENS1:FREQ:STOP?'));
        end
        function set.freq_stop(obj,freq)
            obj.Write(strcat(":SENS1:FREQ:STOP ", num2str(freq)))
        end
        function freq = get.IF_bandwidth(obj)
            freq = str2double(obj.Query(':SENS1:BAND?'));
        end
        function set.IF_bandwidth(obj,freq)
            obj.Write(strcat(":SENS1:BAND ", num2str(freq)))
        end
        function f = get.power_dB(obj)
            f = str2double(obj.Query(':SOUR1:POW?'));
        end
        function set.power_dB(obj,f)
            obj.Write(strcat(":SOUR1:POW ", num2str(f)))
        end
        function f = get.sweep_points(obj)
            f = str2double(obj.Query(':SENS:SWE:POIN?'));
        end
        function set.sweep_points(obj,f)
            obj.Write(strcat(":SENS:SWE:POIN ", num2str(f)))
        end
        
        function f = get.sweep_type(obj)
            f = obj.Query(':SENS:SWE:TYPE?');
            f = f(1:end-1);
        end
        function set.sweep_type(obj,f)
            obj.Write(strcat(":SENS:SWE:TYPE ", f))
        end
    end
    %%
    methods
        function [X,Y1,Y2] = ReadTrace(obj)
            x=obj.Query(":SENS1:FREQ:DATA?");
            x=strsplit(x,',');
            X=str2double(x); % wavelength in unit of NM.
            y=obj.Query(":CALC1:DATA:FDAT?");
            y=strsplit(y,',');
            Y=str2double(y);
            X=X';
            Y=Y';
            Y1=Y(1:2:end);
            Y2=Y(2:2:end);
        end
        
        function vnaTrace = saveTrace(obj,filename)
            filename = char(filename);
            if strcmpi(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
            [dir, matname] = fileparts(filename);
            if ~isfolder(dir)
                warning('Folder does not exist, new folder created.')
                mkdir(dir)
            end
            filename = strcat(dir,filesep,'VNA_',matname);
            
%             obj.Stop;
            [X, Y1, Y2] = obj.ReadTrace();
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
    %             if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
    %             end
            end
            
            vnaTrace.XData = X;
            vnaTrace.YData = Y1;
            vnaTrace.Y2Data = Y2;
            
            vnaTrace.IF_bandwidth = obj.IF_bandwidth;
            vnaTrace.power_dB = obj.power_dB;
            
            save(strcat(filename, '.mat') ,'vnaTrace')
            fprintf('VNA Data (channel 1) file saved as %s\n', strcat(filename, '.mat') )
                figure
                plot(X, Y1)
        end
        
        
    end
end