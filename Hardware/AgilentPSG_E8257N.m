classdef AgilentPSG_E8257N < handle
    properties
        visaObj
    end
    
    properties (Dependent = true)
        Freq % in unit of Hz
        Power % in unit of dBm
        
        RFOut % Binary, state of RF output
    end

    
    %% connection related
    methods
        function Obj = AgilentPSG_E8257N(strvisa)
            if nargin == 0
                strvisa = 'GPIB1::19::INSTR';
            end
            Obj.visaObj = visa('AGILENT',strvisa);
            Obj.visaObj.Timeout = 100;
            Obj.visaObj.ByteOrder = 'littleEndian';
        end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('Agilent E8257N PSG connected');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Agilent E8257N PSG disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj, command)
            fprintf(Obj.visaObj, command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
        
    end
    
    %% parameters related
    methods
        function set.Freq(Obj, Freq) % Freq in unit of Hz
            Obj.Write(strcat("FREQ ",num2str(Freq)," Hz"))
            % fprintf(Obj.visaObj, strcat("FREQ ",num2str(Freq)," Hz") );
        end
        
        function set.Power(Obj, Power) % Power in unit of dBm
            Obj.Write(strcat("POWER ",num2str(Power)," DBM"));
            % fprintf(Obj.visaObj, strcat("FREQ ",num2str(Power)," DBM") );
        end
        
        function ff = get.Freq(Obj)
            ff = str2double( Obj.Query(":FREQ?") );
        end
        
        function ff = get.Power(Obj)
            ff = str2double( Obj.Query(":POWER?") );
        end
    end
    %% RF On and OFF
    methods
        function set.RFOut(Obj, state)
            if isnumeric(state) && length(state) == 1
                if state
                    Obj.Write(strcat(":OUTP ON"));
                else
                    Obj.Write(strcat(":OUTP OFF"));
                end
            elseif strcmpi(state,"ON") || strcmpi(state,"OFF")
                Obj.Write(strcat( ":OUTP ", upper(state)) );
            else
                error("Unidentified RFOut state flag. Should be ON|OFF|0|1")
            end
        end
        
        function tt = get.RFOut(Obj)
            tt = str2double( Obj.Query(":OUTP?") );
        end
    end
    
end