classdef TLB6700 < handle
    % New Focus Laser Controller
    properties (Hidden = true)
        % Newport USB
        USBObj % Newport.USBComm.USB
        DeviceID % int
        Stringbuffer % System.Text.StringBuilder
    end
    
    properties (Dependent = true)
        % Laser Parameters
        Wavelength % [nm]
        Track % 0:OFF 1:ON
        Current % [mA]
        Power % [mW]
        PowerON % 0:OFF 1:ON
        StartWavelength % [nm]
        StopWavelength % [nm]
        FwdVelocity % [nm/s]
        RevVelocity % [nm/s]
        DesiredScan % Times
        Piezo % piezo percentage
    end
    
    methods
        %% Core
        function obj = TLB6700()
            dllpath = mfilename('fullpath');
            idx = strfind(dllpath,'\');
            dllpath = dllpath(1:idx(end));
            NET.addAssembly([dllpath '/UsbDllWrap.dll']); % put this .dll file in the same folder
            obj.USBObj = Newport.USBComm.USB(true);
            obj.Stringbuffer = System.Text.StringBuilder(64);
        end
        
        function delete(obj)
            obj.disconnect;
        end
        
        function b = isconnected(obj)
            b = ~isempty(obj.DeviceID);
        end
        
        function connect(obj)
            if (obj.isconnected)
                return
            end
            if obj.USBObj.OpenDevices
                obj.DeviceID = obj.USBObj.GetDevInfoList.Item(0).ID;
%                 obj.DeviceID=hex2dec('100A');
            else
                error('Can not open USB Device')
            end
            Devicestr = obj.Query('*IDN?');
            disp([Devicestr ' connected']);
        end
        
        function disconnect(obj)
            if (~obj.isconnected)
                return
            end
            Devicestr = obj.Query('*IDN?');
            disp([Devicestr ' disconnected']);
            obj.USBObj.CloseDevices;
            obj.DeviceID = [];
        end
        
        function str = Query(obj,msg)
            obj.USBObj.Query(obj.DeviceID, msg, obj.Stringbuffer);
            str = char(obj.Stringbuffer.ToString); % Convert System.String to Matlab char array
            obj.Stringbuffer.Clear();
        end
        
        function Reset(obj)
            obj.Query('*RST');
        end
        
        %% Laser Commands
        function l = get.Wavelength(obj) % get actual wavelength
            l = str2double(obj.Query('SENSE:WAVELENGTH?'));
        end
        function set.Wavelength(obj,lambda) % set wavelength (track should be on)
            obj.Query(sprintf('SOURCE:WAVELENGTH %f',lambda));
        end
        
        function t = get.Track(obj)
            t = str2double(obj.Query('OUTPUT:TRACK?'));
        end
        function set.Track(obj,state)
            obj.Query(sprintf('OUTPUT:TRACK %d',state));
        end
        
        function I = get.Current(obj)
            I = str2double(obj.Query('SENSE:CURRENT:DIODE?'));
        end
        function set.Current(obj,I)
            obj.Query(sprintf('SOURCE:CURRENT:DIODE %f',I));
        end
        
        function P = get.Power(obj)
            P = str2double(obj.Query('SENSE:POWER:DIODE?'));
        end
        function set.Power(obj,P)
            obj.Query(sprintf('SOURCE:POWER:DIODE %f',P));
        end
        
        function t = get.PowerON(obj)
            t = str2double(obj.Query('OUTPUT:STATE?'));
        end
        function set.PowerON(obj,state)
            obj.Query(sprintf('OUTPUT:STATE %d',state));
        end
        
        function l = get.StartWavelength(obj)
            l = str2double(obj.Query('SOURCE:WAVELENGTH:START?'));
        end
        function set.StartWavelength(obj,lambda)
            obj.Query(sprintf('SOURCE:WAVELENGTH:START %f',lambda));
        end
        
        function l = get.StopWavelength(obj)
            l = str2double(obj.Query('SOURCE:WAVELENGTH:STOP?'));
        end
        function set.StopWavelength(obj,lambda)
            obj.Query(sprintf('SOURCE:WAVELENGTH:STOP %f',lambda));
        end
        
        function l = get.FwdVelocity(obj)
            l = str2double(obj.Query('SOURCE:WAVELENGTH:SLEW:FORWARD?'));
        end
        function set.FwdVelocity(obj,lambda)
            obj.Query(sprintf('SOURCE:WAVELENGTH:SLEW:FORWARD %f',lambda));
        end
        
        function l = get.RevVelocity(obj)
            l = str2double(obj.Query('SOURCE:WAVELENGTH:SLEW:RETURN?'));
        end
        function set.RevVelocity(obj,lambda)
            obj.Query(sprintf('SOURCE:WAVELENGTH:SLEW:RETURN %f',lambda));
        end
        
        function l = get.DesiredScan(obj)
            l = str2double(obj.Query('SOURCE:WAVELENGTH:DESSCANS?'));
        end
        function set.DesiredScan(obj,lambda)
            obj.Query(sprintf('SOURCE:WAVELENGTH:DESSCANS %f',lambda));
        end
        
        function l = get.Piezo(obj)
            l = str2double(obj.Query('SOURCE:VOLTAGE:PIEZO?'));
        end
        function set.Piezo(obj,lambda)
            obj.Query(sprintf('SOURCE:VOLTAGE:PIEZO %f',lambda));
        end
        
        %% Advanced
        function SetScan(obj,start,stop,fwdspd,revspd,times)
            if (nargin < 6)
                times = 1;
                if (nargin < 5)
                    revspd = fwdspd;
                end
            end
            if (obj.StartWavelength ~= start)
                obj.StartWavelength = start;
            end
            if (obj.StopWavelength ~= stop)
                obj.StopWavelength = stop;
            end
            if (obj.FwdVelocity ~= fwdspd)
                obj.FwdVelocity = fwdspd;
            end
            if (obj.RevVelocity ~= revspd)
                obj.RevVelocity = revspd;
            end
            if (obj.DesiredScan ~= times)
                obj.DesiredScan = times;
            end
        end
        
        function Scan(obj)
            obj.Query('OUTPUT:SCAN:START');
        end
        
        function Move2Wavelength(obj,l)
            obj.Wavelength = l;
            obj.Track = 1;
            while abs(obj.Wavelength - l) > 0.1
                pause(3);
            end
            obj.Track = 0;
        end
        
        function Move2Piezo(obj,l)
            obj.Piezo = l;
        end
    end
end