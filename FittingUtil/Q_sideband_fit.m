% Class Q_sideband_fit, for fitting Qs using the PM sideband method
% 
% Usage:
% Q_obj=Q_sideband_fit(trace_Q,PM_freq,lambda,threshold)
% where:
%   trace_Q (N*1 double) is the oscilloscope Q trace;
%   PM_freq (double) is the phase modulation frequency, in MHZ;
%   lambda (double) is the center wavelength, in nm;
%   threshold (optional; double, from 0 to 0.995) is the threshold for peak
%     detection. 0 does not detect peaks, and 0.995 is most sensitive.
%     Defaults to 0.
% 
% Methods:
% Q_obj.plot_trace_stat
%   returns a figure handle with a plot of Qs marked below each trace peak.
% Q_obj.plot_Q_max
%   returns a figure handle with a fitting plot of the peak with maximum Q.
% 
classdef Q_sideband_fit
    
    properties
        trace_Q
        PM_freq
        lambda
        threshold
        
        trace_length
        trace_Q_filtered
        px_per_freq
        
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
        modeDesignation
    end
    
    methods
        function Q_obj=Q_sideband_fit(trace_Q,PM_freq,lambda,threshold) % constructor

            if nargin>=4 % determine the threshold for detection; clamped at 0.95 to avoid noise
                threshold=min(threshold,0.995);
            else
                threshold=0.95;
            end
            
            px_per_freq=1;

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
            modeDesignation={};
            
%             close all;
            trace_length=length(trace_Q);
            
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
            
            % Lorentz lineshape, with LS=(kappa_0+kappa_1)/2 and LP=kappa_0*kappa_1, in pixels
            fit_Lorentz=fittype('A*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A','LP','LS','x0'});
            
            while 1 % loop over all peaks
                [transmission,peakpos]=min(trace_Q_trunc); % extract the lowest dip
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
                    'StartPoint', [Q_baseline, (1-transmission)*linewidth^2/4, linewidth/2, 0]); % Lorentz fit
                kappa=2*abs(Q_fit.LS); % LS may be negative due to nonlinear fitting
                kappa0=abs(Q_fit.LS)+sqrt(Q_fit.LS^2-Q_fit.LP);
                Q_baseline=Q_fit.A;
                transmission=Q_fit(Q_fit.x0)/Q_fit.A;
                if transmission<=0 % Apparant negative transmission warning
                    warning('A fitted peak has apparant negative transmission of %.2g. The coupling will be assumed critical, but this will introduce a relative error of %.1g.', ...
                        transmission, sqrt(-transmission));
                    kappa0=kappa/2;
                end
                
                Q_fit_data=Q_fit(peakstart-peakpos:peakend-peakpos);
                Q_fit_A=Q_fit.A;
                
                Q0=299792.458/lambda/kappa0;
                Q1=299792.458/lambda/(kappa-kappa0);
                QL=299792.458/lambda/kappa;
                
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
            end
            
            Q_obj.trace_Q=trace_Q;
            Q_obj.PM_freq=PM_freq;
            Q_obj.lambda=lambda;
            Q_obj.threshold=threshold;
            
            Q_obj.trace_length=trace_length;
            Q_obj.trace_Q_filtered=trace_Q_filtered;
            
            [~,indexorder]=sort(modeTransmission,'ascend');
            
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
            
            if isempty(indexorder)
                warning('No peaks have been found in the trace; subsequent plots, if any, will be suppressed.');
            elseif length(indexorder)<3
                warning('Not enough peaks have been found in the trace; all Q values will be displayed in pixel units.');
            else
                modeDesignation=cell(size(modeQ0));
%                 modeDesignation{1:end}='';
                modeDesignation{1}='Main';
                modeDesignation{end}='Side';
                modeDesignation{end-1}='Side';
                px_per_freq=abs(Q_obj.modePos(end)-Q_obj.modePos(end-1))/2/PM_freq;
            end
            Q_obj.px_per_freq=px_per_freq;
            Q_obj.modeDesignation=modeDesignation;
            Q_obj.modeQ0=Q_obj.modeQ0*px_per_freq;
            Q_obj.modeQ1=Q_obj.modeQ1*px_per_freq;
            Q_obj.modeQL=Q_obj.modeQL*px_per_freq;
        end
        
        function figure_handle=plot_trace_stat(Q_obj)
            figure_handle=figure;
            hold on;
            xlabel('Frequency Estimate (MHz)');
            ylabel('Trace voltage (V)');
            ylim(max(Q_obj.trace_Q)*[-0.1 1.1]);
            title('Trace statistics','FontSize',10,'FontWeight','normal');
            if ~isempty(Q_obj.modeQ0)
                plot((1:Q_obj.trace_length)/Q_obj.px_per_freq,Q_obj.trace_Q);
                text_Q=text([Q_obj.modePos/Q_obj.px_per_freq;Q_obj.modePos/Q_obj.px_per_freq],...
                    [Q_obj.modeBaseline.*(Q_obj.modeTransmission-0.02);Q_obj.modeBaseline.*(Q_obj.modeTransmission-0.07)],...
                    num2str([Q_obj.modeQ0;Q_obj.modeQ1],'%.4g'),...
                    'HorizontalAlignment','center');
                set(text_Q(1),'Color','red');
                text_d=text(Q_obj.modePos/Q_obj.px_per_freq,...
                    Q_obj.modeBaseline.*(Q_obj.modeTransmission-0.12),...
                    Q_obj.modeDesignation,...
                    'HorizontalAlignment','center');
                set(text_d(1),'Color','red');
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
                
                plot_base=peakstart-peakpos:peakend-peakpos;
                xlim([min(plot_base) max(plot_base)]/Q_obj.px_per_freq);
                scatter(plot_base/Q_obj.px_per_freq,Q_obj.trace_Q(peakstart:peakend)/Q_fit_A,'bo');
                plot(plot_base/Q_obj.px_per_freq,Q_fit/Q_fit_A,'r','LineWidth',2);
                legend('Transmission','Lorentzian fit','Location','best');
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