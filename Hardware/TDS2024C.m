classdef TDS2024C < handle
    properties
        visaObj;
        visaResourceString;
        InputBufferSize=1.5e7;
    end
    
    methods
        function obj = TDS2024C(visaAddress)
            if nargin > 0
                obj.visaResourceString = visaAddress;
            else
                obj.visaResourceString = 'USB0::0x0699::0x03A6::C031910::INSTR';
            end
            % obj.visaObj = visa('agilent',obj.visaResourceString);
            obj.visaObj = visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout = 30;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('TDS2024C OSCilloscope connected');
        end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('TDS2024C OSCilloscope disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(Obj,command)
            fprintf(Obj.visaObj, command);
        end
        
        function data = Query(Obj,command)
            data = query(Obj.visaObj,command);
        end
    end
    
    methods
        function wvfm = ReadTrace(obj, trace)
            % trace = 1|2|3|4
            obj.Write(strcat("DAT:SOU CH", num2str(trace))); % select trace
            % obj.Write('DAT:ENC RIBinary');
            % obj.Write('WFMPre:BN_Fmt RI')
            obj.Write('DAT:ENC ASCI');
            obj.Write('WFMPre:PT_Fmt Y')
            obj.Write('DAT:WID 2'); % bytes per point, nbits = 8*nbytes
            obj.Write('DAT:STAR 1');
            obj.Write('DAT:STOP 2500');
            
            wvfm.preamble = obj.Query('WFMP?');
            wvfm.curve = obj.Query('CURV?');
            
            pream = strsplit(wvfm.preamble,';');
            wvfm.BYT_Nr = str2double(pream(1)); % bytes per point
            wvfm.BIT_Nr = str2double(pream(2)); % bits per point, = BYT_Nr*8
            wvfm.ENCd = pream(3); %ASC|BIN
            wvfm.BN_Fmt = pream(4); %RI|RP
            wvfm.BYT_Or = pream(5); % LSB|MSB
            wvfm.NR_Pt = str2double(pream(6)); % num of points, 2500
            wvfm.WFID = pream(7);
            wvfm.PT_FMT = pream(8); % ENV|Y
            wvfm.XINcr =  str2double(pream(9)); % X increment
            wvfm.PT_Off = str2double(pream(10));
            wvfm.XZEro = str2double(pream(11));
            wvfm.XUNit = pream(12);
            wvfm.YMUlt = str2double(pream(13));
            wvfm.YZEro = str2double(pream(14));
            wvfm.YOFF = str2double(pream(15));
            wvfm.YUNit = pream(16);
            
            Y = strsplit(wvfm.curve, ',');
            Y = str2double(Y)';
            wvfm.Y = wvfm.YZEro + wvfm.YMUlt*(Y - wvfm.YOFF);
            wvfm.X = wvfm.XZEro + wvfm.XINcr*((0:(wvfm.NR_Pt-1))' - wvfm.PT_Off);
        end
        
        function wvfm = saveTrace(obj,trace,filename)
            filename = char(filename);
            if strcmpi(filename(end-3:end), '.mat')
                filename = filename(1:end-4);
            end
            [dir,~,~] = fileparts(filename);
            if ~isfolder(dir)
                warning('Folder does not exist, new folder created.')
                mkdir(dir)
            end
            
            wvfm = obj.ReadTrace(trace);
            X = wvfm.X;
            Y = wvfm.Y;
            if exist([filename,'.mat'],'file')
                warning('File already exists!')
                % if ~overwrite
                    movefile([filename,'.mat'],[filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat']);
                    warning('Old file was renamed!')
                % end
            end
            
            save(strcat(filename, '.mat') ,'wvfm','X','Y')
            fprintf('OSCilloscope Data (channel %.0f) file saved as %s\n', trace, strcat(filename, '.mat') )
                figure
                plot(X, Y)
                title( sprintf('OSC Data (CH %.0f) \n saved name: %s', trace, filename((length(fileparts(filename))+2):end) ),'interpreter', 'none')
        end
        
    end
    
    methods(Static)
        function [electrical_pulse_width,electrical_pulse_width_error] = get_autocorr_FWHM(X,Y)
            EOM_rep_rate = 17.5e9;
            fprintf('Two peak distance is given as %.2f GHz. Used for time scaling calibration. Please make sure this is correct.\n',EOM_rep_rate/1e9);
            
            pulse_time = X;
            pulse_shape = Y;
            fit_range = 100; % in numbers.

            fit_Lorentz = fittype('A/((x-x0)^2+dx^2)','coefficients',{'A','x0','dx'});

            % pulse_diff = diff(pulse_shape);
            % peak_pos = find(pulse_diff(1:end-1)>0 & pulse_diff(2:end)<0 )+1;
            % peak_pos = peak_pos(pulse_shape(peak_pos)>max(pulse_shape)*0.85);

            [~,peak_pos] = findpeaks(pulse_shape, 'MinPeakProminence',0.05, 'MinPeakHeight', max(pulse_shape)*0.6);

            % fit_pos_center = round( median(peak_pos) );

            [~,tt] = min(abs(peak_pos - length(pulse_shape)/2));
            fit_pos_center = peak_pos(tt);

            fit_pos = (fit_pos_center-fit_range):(fit_pos_center+fit_range);
            pulse_max = pulse_shape(fit_pos_center);
            dx_estimate = [find(pulse_shape(fit_pos) > pulse_max/2, 1 ), ...
                                             find(pulse_shape(fit_pos) > pulse_max/2, 1, 'last' )];
            dx_estimate = fit_pos(dx_estimate);
            dx_estimate = abs(diff(pulse_time(dx_estimate)));

            fit_obj = fit(pulse_time(fit_pos),pulse_shape(fit_pos),fit_Lorentz,...
                'StartPoint',[pulse_max*dx_estimate^2, pulse_time(fit_pos_center),dx_estimate]);
            fit_result = fit_obj(pulse_time);



            rep_time = abs( max(pulse_time(peak_pos))-min(pulse_time(peak_pos)) ) /2;
            ratio = fit_obj.dx/rep_time;

            %% Finally, 
            
            electrical_pulse_width = ratio / EOM_rep_rate; % electrical width
            
            fit_error = confint(fit_obj,0.95);
            fit_error_dx = abs(diff(fit_error(:,3)))/2; % one sided error
            electrical_pulse_width_error = fit_error_dx/rep_time/EOM_rep_rate;
            fprintf('Fitted Optical pulse width %.4f +/- %.4f (ps).\n',electrical_pulse_width*1e12, electrical_pulse_width_error*1e12)
            
            figure;
            hold on
            plot(pulse_time, pulse_shape);
            plot(pulse_time,fit_result);
            % xline(max(pulse_time(peak_pos)));
            % xline(min(pulse_time(peak_pos)));
            title(strcat('Input EOM pulse, electrical pulse width = ', num2str(electrical_pulse_width*1e12), 'ps') )


            figure;
            plot(14 + pulse_time/rep_time/EOM_rep_rate/1e-12, pulse_shape);
            hold on
            plot(14 + pulse_time/rep_time/EOM_rep_rate/1e-12,fit_result);
            xlabel('Time (ps)')

            title(strcat('Input EOM pulse, electrical pulse width = ', num2str(electrical_pulse_width*1e12), 'ps') )
            end
    end
end