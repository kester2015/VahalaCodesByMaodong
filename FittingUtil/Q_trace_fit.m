% Class Q_trace_fit, for fitting Qs from oscilloscope traces
% 
% Usage:
% Q_obj=Q_trace_fit(trace_Q,trace_MZI,MZI_FSR,lambda,...
%   threshold,corr_type,cutoff_freq)
% where:
%   trace_Q (N*1 double) is the oscilloscope Q trace;
%   trace_MZI (N*1 double) is the oscilloscope MZI trace;
%   MZI_FSR (double) is the MZI FSR, in MHZ;
%   lambda (double) is the center wavelength, in nm;
%   threshold (optional; double, from 0 to 0.995) is the threshold for peak
%     detection. 0 does not detect peaks, and 0.95 is most sensitive.
%     Defaults to 0;
%   corr_type (optional; '' | 'fano' | 'split' | 'osc' | append with 'mzi')
%     instructs the code to correct for non-ideal lineshapes. First four
%     options are no correction, Fano lineshapes, mode splitting, or trying
%     to remove low-frequency sine components from the Q trace background
%     with Fourier transform. Appending any option with 'MZI' also corrects
%     scanning drift with the Hilbert transform. Case-insensitive. Defaults
%     to '';
%   cutoff_freq (optional; int) is the cutoff frequency used in 'osc' and
%     'oscmzi'. Sine components with less than cutoff_freq periods will be
%     removed. If not specified the code attempts to find a frequency by
%     analyzing the Q trace.
% 
% Methods:
% Q_obj.plot_Q_stat
%   returns a figure handle with a plot of Q vs. transmission.
% Q_obj.plot_trace_stat
%   returns a figure handle with a plot of Qs marked below each trace peak.
% Q_obj.plot_Q_max
%   returns a figure handle with a fitting plot of the peak with maximum Q.
% 
classdef Q_trace_fit
    
    properties
        trace_Q
        trace_MZI
        MZI_FSR
        lambda
        threshold
        flag_fano_corr
        flag_split_corr
        flag_osc_corr
        flag_MZI_corr
        cutoff_freq
        
        trace_length
        trace_Q_filtered
        
        modeQ0
        modeQ1
        modeQL
        modePos
        modeStart
        modeEnd
        modeBaseline
        modeTransmission
        modeFitQ
        modeFitQ_A
        modeFitMZI
        modeFitMZI_T
        modeFitMZI_A0
        modeFitMZI_A
    end
    
    methods
        function Q_obj=Q_trace_fit(trace_Q,trace_MZI,MZI_FSR,lambda,threshold,corr_type,cutoff_freq) % constructor

            if nargin>=5 % determine the threshold for detection; clamped at 0.95 to avoid noise
                threshold=min(threshold,0.995);
            else
                threshold=0.95;
            end
            
            if nargin<6 % determine the correction type to be applied
                corr_type='';
            end
            flag_fano_corr=false;
            flag_split_corr=false;
            flag_osc_corr=false;
            flag_MZI_corr=false;
            corr_type=lower(corr_type);
            switch corr_type
                case ''
                case blanks(0)
                    % no correction
                case 'fano'
                    flag_fano_corr=true;
                case 'split'
                    flag_split_corr=true;
                case 'osc'
                    flag_osc_corr=true;
                case 'mzi'
                    flag_MZI_corr=true;
                case 'fanomzi'
                    flag_fano_corr=true;
                    flag_MZI_corr=true;
                case 'splitmzi'
                    flag_split_corr=true;
                    flag_MZI_corr=true;
                case 'oscmzi'
                    flag_osc_corr=true;
                    flag_MZI_corr=true;
