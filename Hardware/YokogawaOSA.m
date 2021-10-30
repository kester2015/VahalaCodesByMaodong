classdef YokogawaOSA < handle
    properties
        visaResourceString;
        visaObj;
        InputBufferSize=1.5e7;
        bPointCheck = true;
    end
    
    properties (Dependent = true)
        % wl refer to wavelength
        wlcenter % center wavelength
        wlspan
        % -- following are derived values in code. 
        wlstart
        wlstop
        wlscale % nm per division
        
        %
        sens % sensitivity, choose from NHLD|NAUT|NORM|MID|HIGH1|HIGH2|HIGH3; NHLD is NORM/HOLD, NAUT is NORM/AUTO.
        
        % % ---- vertical ----
        % position
        reflevel % reference level in dBm unit
        refscale % referenc level in dBm/Div
        % -- following are derived values
        % refup % highest reference level, in dBm unit
        % - vertical unit, linear or log, absolute or density
        vertunit % vertical unit, choose from DBM|W|DBM/NM|W/NM
%         % position in linear level
        reflevel_lin % reference level in linear unit, W
%         refscale_lin % reference level in W/Div
    end
    
    properties (Access = private)
        NUM_HOR_DIV = 10;
        NUM_VER_DIV = 10;
        NUM_VERREF_POS = 8; % reference level positioned at #8 div from bottom to top, if in DB mode
    end
    
    methods
        function obj=YokogawaOSA(visaResourceString)
            if nargin>0
                obj.visaResourceString = visaResourceString;
            else
                obj.visaResourceString = "GPIB1::1::INSTR";
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
            disp('Yokogawa OSA connected');
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
                disp('Yokogawa OSA disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj,command)
            % if any( strcmpi(command,["A","B","C","D","E","F","G"] ) ==1 )
            %     warning("Write function is sending a channel label as command. Make sure you shouldn't use wirteTrace instead.")
            % end
            fprintf(Obj.visaObj, command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
        %% Trace operations
        function writeTrace(obj,trace)
            if any( strcmpi(trace,["A","B","C","D","E","F","G"] ) ==1 )
                if strcmpi(trace,'A')
                    error("OSA: DO NOT write trace A before DTRA review. Zhiquan will use that trace on 10-23-2021.")
                end
                tt = strcat("TRAC:ATTR:TR",upper(trace)," WRIT");
                fprintf("OSA: Trace %s is being written.\n",upper(trace))
                obj.Write(tt)
                obj.dispTrace(trace)
            elseif strcmpi(trace,"all")
                for tr = ["A","B","C","D","E","F","G"]
                    obj.writeTrace(tr);
                end
            else
                error("Unrecognized trace %s, should be A to G.",trace)
            end
        end
        function fixTrace(obj,trace)
            if any( strcmpi(trace,["A","B","C","D","E","F","G"] ) ==1 )
                tt = strcat("TRAC:ATTR:TR",upper(trace)," FIX");
                fprintf("OSA: Trace %s is being fixed.\n",upper(trace))
                obj.Write(tt)
            elseif strcmpi(trace,"all")
                for tr = ["A","B","C","D","E","F","G"]
                    obj.fixTrace(tr);
                end
            else
                error("Unrecognized trace %s, should be A to G.",trace)
            end
        end
        function dispTrace(obj,trace)
            if any( strcmpi(trace,["A","B","C","D","E","F","G"] ) ==1 )
                tt = strcat(":TRAC:STAT:TR",upper(trace)," ON");
                fprintf("OSA: Trace %s is displayed.\n",upper(trace))
                obj.Write(tt)
            elseif strcmpi(trace,"all")
                for tr = ["A","B","C","D","E","F","G"]
                    obj.dispTrace(tr);
                end
            else
                error("Unrecognized trace %s, should be A to G.",trace)
            end
        end
        function blankTrace(obj,trace)
            if any( strcmpi(trace,["A","B","C","D","E","F","G"] ) ==1 )
                tt = strcat(":TRAC:STAT:TR",upper(trace)," OFF");
                fprintf("OSA: Trace %s is blanked.\n",upper(trace))
                obj.Write(tt)
            elseif strcmpi(trace,"all")
                for tr = ["A","B","C","D","E","F","G"]
                    obj.blankTrace(tr);
                end
            else
                error("Unrecognized trace %s, should be A to G.",trace)
            end
        end
        %% Sweep start stop related
        function Single(obj)
            obj.Write(":INIT:SMOD SING");
            obj.Write(":INIT")
        end
        function Run(obj, trace2Write)
            if nargin == 2
                obj.fixTrace('all');
                obj.writeTrace(trace2Write);
            end
            obj.Write(":INIT:SMOD REP");
            obj.Write(":INIT")
        end
        function Stop(obj)
            obj.Write(":ABOR");
        end
        
        %% wavelength center and span setups
        function set.wlcenter(obj,wlc) % set display wavelength center, in unit of nm
            tt = strcat(":SENS:WAV:CENT ",num2str(wlc),"NM");
            % obj.Write(":DISP:TRAC:X:INIT");
            obj.Write(tt);
        end
        function wl = get.wlcenter(obj)
            wl = str2double(obj.Query(":SENS:WAV:CENT?"))/1e-9; % in unit of nm
        end
        function set.wlspan(obj,wls)
            tt = strcat(":SENS:WAV:SPAN ",num2str(wls),"NM");
            % obj.Write(":DISP:TRAC:X:INIT");
            obj.Write(tt);
        end
        function wl = get.wlspan(obj)
            wl = str2double(obj.Query(":SENS:WAV:SPAN?"))/1e-9; % in unit of nm
        end
        function set.wlstart(obj, wl)
            oldstop = obj.wlcenter + obj.wlspan/2;
            newstart = wl;
            if newstart>=oldstop
                newstop = newstart + 10; % if overtuned, 10nm span by default;
            else
                newstop = oldstop;
            end
            obj.wlcenter = (newstart + newstop)/2;
            obj.wlspan = (newstop - newstart);
        end
        function tt = get.wlstart(obj)
            tt = obj.wlcenter - obj.wlspan/2;
        end
        function set.wlstop(obj,wl)
            oldstart = obj.wlcenter - obj.wlspan/2;
            newstop = wl;
            if newstop <= oldstart
                newstart = newstop - 10;
            else
                newstart = oldstart;
            end
            obj.wlcenter = (newstart + newstop)/2;
            obj.wlspan = (newstop - newstart);
        end
        function tt = get.wlstop(obj)
            tt = obj.wlcenter + obj.wlspan/2;
        end
        function set.wlscale(obj, scale)
            obj.wlspan = obj.NUM_HOR_DIV * scale;            
        end
        function tt = get.wlscale(obj)
            tt = obj.wlspan / obj.NUM_HOR_DIV;            
        end
        %% set and get sensitivity
        function set.sens(obj, sensstr)
            if ~any( strcmpi(sensstr,["NHLD","NAUT","NORM","MID","HIGH1","HIGH2","HIGH3"]) )==1
                error("specified sensitivity %s not recognized. \n Should choose from NHLD|NAUT|NORM|MID|HIGH1|HIGH2|HIGH3.")
            end
            tt = strcat(":SENS:SENS ",upper(sensstr));
            obj.Write( tt );
        end
        function tt = get.sens(obj)
            label = str2double( obj.Query(":SENS:SENS?") );
            switch label
                case 0
                    tt = "NHLD";
                case 1
                    tt = "NAUT";
                case 2
                    tt = "MID";
                case 3
                    tt = "HIGH1";
                case 4
                    tt = "HIGH2";
                case 5
                    tt = "HIGH3";
                case 6
                    tt = "NORM";
            end
        end
        %% vertical reference
        function set.vertunit(obj, vertu)
            if ~any( strcmpi(vertu,["DBM","W","DBM/NM","W/NM"]) )==1
                error("specified vertical unit %s not recognized. \n Should choose from DBM|W|DBM/NM|W/NM.")
            end
            tt = strcat(":DISP:TRAC:Y1:UNIT ",upper(vertu));
            obj.Write(tt);
        end
        function vertu = get.vertunit(obj)
            label = str2double( obj.Query(":DISP:TRAC:Y1:UNIT?") );
            switch label
                case 0
                    vertu = "DBM";
                case 1
                    vertu = "W";
                case 2
                    vertu = "DBM/NM";
                case 3
                    vertu = "W/NM";
            end
        end
        
        function set.reflevel(obj,reflvl)
            if strcmp(obj.vertunit, "DBM") || strcmp(obj.vertunit, "DBM/NM")
                tt = strcat(":DISP:TRAC:Y1:RLEV ",num2str(reflvl),"dbm");
                obj.Write(tt)
            else
                warning("You are setting reference level in LOG scale when displaying in linear scale!");
                obj.reflevel_lin = 10^(reflvl/10);
            end
        end
        function tt = get.reflevel(obj)
            if strcmp(obj.vertunit, "DBM") || strcmp(obj.vertunit, "DBM/NM")
                tt = str2double(obj.Query(":DISP:TRAC:Y1:RLEV?"));
            else
                tt = 10*log10(obj.reflevel_lin);
                % warning("You are setting reference level in LOG scale when displaying in linear scale!");
            end
        end
        function set.refscale(obj,refsca)
            if refsca>10
                warning("max reflevel is 10dBm, the setting might not be valid.")
            end
            if refsca<0
                error("vertical scale must be positive, in unit of dbm/div")
            end
            if strcmp(obj.vertunit, "DBM") || strcmp(obj.vertunit, "DBM/NM")
                tt = strcat(":DISP:TRAC:Y1:PDIV ",num2str(refsca),"DB");
                obj.Write(tt)
            else
                warning("You are setting reference scale in LOG scale when displaying in linear scale!");
            end
        end
        function tt = get.refscale(obj)
            if strcmp(obj.vertunit, "DBM") || strcmp(obj.vertunit, "DBM/NM")
                tt = str2double(obj.Query(":DISP:TRAC:Y1:PDIV?"));
            else
                % warning("You are setting reference level in LOG scale when displaying in linear scale!");
            end
        end
        
        function set.reflevel_lin(obj,reflvl)
            if strcmp(obj.vertunit, "W") || strcmp(obj.vertunit, "W/NM")
                tt = strcat(":DISP:TRAC:Y1:RLEV ",num2str(reflvl),"W");
                obj.Write(tt)
            else
                warning("You are setting reference level in Linear scale when displaying in log scale!");
                obj.reflevel = 10*log10(reflvl);
            end
        end
        function tt = get.reflevel_lin(obj)
            if strcmp(obj.vertunit, "W") || strcmp(obj.vertunit, "W/NM")
                tt = str2double(obj.Query(":DISP:TRAC:Y1:RLEV?"));
                obj.Write(tt)
            else
                warning("You are setting reference level in Linear scale when displaying in log scale!");
                tt = 10^(obj.reflevel/10);
            end
        end

        %%
        function n = GetTraceSamplingPoints(obj,strTraceName)
            n = str2double(query(obj.visaObj,[':TRACe:DATA:SNUMber? TR' strTraceName]));
        end
        
        function wait(obj)
            flag = ~ str2double( obj.Query(":STAT:OPER:EVEN?") ) ;
            count = 0;
            while flag
                flag = ~str2double( obj.Query(":STAT:OPER:EVEN?") );
                if count > 0
                    fprintf("Waiting for OSA finish sweeping. %1.f seconds waited\n",count);
                end
                count = count + 1;
                pause(1)
            end
        end
        
        %%
        function [X,Y] = ReadTrace(obj,strTraceName,bSingle)
            if nargin == 3 && bSingle
                obj.Initiate;
            end
            x=query(obj.visaObj,[':TRACe:X? TR' strTraceName]);
            x=strsplit(x,',');
            X=str2double(x)*1e9; % wavelength in unit of NM.
            y=query(obj.visaObj,[':TRACe:Y? TR' strTraceName]);
            y=strsplit(y,',');
            Y=str2double(y);
            X=X';
            Y=Y';
            if obj.bPointCheck
                PointCheck(obj,strTraceName,length(Y));
            end
        end
        
        function saveTrace(obj,strTraceName,filename)
            filename = char(filename);
            if strcmpi(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
            dir = fileparts(filename);
            if ~isfolder(dir)
                warning('Folder does not exist, new folder created.')
                mkdir(dir)
            end
            
%             obj.Stop;
            [OSAWavelength, OSAPower] = obj.ReadTrace(strTraceName);
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
    %             if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
    %             end
            end
            save(strcat(filename, '.mat') ,'OSAPower','OSAWavelength')
            fprintf('Spectrum Data (channel %s) file saved as %s\n', strTraceName, strcat(filename, '.mat') )
                figure
                plot(OSAWavelength, OSAPower)
                ylim([-120 0])
        end
        
        function saveTrace2OSA(obj,strTraceName,fileName)
            tt = strcat(":MMEMory:STORe:TRACe TR",strTraceName,',CSV,"',fileName,'",EXT');
%             display(tt)
            obj.Write(tt)
        end
        
        
        function Initiate(obj,strCommand)
            % strCommand='SINGLE' (default),"REPEAT','STOP'
            if nargin<2
                strCommand='SINGLE';
            end
            if strcmp(strCommand,'STOP') || strcmp(strCommand,'stop')
                fprintf(obj.visaObj,'ABORt');
            else
                fprintf(obj.visaObj,[':INITIATE:SMODE ' strCommand]);
                fprintf(obj.visaObj,':INITIATE');
            end
        end
        
        
    end
    
    methods (Access=protected)
        function bflag=PointCheck(obj,strTraceName,nFetched)
            % check if fetched trace points == OSA sampling points
            n=GetTraceSamplingPoints(obj,strTraceName);
            if nFetched~=n
                warning('Fetched trace points(%d) are less than OSA sampling points(%d). Try increase InputBufferSize.\n',nFetched,n);
                bflag=false;
            else
                bflag=true;
            end
        end
    end
end