classdef MDT693B < handle
    % Maodong, version 0, 02082023
    % Controlling class for Thorlabs piezo controller MDT693B
    % Example:
    % piezo = MDT693B()
    % piezo.connect
    % piezo.set_x(50) % set channel x to 50V
    % piezo.get_z     % get channel z to current voltage
    
    
    properties
        visaObj;
        visaResourceString;
        disp_after_set = false
        InputBufferSize=1.5e7;
    end
        
    properties (Dependent = true)
    end
    
    
    methods
        function v = get_x(obj)
            v = str2double(obj.Query('xr?'));
        end
        function v = get_y(obj)
            v = str2double(obj.Query('yr?'));
        end
        function v = get_z(obj)
            v = str2double(obj.Query('zr?'));
        end
        
        function set_x(obj,v)
            obj.Write(strcat('XV', num2str(v)))
            if obj.disp_after_set
                pause(0.1)
                disp(strcat("X voltage set to ",num2str(obj.get_x)," V"))
            end
        end
        
        function set_y(obj,v)
            obj.Write(strcat('YV', num2str(v)))
            if obj.disp_after_set
                pause(0.1)
                disp(strcat("Y voltage set to ",num2str(obj.get_y)," V"))
            end
        end
        
        function set_z(obj,v)
            obj.Write(strcat('ZV', num2str(v)))
            if obj.disp_after_set
                pause(0.1)
                disp(strcat("Z voltage set to ",num2str(obj.get_z)," V"))
            end
        end
    end
    
    
    methods
        function obj = MDT693B(visaAddress)
            if nargin > 0
                obj.visaResourceString = visaAddress;
            else
                obj.visaResourceString = 'ASRL5::INSTR';
            end
            % obj.visaObj = visa('agilent',obj.visaResourceString);
            obj.visaObj = visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout = 5;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('Thorlab MDT693B piezo controller connected');
        end   
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Thorlab MDT693B piezo controller disconnected');
            end
            fclose(Obj.visaObj);
        end

        function Write(Obj,command)
            flushinput(Obj.visaObj)
            fprintf(Obj.visaObj, command);
            fscanf(Obj.visaObj);
        end
        function data = Query(Obj,command)
            flushinput(Obj.visaObj)
            fprintf(Obj.visaObj, command);
            resp = "";
            while ~contains(resp, ']')
                resp = strcat(resp,char(fread(Obj.visaObj, 1)));
            end
            
            % till now resp will be something like "xr?[10.7]"
            % Then extract actual response
            resp = char(resp);
            startIndex = strfind(resp, '[');
            endIndex = strfind(resp, ']');
            data = resp(startIndex+1:endIndex-1);
        end
    end

end