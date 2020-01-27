classdef TopticaDLC < handle
    % Toptica DLC Laser Controller
    properties
        %visa
        SerialObj
        USBAddress = 'COM18'
    end
    
    properties (Dependent = true)
        % Laser Parameters
        Wavelength % [nm]
        Current % [mA]
        StartWavelength % [nm]
        StopWavelength % [nm]
        ScanSpeed % [nm/s]
        ExternalScan % 0:OFF 1:ON
        PowerON % 0:OFF 1:ON
        
        ScanAmp % should be 0
        ScanOff % should be 0
    end
    
    properties (Dependent = true, SetAccess = immutable)
        Power % [mW]
    end
    
    methods
        %% Core
        function obj = TopticaDLC()
            obj.SerialObj = serial(obj.USBAddress, 'BaudRate', 115200);
        end
        
        function delete(obj)
            obj.disconnect();
        end
        
        function b = isconnected(obj)
            b = strcmp(obj.SerialObj.Status,'open');
        end
        
        function connect(obj)
            if (obj.isconnected)
                return
            end
            fopen(obj.SerialObj);
            disp('Toptica laser connected');
        end
        
        function disconnect(obj)
            if ~isvalid(obj)
                return
            end
            if (obj.isconnected)
                disp('Toptica laser disconnected');
            end
            fclose(obj.SerialObj);
        end
        
        function Write(obj,command)
            fprintf(obj.SerialObj,command);
        end
        
        function str = Read(obj)
            str = fscanf(obj.SerialObj);
        end
        
        function data = Query(obj,command)
            query(obj.SerialObj,command);
            data = obj.Read;
        end
        
        function Reset(obj)
            obj.Query('*RST');
        end
        
        function data = Get(obj,msg)
            data = obj.Query(['(param-ref ''' msg ')']);
        end
        
        function data = Set(obj,msg)
            data = obj.Query(['(param-set! ''' msg ')']);
        end
        
        function data = Command(obj,msg)
            data = obj.Query(['(exec ''' msg ')']);
        end
        %% Laser CMDs
        function l = get.Wavelength(obj) % get actual wavelength
            l = str2double(obj.Get('laser1:ctl:wavelength-act'));
        end
        function set.Wavelength(obj,lambda) % set wavelength (track should be on)
            obj.Set(sprintf('laser1:ctl:wavelength-set %f',lambda));
        end
        
        function I = get.Current(obj)
            I = str2double(obj.Get('laser1:dl:cc:current-set'));
        end
        function set.Current(obj,I)
            obj.Set(sprintf('laser1:dl:cc:current-set %f',I));
        end
        
        function l = get.StartWavelength(obj)
            l = str2double(obj.Get('laser1:ctl:scan:wavelength-begin'));
        end
        function set.StartWavelength(obj,lambda)
            obj.Set(sprintf('laser1:ctl:scan:wavelength-begin %f',lambda));
        end
        
        function l = get.StopWavelength(obj)
            l = str2double(obj.Get('laser1:ctl:scan:wavelength-end'));
        end
        function set.StopWavelength(obj,lambda)
            obj.Set(sprintf('laser1:ctl:scan:wavelength-end %f',lambda));
        end
        
        function v = get.ScanSpeed(obj)
            v = str2double(obj.Get('laser1:ctl:scan:speed'));
        end
        function set.ScanSpeed(obj,v)
            obj.Set(sprintf('laser1:ctl:scan:speed %f',v));
        end
        
        function P = get.Power(obj)
            P = str2double(obj.Get('laser1:ctl:power:power-act'));
        end
        
        function t = get.PowerON(obj)
            t = strcmp(obj.Get('laser1:emission'),sprintf('#t\r\n')) && obj.Current > 1;
        end
        function set.PowerON(obj,b)
            if b
                obj.Current = 320;
                obj.ExternalScan = 1;
            else
                obj.Current = 0;
                obj.ExternalScan = 0;
            end
        end
        
        function A = get.ScanAmp(obj)
            A = str2double(obj.Get('laser1:scan:amplitude'));
        end
        function set.ScanAmp(obj,A)
            obj.Set(sprintf('laser1:scan:amplitude %f',A));
        end
        
        function off = get.ScanOff(obj)
            off = str2double(obj.Get('laser1:scan:offset'));
        end
        function set.ScanOff(obj,off)
            obj.Set(sprintf('laser1:scan:offset %f',off));
        end
        
        function t = get.ExternalScan(obj)
            t = strcmp(obj.Get('laser1:dl:pc:external-input:enabled'),sprintf('#t\r\n'));
        end
        function set.ExternalScan(obj,b)
            if b
                obj.Set('laser1:dl:pc:external-input:enabled #t');
            else
                obj.Set('laser1:dl:pc:external-input:enabled #f');
            end
        end
        %% Advanced
        function SetScan(obj,start,stop,speed) % 1520 1630 10
            if (obj.StartWavelength ~= start)
                obj.StartWavelength = start;
            end
            if (obj.StopWavelength ~= stop)
                obj.StopWavelength = stop;
            end
            if (obj.ScanSpeed ~= speed)
                obj.ScanSpeed = speed;
            end
        end
        
        function Scan(obj)
            obj.Command('laser1:ctl:scan:start');
        end
        
        function Move2Wavelength(obj,l)
            obj.Wavelength = l;
            while abs(obj.Wavelength - l) > 0.5
                pause(2);
            end
        end
    end
end