classdef ringdown_trace_fit
% Usage:
% obj=ringdown_trace_fit(time,trace_Q,trace_MZI,MZI_FSR,lambda,threshold)
% where:
%   time is the oscilloscope x-axis
%   trace_Q (N*1 double) is the oscilloscope Q trace;
%   trace_MZI (N*1 double) is the oscilloscope MZI trace;
%   MZI_FSR (double) is the MZI FSR, in MHZ;
%   lambda (double) is the center wavelength, in nm;
%   threshold (optional; double, start from 1.05) is the threshold for peak detection.
% 
% Methods:
% obj.plot_trace_stat returns a figure handle with a plot of Qs marked below each trace peak.
% obj.plot_Q_max returns a figure handle with a fitting plot of the peak with maximum Q.
% 
    properties
        time
        trace_Q
        trace_MZI
        MZI_FSR
        lambda
        threshold
        
        modeQ0
        modeQ1
        modeQL
        modePos
        modeStart
        modeEnd
        modeBaseline
        modeFitQ
        modeFitMZI
    end
    
    properties (Access = private)
        ringdown_fittype = fittype('A*abs(1-(1+1i)/2*sqrt(pi/beta)*kappa1.*erfcxz((1i-1)*((x-x0)*beta-1i*kappa/2)/(2*sqrt(beta)))).^2', ...
            'coefficients', {'A','x0','beta','kappa','kappa1'});
        fit_sine=fittype('A0+A*cos((x-x0)/T*2*pi)','coefficients',{'A0','A','x0','T'});
    end
    
    methods
        function obj=ringdown_trace_fit(time,trace_Q,trace_MZI,MZI_FSR,lambda,threshold) % constructor
            
            if nargin>=6 % determine the threshold for detection; clamped at 0.95 to avoid noise
                threshold=max(threshold,1.05);
            else
                threshold=1.05;
            end
            baseline=median([median(trace_Q) median(trace_Q(1:9)) median(trace_Q(end-8:end))]); % Q baseline estimate
            
            modeQ0=[];
            modeQ1=[];
            modeQL=[];
            modePos=[];
            modeStart=[];
            modeEnd=[];
            modeBaseline = [];
            modeFitQ={};
            modeFitMZI={};
            
            close all;
            trace_Q_trunc=trace_Q;
            dt = (time(2) - time(1))*1e6; % in us
            idxrange = round(2/dt); % pixel/us
            % estimate kappa0
            w = 299792.458/lambda*2*pi; % in MHz
            kappa0 = w/200;
            kappa10 = w/300;
            idxstart = 1;
            idxend = 1;
            while 1 % loop until no ringdown spetra
                trace_Q_trunc(idxstart:idxend) = baseline; % flatten previous part
                %%
                [transmission,rdpos1]= max(trace_Q_trunc); % Extract the highest peak
                if transmission < threshold*baseline % only detect peaks with transmission below threshold, to avoid noise
                    break;
                end
                [~,rdpos2] = min(trace_Q_trunc(rdpos1-idxrange:rdpos1));
                idxstart = rdpos1 + (rdpos2-idxrange) * 7;
                idxend = rdpos1 - (rdpos2-idxrange) * 12;
                if (idxstart - idxrange <= 0 || idxend+idxrange > numel(trace_Q))
                    if (idxstart - idxrange <= 0)
                        idxstart = 1;
                    end
                    if (idxend+idxrange > numel(trace_Q))
                        idxend = numel(trace_Q);
                    end
                    continue;
                end
                %% Local Fitting
                trans_tofit=trace_Q(idxstart:idxend);
                time_tofit=(time(idxstart:idxend) - time(idxstart))*1e6; % in us
                
                % A0
                A0 = median(trace_Q([idxstart-idxrange:idxstart idxend:idxend+idxrange]));
                % t0
                [~,peakpos] = max(trans_tofit);
                [~,dippos] = min(trans_tofit(1:peakpos));
                t0pos = round(dippos*1.5 - peakpos*0.5);
                if t0pos <= 0 || t0pos > numel(time_tofit)
                    continue;
                end
                t0 = time_tofit(t0pos);
                % mzi => beta0 scanning speed
                trace_MZI_tofit=trace_MZI(idxstart:idxend);
                [MZI_peak,MZI_pos]= max(trace_MZI_tofit);
                trace_MZI_phasor=hilbert(trace_MZI_tofit-mean(trace_MZI_tofit)); % use phasor arg to extract period
                MZI_period_local=2*pi/(mean(angle(trace_MZI_phasor(2:end)./trace_MZI_phasor(1:end-1))));
                MZI_baseline=median(trace_MZI_tofit); % MZI baseline estimate
                MZI_fit=fit((idxstart:idxend).', trace_MZI_tofit, obj.fit_sine, ...
                    'StartPoint', [MZI_baseline, MZI_peak - MZI_baseline, idxstart+MZI_pos, MZI_period_local]); % sine fit
                beta0 = MZI_FSR/MZI_fit.T/dt*2*pi;
                ringdown_fit = fit(time_tofit,trans_tofit,obj.ringdown_fittype...
                                ,'StartPoint',[A0,t0,beta0,kappa0,kappa10]...
                                );
                
                QL = w/ringdown_fit.kappa;
                Q1 = w/ringdown_fit.kappa1;
                Q0 = w/(ringdown_fit.kappa - ringdown_fit.kappa1);
                
                modeQ0=[modeQ0;Q0];
                modeQ1=[modeQ1;Q1];
                modeQL=[modeQL;QL];
                modePos=[modePos;ringdown_fit.x0+time(idxstart)*1e6];
                
                modeBaseline = [modeBaseline;ringdown_fit.A];
                modeStart=[modeStart;idxstart];
                modeEnd=[modeEnd;idxend];
                modeFitQ=[modeFitQ;{ringdown_fit}];
                modeFitMZI=[modeFitMZI;{MZI_fit}];
            end
            
            %% construct
            obj.time = time;
            obj.trace_Q = trace_Q;
            obj.trace_MZI = trace_MZI;
            obj.MZI_FSR = MZI_FSR;
            obj.lambda = lambda;
            obj.threshold = threshold;
            
            [~,indexorder]=sort(modeQ0,'descend');
            obj.modeQ0=modeQ0(indexorder);
            obj.modeQ1=modeQ1(indexorder);
            obj.modeQL=modeQL(indexorder);
            obj.modePos=modePos(indexorder);
            obj.modeStart=modeStart(indexorder);
            obj.modeEnd=modeEnd(indexorder);
            obj.modeBaseline = modeBaseline(indexorder);
            obj.modeFitQ=modeFitQ(indexorder);
            obj.modeFitMZI=modeFitMZI(indexorder);
        end
        
        function figure_handle=plot_trace_stat(obj)
            figure_handle=figure;
            hold on;
            xlabel('Time (\mus)');
            ylabel('Trace voltage (V)');
            if (numel(obj.modeFitMZI) == 0)
                return;
            end
            plot(obj.time*1e6,obj.trace_Q);
            text_Q=text(obj.modePos,1.2*obj.modeBaseline,num2str(obj.modeQ0,'%.4g'),...
                'HorizontalAlignment','center');
            set(text_Q(1),'Color','red');
            title('Trace statistics','FontSize',10,'FontWeight','normal');
            hold off;
        end
        
        function figure_handle=plot_Q_max(obj)
            figure_handle=figure;
            hold on;
            xlabel('Time (\mus)');
            ylabel('Normalized outputs');
            if (numel(obj.modeStart) == 0)
                return;
            end
            peakstart=obj.modeStart(1);
            peakend=obj.modeEnd(1);
            Q_fit=obj.modeFitQ{1};
            grid on;
            time_base=(obj.time(peakstart:peakend) - obj.time(peakstart))*1e6;
            scatter(time_base,obj.trace_Q(peakstart:peakend)/Q_fit.A,'.');
            plot(time_base,Q_fit(time_base)/Q_fit.A,'r','LineWidth',1);
            xlim([0 max(time_base)]);
            legend('Transmission','Ringdown fit','Location','best');
            Q0=obj.modeQ0(1);
            Q1=obj.modeQ1(1);
            QL=obj.modeQL(1);
            title(['Q0=',num2str(Q0,'%.4g'),'M, Q1=',num2str(Q1,'%.4g'),'M, Q=',num2str(QL,'%.4g'),'M'],...
                'FontSize',10,'FontWeight','normal');
            hold off;
        end
        
        function Q_matrix=get_Q(obj)
            Q_matrix=[obj.modeQ0,obj.modeQ1,obj.modeQL];
        end
        
        function figure_handle=logfit(obj,num)
            if nargin < 2
                num = 1;
            end
            figure_handle=figure;
            hold on;
            xlabel('Time (\mus)');
            ylabel('Normalized outputs');
            if (num > numel(obj.modeQ0))
                return
            else
                peakstart = obj.modeStart(num);
                peakend = obj.modeEnd(num);
                baseline = obj.modeBaseline(num);
            end
            x = (obj.time(peakstart:peakend) - obj.time(peakstart))*1e9;
            y = obj.trace_Q(peakstart:peakend) - baseline;
            [peak,x0] = findpeaks(y,x,'MinPeakWidth',10); % Todo
            a = polyfit(x0,log(peak),1);
            fy = a(1)*x+a(2);
            plot(x,fy,'r','LineWidth',1.5);
            hold on;
            xlim([0 max(x)])
            plot(x0,log(peak),'o','MarkerSize',7);
            xlabel('Time (ns)');
            ylabel('Amplitude (A.U.)');
            legend('logfit','data');
            hold off
        end
    end
end