classdef NF6300 < handle
    % New Focus Laser Controller
    properties (Hidden = true)
        GPIBObj
    end
    
    properties (Dependent = true)
        Wavelength % [nm]
        Track % 0:OFF 1:ON
        Current % [mA]
        Power % [mW]
        PowerON % 0:OFF 1:ON
        
        StartWavelength
        StopWavelength
        FwdVelocity
        RevVelocity
        DesiredScan
    end
    
    methods
        function obj = NF6300()
            obj.GPIBObj = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 10, 'Tag', '');
            if isempty(obj.GPIBObj)
                obj.GPIBObj = gpib('AGILENT', 32, 10);
            else
                fclose(obj.GPIBObj);
                obj.GPIBObj = obj.GPIBObj(1);
            end
        end
        
        function delete(obj)
            obj.disconnect();
        end
        
        function b = isconnected(obj)
            b = strcmp(obj.GPIBObj.Status,'open');
        end
        
        function connect(obj)
            if (obj.isconnected)
                return
            end
            fopen(obj.GPIBObj);
            disp('New Focus laser connected');
        end
        
        function disconnect(obj)
            if ~isvalid(obj)
                return
            end
            if (obj.isconnected)
                disp('New Focus laser disconnected');
            end
            fclose(obj.GPIBObj);
        end
        
        function str = Query(obj,cmd)
            str = query(obj.GPIBObj,cmd);
        end
            
        function wait(obj)
            operationComplete = str2double(obj.Query('*OPC?'));
            while ~operationComplete
                operationComplete = str2double(obj.Query('*OPC?'));
            end
        end
        %% Laser Parameters
        function l = get.Wavelength(obj) % get actual wavelength
            l = str2double(obj.Query(':SENS:WAVE'));
        end
        function set.Wavelength(obj,lambda) % set wavelength (track should be on)
            obj.Query(sprintf(':Wave %f',lambda));
        end
        
        function TrackOFF(obj)
            obj.Query(':OUTP:TRAC OFF');
        end
        
        function I = get.Current(obj)
            I = str2double(obj.Query(':SENS:CURR:DIOD'));
        end
        function set.Current(obj,I)
            obj.Query(sprintf(':CURR %f',I));
        end
        
        function P = get.Power(obj)
            P = str2double(obj.Query(':SENS:POW:FRON?'));
        end
        function set.Power(obj,P)
            obj.Query(sprintf(':POW %f',P));
        end
        
        function t = get.PowerON(obj)
            t = str2double(obj.Query(':OUTP?'));
        end
        function set.PowerON(obj,state)
            obj.Query(sprintf(':OUTP %d',state));
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
        %%
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
        
        function Move2Wavelength(obj, l)
            obj.Wavelength = l;
            while abs(obj.Wavelength - l) > 0.1
                pause(3);
            end
            obj.TrackOFF;
        end
    end
end
