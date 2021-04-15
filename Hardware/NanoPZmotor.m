classdef NanoPZmotor < handle
    properties
        comString % COM communication address.
        serialObj % COM communication serial object
    end
    
    properties
        ADDRESS = 1 % CN: controller number == 1. Only Used in commands syntax. Will be useful if you have multiple controller.
    end
    
    properties (Dependent = true)
        channel % current channel
    end
    %% System related
    methods
        function obj = NanoPZmotor(comstr)
            if nargin > 0
                obj.comString = comstr;
            else
                obj.comString = "COM5"; % 231W: COM5; 233: COM3 
            end
            obj.serialObj = serial(obj.comString);
            obj.serialObj.BaudRate = 19200;
            obj.serialObj.Terminator = 'CR/LF';
        end
        
        function tt = isconnected(obj)
            if strcmp(obj.serialObj.Status, 'closed')
                tt = 0;
            else % strcmp(obj.serialObj.Status, 'open')
                tt = 1;
            end
        end
        
        function connect(obj)
            if obj.isconnected
                return
            else
                fopen(obj.serialObj);
            end
            
        end
        
        function Write(obj,cmd)
            cmd = strcat(num2str(obj.ADDRESS),cmd);
            fprintf(obj.serialObj, cmd);
        end
        function data = Query(obj,cmd)
            cmd = strcat(num2str(obj.ADDRESS),cmd);
            data = query(obj.serialObj, cmd);
        end
        
        function errorshow(obj)
            pause(0.3)
            info = obj.Query("TE?");
            temp = strsplit(info,' ');
            info = temp{end};
            flag = str2double( info );
            switch flag
                case 0 % no error
                    return
                case 2
                    error("Motor command error code %1.f: Driver fault (thermal shut down)\n", flag);
                case 6
                    error("Motor command error code %1.f: Unknown command\n", flag);
                case 7
                    error("Motor command error code %1.f: Parameter out of range\n", flag);
                case 8
                    error("Motor command error code %1.f: No motor connected\n", flag);
                case 26
                    error("Motor command error code %1.f: Positive software limit detected\n", flag);
                case 27
                    error("Motor command error code %1.f: Negative software limit detected\n", flag);
                case 38
                    error("Motor command error code %1.f: Command parameter missing\n", flag);
                case 50
                    error("Motor command error code %1.f: Communication Overflow\n", flag);
                case 213
                    error("Motor command error code %1.f: Motor not enabled\n", flag);
                case 214
                    error("Motor command error code %1.f: Invalid axis\n", flag);
                case 226
                    error("Motor command error code %1.f: Command not allowed during motion\n", flag);
                case 227
                    error("Motor command error code %1.f: Command not allowed\n", flag);
                case 240
                    error("Motor command error code %1.f: Jog wheel over speed\n", flag);
                otherwise
                    error("Motor command error code %1.f\n Error code NOT recognized.", flag);
            end
        end
    end
    
    %% Motor related
    methods
        function set.channel(obj,chan)
            obj.selectChannel(chan);
        end
        function ch = get.channel(obj)
            info = obj.Query("MX?");
            temp = split(info,' ');
            ch = str2double(temp{end});
        end
        
        function ON(obj)
            obj.Write("MO")
            obj.errorshow;
        end
        function OFF(obj)
            obj.Write("MF")
            obj.errorshow;
        end
        
        function stop(obj)
            obj.Write("ST")
            obj.errorshow;
        end
        
        function startJog(obj, gear, chan) % gear choose from 0|1|2|3|4|5|6|7
            if nargin == 3
                obj.channel = chan;
                pause(0.3)
            end
            fprintf("Selected Motor channel: %1.f \n", obj.channel);
            speedList = [3.2 16 80 400 2000 10000 48000];
            if ( ~mod(gear,1)==0 ) || abs(gear)>7
                error("Unexcepted jog speed %f, should be [+|-] [0|1|2|3|4|5|6|7]", gear)
            end
                % --- Safety control: confim before assigning a high speed ---
                    % if abs(gear)>5
                    %     reply = input('Very high motor jogging speed! Are you sure [Y/N]?','s');
                    %     if ~strcmp(reply,'Y')
                    %         warning("Jogging command aborted.\n");
                    %         return
                    %     end
                    % end
                % --- Safety control ended ---
            if gear == 0
                jogspeed = 0; % used to show information in command window.
            else
                jogspeed = speedList(abs(gear));
            end
            if gear<0
                jogdirection = '-'; % used to show information in command window.
            else
                jogdirection = '+';
            end
            fprintf("motor moving at Gear %1.f, %c %.1f �step/s \n", abs(gear), jogdirection, jogspeed);
            obj.Write( strcat("JA",num2str(gear)) );
            
            obj.errorshow;
        end
        
        function startRelative(obj,steps, chan)
            if nargin == 3
                obj.channel = chan;
                pause(0.5)
            end
            fprintf("Selected Motor channel: %1.f \n", obj.channel);
            fprintf("Initiating Relative motion: %1.f �step\n", round(steps) );
            
            obj.Write( strcat( "PR",num2str(round(steps)) ) );
            obj.errorshow;
        end
        
    end
    
    %% Position related. Rarely used.
    methods
        
        function zeroPosition(obj,chan)
            obj.selectChannel(chan);
            pause(0.5);
            obj.Write("OR");
            obj.errorshow;
        end
        function cp = currentPosition(obj,chan)
            info = obj.Query(strcat("TP", num2str(chan),"?"));
            temp = strsplit(info,' ');
            cp = str2double(temp{end});
            obj.errorshow;
        end
    end
    %% 
    methods (Access = private)
        function selectChannel(obj, chan)
            obj.Write(strcat("MX",num2str(chan)));
            obj.errorshow;
        end
    end
end