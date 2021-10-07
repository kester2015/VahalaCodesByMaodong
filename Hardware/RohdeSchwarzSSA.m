classdef RohdeSchwarzSSA < handle
    properties
        visaResourceString;
        visaObj;
        InputBufferSize=1.5e7;
        % bPointCheck = true;
    end
    
    properties (Dependent = true)
        mode
    end
    
    %% Basic connect, write and query functions
    methods
        function obj = RohdeSchwarzSSA(visaResourceString)
            if nargin >0
                obj.visaResourceString = visaResourceString;
            else
                obj.visaResourceString = 'GPIB1::21::INSTR';
            end
            obj.visaObj=visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout=30;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                disp('Rohde&Schwarz SSA (Signal Source Analyzer) ALREADY connected');
                return
            end
            fopen(Obj.visaObj);
            disp('Rohde&Schwarz SSA (Signal Source Analyzer) connected');
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
                disp('Rohde&Schwarz PNA disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj,command)
            % if any( strcmpi(num2str(command),["1","2","3","4","5","6","7","8"] ) ==1 )
            %     warning("Write function is sending a trace label as command. Make sure you shouldn't use wirteTrace instead.")
            % end
            fprintf(Obj.visaObj, command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
    end
    
    %% Get and set methods for dependent properties
    methods
        function tt = get.mode(obj)
            % will be SAN|ADEM|PNO
            tt = obj.Query('INST:SEL?');
            tt = tt(1:end-1); % discard '\n' at the end.
        end
        function set.mode(obj, modetoset)
            obj.ModeSelect(modetoset);
        end
    end
    
    %%
    methods
        function results = readTrace(obj, traceNum)
            command_tosend = strcat( "TRAC? TRACE",num2str(traceNum) );
            datastr = obj.Query(command_tosend);
            dataArray = str2double( strsplit(datastr,',') );
            results = reshape(dataArray,[2 length(dataArray)/2])';
        end
        
        function viewTrace(obj, traceNum)
            % if (~length(traceNum)==1) || (~isnumeric(traceNum)) || (~mod(traceNum,1)==0) || (traceNum>8) || (traceNum<1)
            %     error("MaodongError:UnRecognizedInput","traceNUM %s unrecognized.\n Trace NUM should be integer number: 1|2|3|4|5|6|7|8", traceNum)
            % end
            command_tosend = strcat("DISP:WIND:TRAC",num2str(traceNum),":MODE VIEW");
            obj.Write(command_tosend);
        end
        
        function blankTrace(obj, traceNum)
            % if (~length(traceNum)==1) || (~isnumeric(traceNum)) || (~mod(traceNum,1)==0) || (traceNum>8) || (traceNum<1)
            %     error("MaodongError:UnRecognizedInput","traceNUM %s unrecognized.\n Trace NUM should be integer number: 1|2|3|4|5|6|7|8", traceNum)
            % end
            command_tosend = strcat("DISP:WIND:TRAC",num2str(traceNum)," OFF");
            obj.Write(command_tosend);
        end
        
        function writeTrace(obj, traceNum)
            % if (~length(traceNum)==1) || (~isnumeric(traceNum)) || (~mod(traceNum,1)==0) || (traceNum>8) || (traceNum<1)
            %     error("MaodongError:UnRecognizedInput","traceNUM %s unrecognized.\n Trace NUM should be integer number: 1|2|3|4|5|6|7|8", traceNum)
            % end
            command_tosend = strcat("DISP:WIND:TRAC",num2str(traceNum)," OFF");
            obj.Write(command_tosend);
        end
        
        function averageTrace(obj, traceNum)
            % if (~length(traceNum)==1) || (~isnumeric(traceNum)) || (~mod(traceNum,1)==0) || (traceNum>8) || (traceNum<1)
            %     error("MaodongError:UnRecognizedInput","traceNUM %s unrecognized.\n Trace NUM should be integer number: 1|2|3|4|5|6|7|8", traceNum)
            % end
            command_tosend = strcat("DISP:WIND:TRAC",num2str(traceNum),":MODE AVER");
            obj.Write(command_tosend);
        end
        
    end
    
    %% Private methods
    methods (Access = private)
        function ModeSelect(obj, modestr)
            if ~isstr(modestr)
                error('MaodongError:UnRecognizedMode',...
                    'Specified mode "%f" must be a string AND choose from:\n SAN|SP : (Spectrum) Analyzer mode\n ADEM|FM|DM : FM demodulator mode\n PN|PNO : Phase noise measurement mode',...
                    modestr)
            end
            modeFlag = 0; % Defined in API. INSTrument:NSELect 
            % modeFlag: 1: Analyzer mode, 3: FM demodulator mode, 20: Phase noise measurement
            if contains(upper(modestr),'SAN') || contains(upper(modestr), 'SP')
                fprintf('(Spectrum) Analyzer mode selected.\n')
                modeFlag = 1;
            elseif contains(upper(modestr),'ADEM') || contains(upper(modestr),'FM') || contains(upper(modestr), 'DM')
                fprintf('FM demodulator mode selected.\n')
                modeFlag = 3;
            elseif contains(upper(modestr),'PN') %|| contains(upper(modestr),'PNO')
                fprintf('Phase noise measurement mode selected.\n')
                modeFlag = 20;
            else
                error('MaodongError:UnRecognizedMode',...
                    'Specified mode "%s" unrecognizeed. Must choose from:\n SAN|SP : (Spectrum) Analyzer mode\n ADEM|FM|DM : FM demodulator mode\n PN|PNO : Phase noise measurement mode',...
                    modestr)
            end
            command_tosend = strcat( "INST:NSEL ",num2str(modeFlag) );
            obj.Write(command_tosend)
        end
        
    end
end