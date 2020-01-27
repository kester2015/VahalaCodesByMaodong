classdef IPGPhotonics < handle
    % IPG Photonics EDFA
    properties
        visaObj
        IPAddress
    end
    
    properties (Dependent = true)
        Current
        Power
        Emission
    end
    
    properties (Dependent = true, SetAccess = immutable)
        Input
        Output
    end
    
    methods
        function obj = IPGPhotonics(IP)
            obj.IPAddress = IP;
            obj.visaObj = visa('ni', ['TCPIP0::' obj.IPAddress '::10001::SOCKET']);
            obj.visaObj.Timeout = 1;
            obj.visaObj.ByteOrder = 'littleEndian';
        end
        
        function delete(obj)
            obj.disconnect();
        end
        
        function b = isconnected(obj)
            b = strcmp(obj.visaObj.Status,'open');
        end
        
        function connect(obj)
            if (obj.isconnected)
                return
            end
            fopen(obj.visaObj);
            disp('IPG Photonics EDFA connected');
        end
        
        function disconnect(obj)
            if (Obj.isconnected)
                disp('IPG Photonics EDFA disconnected');
            end
            fclose(obj.visaObj);
        end
        
        function Write(obj,command)
            fprintf(obj.visaObj,command);
        end
        
        function str = Read(obj)
            str = fscanf(obj.visaObj);
        end
        
        function str = Query(obj,command)
            str = query(obj.visaObj,command);
        end
        
        function Reset(obj)
            obj.Query('RERR');
        end
        %%
        function I = get.Current(obj)
            rt = obj.Query('RCS');
            I = str2double(rt(6:end));
        end
        function set.Current(obj,I)
            obj.Query(sprintf('SCS %.2f',I));
        end
        
        function P = get.Power(obj)
            rt = obj.Query('RPS');
            P = str2double(rt(6:end));
        end
        function set.Power(obj,I)
            obj.Query(sprintf('SPS %.2f',I));
        end
        
        function t = get.Emission(obj)
            t = strcmp(obj.Query('REM'),'REM: ON');
        end
        function set.Emission(obj,state)
            if state == 0
                obj.Query('EMOFF');
            else
                obj.Query('EMON');
            end
        end
        
        function P = get.Input(obj)
            rt = obj.Query('RIN');
            P = str2double(rt(6:end));
        end
        
        function P = get.Output(obj)
            rt = obj.Query('ROP');
            P = str2double(rt(6:end));
        end
    end
end