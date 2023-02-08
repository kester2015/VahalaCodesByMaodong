classdef RSfsupPNA < handle
    % Maodong, version 0, 03012022
    % command example:
    % pna = RSfsupPNA('GPIB0::1:INSTR') % use your address
    % pna.connect
    % pna.RESET
    % pna.mode = 'SAN' (or 'PNO') % spectrum or phase noise
    % pna.mode = 'PNO' (will default be 'PhaseLockedLoop')
    % % pna.setPNOMeas = 'PNPLL' % (default, not necessary. If need baseline, use pna.setPNOMeas = 'BAS')
    % pna.RBW = 1e6 % only works in SAN mode
    % pna.nPoints(625) % default is 625 points
    % pna.Single
    % pna.readtrace
    % pna.saveTrace(file name)
    
    properties
        visaObj;
        visaResourceString;
        InputBufferSize=1.5e7;
    end
        
    properties (Dependent = true)
        RBW % resolution bandwidth
        mode % SAN: spectrun analyzer, PNO: phase noise measurement, ADEM: FM demodulator
    end
    
    methods
        function obj = RSfsupPNA(visaAddress)
            if nargin > 0
                obj.visaResourceString = visaAddress;
            else
                obj.visaResourceString = 'GPIB0::21::INSTR';
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
            disp('R&S FSUP PNA connected');
            Obj.Write("SYST:DISP:UPD ON")
        end   
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('R&S FSUP PNA disconnected');
            end
            fclose(Obj.visaObj);
        end
        function RESET(obj)
            obj.Write("*RST")
        end
        function WAIT(obj)
            obj.Write("*WAI")
        end
        function Write(Obj,command)
            fprintf(Obj.visaObj, command);
        end
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
    end
    
    methods
        function set.RBW(obj, rbw) % in Hz
            if ~strcmpi(obj.mode, 'SAN')
                warning(strcat("Ignored RBW setting. RBW setting only valid for SAN mode, now ", obj.mode, " mode."))
            end
            cmd = strcat("BAND ", num2str(rbw),"HZ");
            obj.Write(cmd)
        end
        function rbw = get.RBW(obj)
            if ~strcmpi(obj.mode, 'SAN')
                rbw = nan;
                return
            end
            cmd = "BAND?";
            rbw = str2double(obj.Query(cmd));
        end
        function m = get.mode(obj)
            % SAN: spectrun analyzer, PNO: phase noise measurement, ADEM: FM demodulator
            m = obj.Query("INST?");
            m = m(1:end-1);
        end
        function set.mode(obj, mode)
            if strcmpi(mode, 'SAN') % spectrum analyzer
                cmd = "INST SAN";
            elseif strcmpi(mode, 'PNO') % Phase noise analyzer
                cmd = "INST PNO; CONF:PNO:MEAS PLL"; % Default choose PhaseLockedLoop mode. Change by obj.setPNOMeas
            elseif strcmpi(mode, 'ADEM') % FM demodulator
                cmd = "INST ADEM";
            else
                error(strcat("PNA mode should chhose from 'SAN'|'PNO'|'ADEM', '", mode, "' is given."))
            end
            obj.Write(cmd)
        end
        function fstart = freqStart(obj, freq)
            if nargin == 1
                fstart = str2double(obj.Query("SENS:FREQ:START?"));
                return
            end
            cmd = strcat("SENS:FREQ:START ", num2str(freq));
            obj.Write(cmd)
            fstart = str2double(obj.Query("SENS:FREQ:START?"));
        end
        function fstop = freqStop(obj, freq)
            if nargin == 1
                fstop = str2double(obj.Query("SENS:FREQ:STOP?"));
                return
            end
            cmd = strcat("SENS:FREQ:STOP ", num2str(freq));
            obj.Write(cmd)
            fstop = str2double(obj.Query("SENS:FREQ:STOP?"));
        end
        function fspan = freqSpan(obj, freq)
            if nargin == 1
                fspan = str2double(obj.Query("SENS:FREQ:SPAN?"));
                return
            end
            cmd = strcat("SENS:FREQ:SPAN ", num2str(freq));
            obj.Write(cmd)
            fspan = str2double(obj.Query("SENS:FREQ:SPAN?"));
        end
        function fcenter = freqCenter(obj, freq)
            if nargin == 1
                fcenter = str2double(obj.Query("SENS:FREQ:CENTER?"));
                return
            end
            cmd = strcat("SENS:FREQ:CENTER ", num2str(freq));
            obj.Write(cmd)
            fcenter = str2double(obj.Query("SENS:FREQ:CENTER?"));
        end
    end
    methods
        function bwFilter(obj, filter)
            if nargin == 1
                filter = 'FFT';
            end
            fprintf("PNA Bandwidth filter set to %s\n", filter);
            cmd = strcat("LIST:BWID:TYPE ", upper(filter));
            obj.Write(cmd)
        end
        function Single(obj)
            swt = str2double(obj.Query("SWE:TIME?"));
            fprintf("PNA Single sweep init, finishing in %.2f seconds.\n",swt);
            if strcmpi(obj.mode, 'SAN')
                obj.Write("INIT:CONT OFF")
                obj.Write("INIT;*WAI")
            else %if strcmpi(obj.mode, 'PNO')
                obj.Write("INIT:CONT OFF")
                obj.Write("INIT;*WAI")
            end
        end
        function Run(obj)
            obj.Write("INIT:CONT ON")
            obj.Write("INIT")
        end
        function Stop(obj)
            obj.Write("INIT:CONT OFF")
        end
    end
    methods
        function setPNOMeas(obj, meas) % choose from 'BAS'|'AM'|'PNPLL'|...to be added
            if ~strcmpi(obj.mode, 'PNO')
                warning(strcat("setPNOMeas called while not in PNO mode, changing to PNO mode. PNOMeas setting to '",meas,"'."))
                obj.mode = 'PNO';
            end
            if strcmpi(meas, 'BAS') % Base band measurement
                cmd = "CONF:PNO:MEAS BAS";
            elseif strcmpi(meas, 'AM') % AM noise measurement
                cmd = "CONF:ANO:MEAS ON";
            elseif strcmpi(meas, 'PNPLL') % PN Noise -> Phase locked loop
                cmd = "CONF:PNO:MEAS PLL";
            else
                error(strcat("PNA PNOMeas should choose from 'BAS'|'AM'|'PNPLL', '",meas,"' is given."))
            end
            obj.Write(cmd)
        end
        
        function npoints = nPoints(obj, points)
            if nargin == 1
                npoints = str2double(obj.Query("SWE:POIN?"));
                return
            end
            cmd = strcat("SWE:POIN ", num2str(points));
            obj.Write(cmd)
            npoints = str2double(obj.Query("SWE:POIN?"));
        end
                
        function trace = readTrace(obj, chan)
            if nargin == 1
                chan = 1;
            end
            obj.Write("FORM ASC")
            % obj.Write("FORM:DEXP:DSEP COMMA")
            response = obj.Query(strcat("TRAC? TRACE", num2str(chan)));
            if strcmpi(obj.mode, 'SAN')
                trace.YData = str2double(strsplit(response, ','))';
                trace.XStart = obj.freqStart;
                trace.XStop = obj.freqStop;
                trace.XData = linspace(trace.XStart, trace.XStop, length(trace.YData))';
                trace.meas = 'Spectrum';
                trace.RBW = obj.RBW;
            elseif strcmpi(obj.mode, 'PNO')
                data = str2double(strsplit(response, ','));
                trace.XData = data(1:2:end)';
                trace.YData = data(2:2:end)';
                meas = obj.Query("CONF:PNO:MEAS?");
                trace.meas = meas(1:end-1);
                if strcmpi(trace.meas,'PLL') || strcmpi(trace.meas, 'CCOR')%trace.meas == 'PLL'
                    trace.signalPower_dbm = str2double(obj.Query("POW:RLEV?"));
                    trace.signalFreq = obj.freqCenter;
                end
            else
                error(strcat("readTrace not realized for mode '", obj.mode, "' yet."))
            end
            figure
            plot(trace.XData, trace.YData, 'DisplayName', strcat("Trace ",num2str(chan)))
            if strcmpi(obj.mode, 'SAN')
                xlabel('Frequency (Hz)')
                ylabel('Power (dBm)')
            elseif strcmpi(obj.mode, 'PNO')
                xlabel('Frequency (Hz)')
                ylabel('Power (dBm)')
                set(gca, 'xscale', 'log')
            end
            legend('location','best')
            title(trace.meas)
        end
        function pnaTrace = saveTrace(obj,chan,filename)
            if nargin == 2
                filename = chan;
                chan = 1;
            end
            filename = char(filename);
            if strcmpi(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
            dir = fileparts(filename);
            if ~isfolder(dir) && ~(isempty(dir))
                warning('Folder does not exist, new folder created.')
                mkdir(dir)
            end
            pnaTrace = obj.readTrace(chan);
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
                % if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
                % end
            end
            save(strcat(filename, '.mat') ,'pnaTrace')
            fprintf('PNA Data (channel %s) file saved as %s\n', num2str(chan), strcat(filename, '.mat') )
        end
    end
    

end