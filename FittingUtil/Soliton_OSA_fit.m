% Usage:
% Constructor: obj=Soliton_OSA_fit(X,Y)
% where:
%  X: OSA trace X Data in nm
%  Y: OSA trace Y Data in dBm
%  X can be filename if no Y

% To Fit: obj.fit(Pump,NoiseLevel,FSR)
%  Pump: Pump wavelength in nm, better to be specified
%  NoiseLevel: in dBm
%  FSR: Comb Spacing in GHz, for peakfinding use

% Output
% Property:
%  pulse_width: Soliton Pulse Width in ps
%  Ramanshift: Self-Freqency Shift Omega/2pi in THz
%  centerpeakpower: spectral envelope center power in dBm
% Method:
%  obj.plot: Plot fitting results

classdef Soliton_OSA_fit < handle
    properties
        OSA_X               % Wavelength [nm]
        OSA_Y               % Power [dBm]
        pump_wavelength     % [nm]
        
        sech2_fit           % Fitting results
        sech2_fit_wl_db
        pulse_width         % taos [ps]
        Ramanshift          % Omega/2pi [THz]
        centerpeakpower     % [dBm]
    end
    
    methods
        function obj=Soliton_OSA_fit(X,Y)
            if nargin < 2
                if numel(X) > 4 && strcmpi(X(end-3:end),'.CSV')
                    X = X(1:end-4); % remove extension if exist
                end
                data = csvread([X,'.CSV'],35,0);
                X = data(:,1);
                Y = data(:,2);
            end
            obj.OSA_X = X;
            obj.OSA_Y = Y;
        end
        
        function fit(obj,Pump,NoiseLevel,FSR)
            % Find Peaks
            if nargin < 4
                if nargin < 3
                    NoiseLevel = -55;
                end
                FSR_nm = 0.1;
            else
                FSR_nm = Pump - 1/(1/Pump + FSR/299792457);
            end
            [PKS,LOCS] = findpeaks(obj.OSA_Y,obj.OSA_X,'MinPeakHeight',NoiseLevel,'MinPeakDistance',FSR_nm * 0.9);
            
            % Discard datapoints around pump
            if nargin < 2
                [~,idx] = max(PKS);
            else
                [~,idx] = min(abs(LOCS - Pump));
            end
            Pump = LOCS(idx);
            obj.pump_wavelength = Pump;
            LOCS(idx-1:idx+1) = [];
            PKS(idx-1:idx+1) = [];
            
            % Define fittype
            fit_sech2 = fittype('A + 20 * log10(sech(pi/2 * ts * (x - x0) ))','coefficients',{'A','ts','x0'});
            fit_X = 2*pi*299792.458./LOCS; % [2piTHz]
            fit_Y = PKS;
            
            % Find fitting initial value
            [A0,loc] = max(fit_Y);
            x0 = fit_X(loc);
            ts0 = ((A0 - NoiseLevel)/20 + log10(2))* log(10)*4/pi/(max(fit_X) - min(fit_X));
            
            % Fit!
            obj.sech2_fit = fit(fit_X, fit_Y, fit_sech2, 'StartPoint', [A0,ts0,x0]);
            
            obj.Ramanshift = obj.sech2_fit.x0/2/pi - 299792.458/Pump;
            obj.pulse_width = obj.sech2_fit.ts;
            obj.centerpeakpower = obj.sech2_fit.A;
            
            obj.sech2_fit_wl_db = @(x)obj.sech2_fit(2*pi*299792.458./x);
        end
        
        function figure_handle = plot(obj,XUnit)
            if nargin < 2
                XUnit = 'THz';
            end
            figure_handle=figure;
            hold on;
            Freq = 299792.458./obj.OSA_X;
            Fitted_Y = obj.sech2_fit(2*pi*Freq);
            switch XUnit
                case 'THz'
                    plot(Freq,obj.OSA_Y,'b');
                    plot(Freq,Fitted_Y,'r','LineWidth',2);
                    xlabel('Frequency(THz)');
                    ylabel('Power(dBm)');
                    xlim([min(Freq),max(Freq)]);
                case 'nm'
                    plot(obj.OSA_X,obj.OSA_Y,'b');
                    plot(obj.OSA_X,Fitted_Y,'r','LineWidth',2);
                    xlabel('Wavelength(nm)');
                    ylabel('Power(dBm)');
                    xlim([min(obj.OSA_X),max(obj.OSA_X)]);
            end
            legend('OSA Spectrum','Sech^2 Fit','Location','best');
            ylim([-80 -20]);
            grid on;
            title('Soliton Spectrum Fit','FontSize',12,'FontWeight','normal');
            hold off;
        end
    end
end