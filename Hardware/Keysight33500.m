classdef Keysight33500 < handle
    % Keysight function generator
    properties
        visaObj
    end
    
    properties (Dependent = true)
        DC1
        DC2
        Freq1
        Phase1
    end
    
    %% Initialization and Connect
    methods 
        function Obj = Keysight33500(strvisa)
            Obj.visaObj = visa('AGILENT', strvisa);
            Obj.visaObj.Timeout = 100;
            Obj.visaObj.ByteOrder = 'littleEndian';
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
            disp('Keysight33500 function generator connected');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Keysight33500 function generator disconnected');
            end
            fclose(Obj.visaObj);
        end
        
    end
    
    
    %% DC wvfm setup
    methods
        function set.DC1(Obj,offset)
            fprintf(Obj.visaObj,['SOUR1:APPL:DC 10,0,' num2str(offset)]);
%             Obj.DC1 = offset;
        end
        
        function set.DC2(Obj,offset)
            fprintf(Obj.visaObj,['SOUR2:APPL:DC 10,0,' num2str(offset)]);
%             Obj.DC2 = offset;
        end
        
        function set.Freq1(Obj,coe)
            freq = coe(1);
            Vpp = coe(2);
            offset = coe(3);
            fprintf(Obj.visaObj,['SOUR1:APPL:TRI ' num2str(freq) 'Hz,' num2str(Vpp) 'V,' num2str(offset)]);
        end
        function set.Phase1(Obj,phase)
%             fprintf(Obj.visaObj, 'SOURce[1|2]:]BURSt:MODE TRIGgered');
            fprintf(Obj.visaObj, 'SOUR1:BURS:STAT ON');
            fprintf(Obj.visaObj,['SOUR1:BURS:PHAS ' num2str(phase)]);
        end
        
    end
    
    
    %% Trigger set up
    methods
        function Trigger1(Obj)
%             fprintf(Obj.visaObj, 'TRIGger[1|2]:COUNt{1}');
            fprintf(Obj.visaObj, 'TRIG1:SOUR BUS');
            fprintf(Obj.visaObj, '*TRG');
        end
        
        function TriggerExt1(Obj)
%             fprintf(Obj.visaObj, 'TRIGger[1|2]:COUNt{1}');
            fprintf(Obj.visaObj, 'TRIG1:SOUR EXT');
            fprintf(Obj.visaObj, '*TRG');
        end
        
        function TriggerExt2(Obj)
%             fprintf(Obj.visaObj, 'TRIGger[1|2]:COUNt{1}');
            fprintf(Obj.visaObj, 'TRIG2:SOUR EXT');
%             fprintf(Obj.visaObj, '*TRG');
        end
        
        function path(Obj,CH1,CH2,interval)
            if numel(CH1) ~= numel(CH2)
                disp('Invalid Path!')
                return
            end
            for ii = 1:numel(CH1)
                Obj.DC1 = CH1(ii);
                Obj.DC2 = CH2(ii);
                pause(interval);
            end
        end
    end 
    
    %% On and OFF state set up
    methods
        function CH1(Obj,state)
            fprintf(Obj.visaObj,['OUTP1 ' num2str(state)]);
        end
        
        function CH2(Obj,state)
            fprintf(Obj.visaObj,['OUTP2 ' num2str(state)]);
        end
        
    end
end