%                 case 'splitosc'
%                     flag_osc_corr=true;
%                     flag_split_corr=true;
                case 'all'
                    flag_fano_corr=true;
                    flag_split_corr=true;
                    flag_osc_corr=true;
                    flag_MZI_corr=true;
                otherwise
                    warning('Unknown correction type; no correction will be applied.');
            end
            
            if nargin<7
                cutoff_freq=0;
            end
            
            modeQ0=[];
            modeQ1=[];
            modeQL=[];
            modePos=[];
            modeStart=[];
            modeEnd=[];
            modeBaseline=[];
            modeTransmission=[];
            modeFitQ={};
            modeFitQ_A=[];
            modeFitMZI={};
            modeFitMZI_T=[];
            modeFitMZI_A0=[];
            modeFitMZI_A=[];
            
%             close all;
            trace_length=length(trace_Q);
            
            if ~flag_osc_corr
                trace_Q_baseline=sgolayfilt(trace_Q,1,11); % baseline estimate, using slow-varying envelope
                for index=2:trace_length
                    trace_Q_baseline(index)=max([trace_Q_baseline(index) trace_Q_baseline(index-1)*(1-1/2/trace_length)]);
                end
                for index=trace_length-1:-1:1
                    trace_Q_baseline(index)=max([trace_Q_baseline(index) trace_Q_baseline(index+1)*(1-1/2/trace_length)]);
                end
                trace_Q_filtered=trace_Q;
                trace_Q_trunc=trace_Q./trace_Q_baseline; % filtered trace, used to detect and truncate peaks
                cutoff_pos=round(trace_length/100);
                trace_Q_trunc(1:cutoff_pos)=1+(trace_Q_trunc(1:cutoff_pos)-1).*(1:cutoff_pos).'/cutoff_pos; % soft truncate start & end
                trace_Q_trunc(end-cutoff_pos+1:end)=1+(trace_Q_trunc(end-cutoff_pos+1:end)-1).*(cutoff_pos:-1:1).'/cutoff_pos;
            else
                trace_Q_trunc=trace_Q/mean(trace_Q)-1;
                trace_fft=fft(trace_Q_trunc); % find the freq component via fft
                trace_fft(2:21)=0; % detrend by removing low-freq components
                trace_fft(end-19:end)=0;
                if cutoff_freq==0
                    [~,cutoff_freq]=max(abs(trace_fft(1:round(trace_length/2))));
                    cutoff_freq=round(cutoff_freq*1.5);
                end
                cutoff_freq=min(abs(cutoff_freq),round(trace_length/100)); % set hard limit
                trace_fft(2:cutoff_freq)=0;
                trace_fft(end-cutoff_freq+2:end)=0;
                trace_fft(cutoff_freq+1)=trace_fft(cutoff_freq+1)/2;
                trace_fft(end-cutoff_freq+1)=trace_fft(end-cutoff_freq+1)/2;
                trace_Q_filtered=real(ifft(trace_fft)); 
                trace_Q_trunc=trace_Q_filtered;
                cutoff_pos=round(trace_length/min([2*cutoff_freq,100]));
                trace_Q_trunc(1:cutoff_pos)=trace_Q_trunc(1:cutoff_pos).*(1:cutoff_pos).'/cutoff_pos; % soft truncate start & end
                trace_Q_trunc(end-cutoff_pos+1:end)=trace_Q_trunc(end-cutoff_pos+1:end).*(cutoff_pos:-1:1).'/cutoff_pos;
            end
            
            MZI_baseline=median(trace_MZI); % MZI baseline estimate
            [MZI_peak,MZI_pos]=max(trace_MZI(round(trace_length/4):round(3*trace_length/4))); % MZI amp & period estimate
            MZI_pos=MZI_pos+round(trace_length/4);
            MZI_period=4*find(trace_MZI(MZI_pos:trace_length)<MZI_baseline,1);
            MZI_amp=MZI_peak-MZI_baseline;
            
            % Lorentz lineshape, with LS=(kappa_0+kappa_1)/2 and LP=kappa_0*kappa_1, in pixels
            fit_Lorentz=fittype('A*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A','LP','LS','x0'});
            % Lorentz lineshape, with correction against Fano lineshape caused by multimode tapers
            fit_Lorentz_corr=fittype('A*((x-x0+F0)^2+LS^2-LP)/(LS^2+(x-x0)^2)','coefficients',{'A','LP','LS','x0','F0'});
            % Lorentz lineshape, with mode splitting
            fit_Lorentz_split=fittype('A*(1-(4*kin*((2*LS-kin)*(4*LS^2+4*(x-x0)^2)+8*LS*g2))/((4*LS^2+4*(x-x0)^2-4*g2)^2+64*LS^2*g2))','coefficients',{'A','kin','LS','x0','g2'});
            % Lorentz-Gibbs lineshape, used for fitting signals after high-pass filters
            fit_Lorentz_osc=fittype('AL*LS^2*(cos((x-x0)*f0)-(x-x0)/LS*sin((x-x0)*f0))/(LS^2+(x-x0)^2)','coefficients',{'AL','LS','x0'},'problem',{'f0'});
            % Sine lineshape, with T=period, in pixels
            fit_sine=fittype('A0+A*cos((x-x0)/T*2*pi)','coefficients',{'A0','A','x0','T'});
            
            while 1 % loop over all peaks
                [transmission,peakpos]=min(trace_Q_trunc); % extract the lowest dip
                if ~flag_osc_corr % no 'osc' correction
                    if transmission>threshold % only detect peaks with transmission below threshold, to avoid noise
                        break;
                    end
                    
                    Q_baseline=trace_Q_baseline(peakpos); % local baseline estimate
                    linewidth=2*max([find(trace_Q(peakpos:end)>trace_Q_baseline(peakpos:end)*(1+transmission)/2,1) 3]); % linewidth estimate
                    peak_base_max=trace_Q(peakpos);
                    for peakend=peakpos:min(peakpos+10*linewidth,trace_length)
                        peak_base_max=max([peak_base_max,trace_Q(peakend)]); % use maximum point to the right to check adjacent peaks
                        if trace_Q(peakend)<peak_base_max-(1-threshold)*Q_baseline
                            break;
                        end
                    end
                    peakend=peakend-round(min([find(trace_Q(peakend-1:-1:peakpos)<peak_base_max-(1-threshold)*Q_baseline,1),peakend-peakpos])/2);
                    % backtrack to avoid another peak base
                    peak_base_max=trace_Q(peakpos);
                    for peakstart=peakpos:-1:max(peakpos-10*linewidth,1)
                        peak_base_max=max([peak_base_max,trace_Q(peakstart)]); % use maximum point to the left to check adjacent peaks
                        if trace_Q(peakstart)<peak_base_max-(1-threshold)*Q_baseline
                            break;
                        end
                    end
                    peakstart=peakstart+round(min([find(trace_Q(peakstart+1:peakpos)<peak_base_max-(1-threshold)*Q_baseline,1),peakpos-peakstart])/2);
                    % backtrack to avoid another peak base
                    trace_Q_trunc(peakstart:peakend)=1;
                    
                    trace_Q_tofit=trace_Q(peakstart:peakend);
                    Q_fit=fit((peakstart-peakpos:peakend-peakpos).', trace_Q_tofit, fit_Lorentz, ...
                        'StartPoint', [Q_baseline, (1-transmission)*linewidth^2/4, linewidth/2, 0]); % Lorentz fit, {'A','LP','LS','x0'}
                    kappa=2*abs(Q_fit.LS); % LS may be negative due to nonlinear fitting
                    kappa0=abs(Q_fit.LS)+sqrt(Q_fit.LS^2-Q_fit.LP);
                    Q_baseline=Q_fit.A;
                    transmission=Q_fit(Q_fit.x0)/Q_fit.A;
                    if ~flag_split_corr
                        if flag_fano_corr
                            Q_fit=fit((peakstart-peakpos:peakend-peakpos).', trace_Q_tofit, fit_Lorentz_corr, ...
                                'StartPoint', [Q_fit.A, Q_fit.LP, abs(Q_fit.LS), Q_fit.x0, 0]); % Fano fit, {'A','LP','LS','x0','F0'}
                            kappa=2*abs(Q_fit.LS);
                            kappa0=abs(Q_fit.LS)+sqrt(Q_fit.LS^2-Q_fit.LP);
                            Q_baseline=Q_fit.A;
                            transmission=Q_fit(Q_fit.x0-Q_fit.F0*Q_fit.LS^2/Q_fit.LP)/Q_fit.A;
                        end
                    else
                        peakend=min(peakpos+10*linewidth,trace_length);
                        peakstart=max(peakpos-10*linewidth,1);
                        trace_Q_trunc(peakstart:peakend)=1;
                        trace_Q_tofit=trace_Q(peakstart:peakend);
                        peakrange=find(trace_Q_tofit<trace_Q_baseline(peakstart:peakend)*(1+transmission)/2);
                        g2estimate=max([(max(peakrange)-min(peakrange))^2/4-linewidth^2,0]);
                        peakdirection=sign(max(peakrange)+min(peakrange)-length(trace_Q_tofit));
                        Q_fit=fit((peakstart-peakpos:peakend-peakpos).', trace_Q_tofit, fit_Lorentz_split, ...
                            'StartPoint', [Q_fit.A, kappa-kappa0, abs(Q_fit.LS), Q_fit.x0+peakdirection*sqrt(g2estimate), g2estimate]); % split fit, {'A','kin','LS','x0','g2'}
                        kappa=2*abs(Q_fit.LS);
                        kappa0=2*abs(Q_fit.LS)-Q_fit.kin;
                    end
                    if transmission<=0 % Apparant negative transmission warning
                        warning('A fitted peak has apparant negative transmission of %.2g. The coupling will be assumed critical, but this will introduce a relative error of %.1g.', ...
                            transmission, sqrt(-transmission));
                        kappa0=kappa/2;
                    end
                    
                else % 'osc' correction
                    if transmission>-4/threshold*sqrt(mean(trace_Q_filtered(trace_Q_filtered>0).^2))
                        break;
                    end
                    linewidth=2*max([find(trace_Q_filtered(peakpos:end)>transmission/2,1) 3]); % linewidth estimate
                    peakend=min(peakpos+max(5*linewidth,round(trace_length/cutoff_freq/5)),trace_length);
                    peakstart=max(peakpos-max(5*linewidth,round(trace_length/cutoff_freq/5)),1);
                    trace_Q_trunc(peakstart:peakend)=0;
                    
                    trace_Q_tofit=trace_Q_filtered(peakstart:peakend);
                    Q_fit=fit((peakstart-peakpos:peakend-peakpos).', trace_Q_tofit, fit_Lorentz_osc, ...
                        'StartPoint', [transmission, linewidth/2, 0], 'problem', 2*pi/trace_length*cutoff_freq); % Lorentz-Gibbs fit
                    Q_baseline=max(trace_Q(peakstart:peakend));
                    transmission=1+mean(trace_Q)*Q_fit.AL*exp(2*pi/trace_length*cutoff_freq*Q_fit.LS)/Q_baseline;
                    trace_Q_tofit=trace_Q(peakstart:peakend);
                    Q_fit=fit((peakstart-peakpos:peakend-peakpos).', trace_Q_tofit, fit_Lorentz, ...
                        'StartPoint', [Q_baseline, (1-transmission)*Q_fit.LS^2, Q_fit.LS, Q_fit.x0]); % use original data with start points from filtereed data
                    kappa=2*abs(Q_fit.LS); % LS may be negative due to nonlinear fitting
                    kappa0=abs(Q_fit.LS)+sqrt(Q_fit.LS^2-Q_fit.LP);
                    Q_baseline=Q_fit.A;
                    transmission=Q_fit(Q_fit.x0)/Q_fit.A;
                    if transmission<=0 % Apparant negative transmission warning
                        warning('A fitted peak has apparant negative transmission of %.2g. The coupling will be assumed critical, but this will introduce a relative error of %.1g.', ...
                            transmission, sqrt(-transmission));
                        kappa0=kappa/2;
                    end
                end
                Q_fit_data=Q_fit(peakstart-peakpos:peakend-peakpos);
                Q_fit_A=Q_fit.A;
                
                MZI_period_local=MZI_period;
                MZIstart=max([peakpos-10*MZI_period_local,1]); % MZI start and end points
                MZIend=min([peakpos+10*MZI_period_local,trace_length]);
                trace_MZI_tofit=trace_MZI(MZIstart:MZIend);
                trace_MZI_phasor=hilbert(trace_MZI_tofit-mean(trace_MZI_tofit)); % use phasor arg to extract period
                trace_MZI_phasor=trace_MZI_phasor(round(length(trace_MZI_phasor)/4):round(3*length(trace_MZI_phasor)/4)); % drop start & end
                MZI_period_local=round(2*pi/(mean(angle(trace_MZI_phasor(2:end)./trace_MZI_phasor(1:end-1)))));
                
                if ~flag_MZI_corr
                    MZIstart=max([peakpos-2*MZI_period_local,1]); % Re-estimate MZI start and end points
                    MZIend=min([peakpos+2*MZI_period_local,trace_length]);
                    trace_MZI_tofit=trace_MZI(MZIstart:MZIend);
                    trace_MZI_phasor=hilbert(trace_MZI_tofit-mean(trace_MZI_tofit)); % use phasor arg to extract period
                    trace_MZI_phasor=trace_MZI_phasor(round(length(trace_MZI_phasor)/4):round(3*length(trace_MZI_phasor)/4)); % drop start & end
                    MZI_period_local=2*pi/(mean(angle(trace_MZI_phasor(2:end)./trace_MZI_phasor(1:end-1))));
                    [~,MZI_pos]=max(trace_MZI_tofit);
                    
                    MZI_fit=fit((MZIstart-peakpos:MZIend-peakpos).', trace_MZI_tofit, fit_sine, ...
                        'StartPoint', [MZI_baseline, MZI_amp, MZIstart-peakpos+MZI_pos, MZI_period_local]); % sine fit
                    MZI_fit_data=MZI_fit(peakstart-peakpos:peakend-peakpos);
                    MZI_fit_T=MZI_fit.T;
                    MZI_fit_A0=MZI_fit.A0;
                    MZI_fit_A=MZI_fit.A;
                else
                    MZIstart=min([max([peakpos-2*MZI_period_local,1]),peakstart]); % Must include peakstart / peakend
                    MZIend=max([min([peakpos+2*MZI_period_local,trace_length]),peakend]);
                    trace_MZI_tofit=trace_MZI(MZIstart:MZIend);
                    trace_MZI_phasor=hilbert(trace_MZI_tofit-mean(trace_MZI_tofit)); % use phasor for non-parametric fit
                    trace_MZI_phase=[0;cumsum(mod(diff(angle(trace_MZI_phasor))+pi,2*pi)-pi)]+angle(trace_MZI_phasor(1));
                    trace_MZI_phase=sgolayfilt(trace_MZI_phase,1,11);
                    trace_MZI_phase=sgolayfilt(trace_MZI_phase,2,round((MZIend-MZIstart)/40)*2+1);
                    trace_MZI_amp=sgolayfilt(abs(trace_MZI_phasor),1,11);
                    trace_MZI_amp=sgolayfilt(trace_MZI_amp,2,round((MZIend-MZIstart)/40)*2+1);
                    trace_MZI_phasor=trace_MZI_amp.*exp(1i*trace_MZI_phase);
                    
                    MZI_fit_data=mean(trace_MZI_tofit)+real(trace_MZI_phasor((peakstart-MZIstart+1):(end-MZIend+peakend)));
                    trace_MZI_peakpos=peakpos-MZIstart+1;
                    MZI_fit_T=4*pi*round(MZI_period_local/4)/(trace_MZI_phase(trace_MZI_peakpos+round(MZI_period_local/4))-trace_MZI_phase(trace_MZI_peakpos-round(MZI_period_local/4)));
                    MZI_fit_A0=mean(trace_MZI_tofit);
                    MZI_fit_A=mean(abs(trace_MZI_phasor));
                end
                
                Q0=299792.458/lambda/(kappa0/MZI_fit_T*MZI_FSR);
                Q1=299792.458/lambda/((kappa-kappa0)/MZI_fit_T*MZI_FSR);
                QL=299792.458/lambda/(kappa/MZI_fit_T*MZI_FSR);
                
                modeQ0=[modeQ0;Q0];
                modeQ1=[modeQ1;Q1];
                modeQL=[modeQL;QL];
                modePos=[modePos;peakpos];
                modeStart=[modeStart;peakstart];
                modeEnd=[modeEnd;peakend];
                modeBaseline=[modeBaseline;Q_baseline];
                modeTransmission=[modeTransmission;transmission];
                modeFitQ=[modeFitQ;{Q_fit_data}];
                modeFitQ_A=[modeFitQ_A;Q_fit_A];
                modeFitMZI=[modeFitMZI;{MZI_fit_data}];
                modeFitMZI_T=[modeFitMZI_T;MZI_fit_T];
                modeFitMZI_A0=[modeFitMZI_A0;MZI_fit_A0];
                modeFitMZI_A=[modeFitMZI_A;MZI_fit_A];
            end
            
            Q_obj.trace_Q=trace_Q;
            Q_obj.trace_MZI=trace_MZI;
            Q_obj.MZI_FSR=MZI_FSR;
            Q_obj.lambda=lambda;
            Q_obj.threshold=threshold;
            Q_obj.flag_fano_corr=flag_fano_corr;
            Q_obj.flag_split_corr=flag_split_corr;
            Q_obj.flag_osc_corr=flag_osc_corr;
            Q_obj.flag_MZI_corr=flag_MZI_corr;
            Q_obj.cutoff_freq=cutoff_freq;
            
            
            Q_obj.trace_length=trace_length;
            Q_obj.trace_Q_filtered=trace_Q_filtered;
            
            [~,indexorder]=sort(modeQ0,'descend');
            
            Q_obj.modeQ0=modeQ0(indexorder);
            Q_obj.modeQ1=modeQ1(indexorder);
            Q_obj.modeQL=modeQL(indexorder);
            Q_obj.modePos=modePos(indexorder);
            Q_obj.modeStart=modeStart(indexorder);
            Q_obj.modeEnd=modeEnd(indexorder);
            Q_obj.modeBaseline=modeBaseline(indexorder);
            Q_obj.modeTransmission=modeTransmission(indexorder);
            Q_obj.modeFitQ=modeFitQ(indexorder);
            Q_obj.modeFitQ_A=modeFitQ_A(indexorder);
            Q_obj.modeFitMZI=modeFitMZI(indexorder);
            Q_obj.modeFitMZI_T=modeFitMZI_T(indexorder);
            Q_obj.modeFitMZI_A0=modeFitMZI_A0(indexorder);
            Q_obj.modeFitMZI_A=modeFitMZI_A(indexorder);
            
            if isempty(indexorder)
                warning('No peaks have been found in the trace; subsequent plots, if any, will be suppressed.');
            end
        end
        
        function figure_handle=plot_Q_stat(Q_obj)
            figure_handle=figure;
            hold on;
            xlabel('Q (Intrinsic) (M)');
            ylabel('Transmission');
            grid on;
            title('Q statistics','FontSize',10,'FontWeight','normal');
            ylim([-0.15,1.05]);
            if ~isempty(Q_obj.modeQ0)
                scatter(Q_obj.modeQ0,Q_obj.modeTransmission,'filled');
            end
            hold off;
        end
        
        function figure_handle=plot_trace_stat(Q_obj)
            figure_handle=figure;
            hold on;
            xlabel('Frequency Estimate (MHz)');
            ylabel('Trace voltage (V)');
            ylim(max(Q_obj.trace_Q)*[-0.1 1.1]);
            title('Trace statistics','FontSize',10,'FontWeight','normal');
            if ~isempty(Q_obj.modeQ0)
                plot((1:Q_obj.trace_length)/Q_obj.modeFitMZI_T(1)*Q_obj.MZI_FSR,Q_obj.trace_Q);
                text_Q=text([Q_obj.modePos/Q_obj.modeFitMZI_T(1)*Q_obj.MZI_FSR;Q_obj.modePos/Q_obj.modeFitMZI_T(1)*Q_obj.MZI_FSR],...
                    [Q_obj.modeBaseline.*(Q_obj.modeTransmission-0.02);Q_obj.modeBaseline.*(Q_obj.modeTransmission-0.07)],...
                    num2str([Q_obj.modeQ0;Q_obj.modeQ1],'%.4g'),...
                    'HorizontalAlignment','center');
                set(text_Q(1),'Color','red');
            end
            hold off;
        end
        
        function figure_handle=plot_Q_max(Q_obj)
            figure_handle=plot_Q(Q_obj,1);
        end
        
        function figure_handle=plot_Q(Q_obj,n)
            figure_handle=figure;
            hold on;
            xlabel('Frequency (MHz)');
            ylabel('Normalized outputs');
            grid on;
            if n<=length(Q_obj.modeQ0)
                peakstart=Q_obj.modeStart(n);
                peakend=Q_obj.modeEnd(n);
                peakpos=Q_obj.modePos(n);
                Q_fit=Q_obj.modeFitQ{n};
                Q_fit_A=Q_obj.modeFitQ_A(n);
                MZI_fit=Q_obj.modeFitMZI{n};
                MZI_fit_T=Q_obj.modeFitMZI_T(n);
                MZI_fit_A0=Q_obj.modeFitMZI_A0(n);
                MZI_fit_A=Q_obj.modeFitMZI_A(n);
                
                plot_base=peakstart-peakpos:peakend-peakpos;
                xlim([min(plot_base) max(plot_base)]/MZI_fit_T*Q_obj.MZI_FSR);
                scatter(plot_base/MZI_fit_T*Q_obj.MZI_FSR,(Q_obj.trace_MZI(peakstart:peakend)-MZI_fit_A0)/MZI_fit_A*0.2,'ko');
                plot(plot_base/MZI_fit_T*Q_obj.MZI_FSR,(MZI_fit-MZI_fit_A0)/MZI_fit_A*0.2,'c','LineWidth',2);
                scatter(plot_base/MZI_fit_T*Q_obj.MZI_FSR,Q_obj.trace_Q(peakstart:peakend)/Q_fit_A,'bo');
                plot(plot_base/MZI_fit_T*Q_obj.MZI_FSR,Q_fit/Q_fit_A,'r','LineWidth',2);
                legend('MZI interferogram','Sinusoidal fit','Transmission','Lorentzian fit','Location','best');
                Q0=Q_obj.modeQ0(n);
                Q1=Q_obj.modeQ1(n);
                QL=Q_obj.modeQL(n);
                transmission=Q_obj.modeTransmission(n);
                title(['Q0=',num2str(Q0,'%.4g'),'M, Q1=',num2str(Q1,'%.4g'),'M, Q=',num2str(QL,'%.4g'),'M, Transmission=',num2str(transmission,'%.4g')],...
                    'FontSize',10,'FontWeight','normal');
            end
            hold off;
        end
        
        function Q_matrix=get_Q(Q_obj)
            Q_matrix=[Q_obj.modeQ0,Q_obj.modeQ1,Q_obj.modeQL];
        end
        
        function T_matrix=get_transmission(Q_obj)
            T_matrix=Q_obj.modeTransmission;
        end
        
        function P_matrix=get_pos(Q_obj)
            P_matrix=[Q_obj.modePos,Q_obj.modeStart,Q_obj.modeEnd];
        end
    end
    
end