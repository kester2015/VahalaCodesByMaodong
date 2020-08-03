close all
clear
clc
MZI_FSR = 39.9553;
lambda = 1548;
load('Z:\Maodong\Tantala\20200723-thermal-rawdata\1548nm-1-mat\Sweep_20Hz_Power_0.01V.mat')

%% define data set to fit
Q_trace = Ch2;
MZI_trace = Ch3;
%%--You may use the following code to do sampling if original dataset is too large
% if length(timeAxis) > 1e3
%     timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
%     MZI_trace= Ch3(1:round(length(Ch3)/1e4):end);
%     Q_trace = Ch2(1:round(length(Ch2)/1e4):end);
% end
%% Fit models defination
% Lorentz-Gibbs lineshape, used for fitting signals after high-pass filters
% fit_Lorentz_osc=fittype('AL*LS^2*(cos((x-x0)*f0)-(x-x0)/LS*sin((x-x0)*f0))/(LS^2+(x-x0)^2)','coefficients',{'AL','LS','x0'},'problem',{'f0'});

fit_Lorentz_fp = fittype('(A0+B*cos((x-x1)/T*2*pi))*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A0','B','x1','T','LP','LS','x0'});
fit_sine       = fittype(' A0+B*cos((x-x1)/T*2*pi)',                        'coefficients',{'A0','B','x1','T'});

%% Fit FP background
Q_trace_freq = abs(fft(Q_trace));
% figure;
% plot(Q_trace_freq)
Q_trace_freq_temp = Q_trace_freq;
Q_trace_freq_temp(1) = 0;
[amp_fp,pos_fp] = max(Q_trace_freq_temp(1:round(end/2)));
fit_T_estimate = length(Q_trace_freq)/(pos_fp-1);
fit_B_estimate = amp_fp/length(Q_trace_freq);
fit_A0_estimate = mean(Q_trace);

fp_fit = fit( (1:length(Q_trace)).',Q_trace,fit_sine,...
    'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate]);
fp_fit_result = fp_fit((1:length(Q_trace)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);


%         figure
%         plot((1:length(Q_trace)).',Q_trace);
%         hold on
%         plot((1:length(Q_trace)).',MZI_trace);
%         title("Original data")

%         figure
%         plot((1:length(Q_trace)).',Q_trace)
%         hold on
%         scatter((1:length(Q_trace)).',fp_fit_result);
%         title("FP fitting")



%% Peak position find and parameter estimation
% First get difference between FP background and Q_trace original data
peak_trace_temp = Q_trace - fp_fit_result;
% Where deviation most is the position of the dip
[amp_peak,pos_peak] = min(peak_trace_temp);
base_local = fp_fit_result(pos_peak); % FP background at the position of dip
 dip_local = Q_trace(pos_peak); % dip depth
 mid_local = (dip_local + base_local)/2; % middle depth of the dip, used to estimate FWHM
 
    transmission_estimate = max(dip_local/base_local,0); % transmission estimation at the dip
dip_boundary_pos_estimate = [find(peak_trace_temp < mid_local-base_local, 1 ), ...
                             find(peak_trace_temp < mid_local-base_local, 1, 'last' )]; % Cut off position at linewidth FWHM
       linewidth_estimate = abs(diff(dip_boundary_pos_estimate)); % linewidth is difference of FWHM cut off position
% Then pick the data range to fit
pos_fitstart = round(0.05*length(Q_trace));% max(round(0.05*length(Q_trace)) , pos_peak - 10*linewidth_estimate); % fitting range is peak position ±10 linewidth
pos_fitend   = round(0.95*length(Q_trace));% min(round(0.95*length(Q_trace)) , pos_peak + 10*linewidth_estimate); % fitting range is peak position ±10 linewidth

Q_trace_tofit   =   Q_trace(pos_fitstart:pos_fitend);
MZI_trace_tofit = MZI_trace(pos_fitstart:pos_fitend);
peak_trace_temp = peak_trace_temp(pos_fitstart:pos_fitend); % peak_trace_temp = Q_trace - fp background.
% update position information because we picked only part of original data
pos_peak                  = pos_peak                  - pos_fitstart + 1;
dip_boundary_pos_estimate = dip_boundary_pos_estimate - pos_fitstart + 1;

%             figure
%             plot(Q_trace_tofit);
%             hold on
%             plot(MZI_trace_tofit);
%             title("data to fit")
            
%% Peak with FP background fitting
% parameter estimation
fit_A0_estimate = fp_fit.A0;
fit_B_estimate = fp_fit.B;
fit_x1_estimate = mod(fp_fit.x1, fp_fit.T);
fit_T_estimate = fp_fit.T;
fit_LP_estimate = (1-transmission_estimate)*linewidth_estimate^2/4;
fit_LS_estimate = linewidth_estimate/2;
fit_x0_estimate = pos_peak;
% Begin fitting
Q_withfp_fit=fit((1:length(Q_trace_tofit)).', Q_trace_tofit, fit_Lorentz_fp, ...
    'StartPoint', [fit_A0_estimate, fit_B_estimate, fit_x1_estimate, fit_T_estimate...
                    fit_LP_estimate, fit_LS_estimate, fit_x0_estimate]); % Lorentz with FP fit, {'A0','B','x1','T','LP','LS','x0'}

Q_withfp_fit_result = Q_withfp_fit((1:length(Q_trace_tofit)).');
kappa  = 2*abs(Q_withfp_fit.LS); % LS may be negative due to nonlinear fitting
kappa0 = abs(Q_withfp_fit.LS)+sqrt(Q_withfp_fit.LS^2-Q_withfp_fit.LP);
% Q_baseline=Q_withfp_fit.A;
% transmission=Q_withfp_fit(Q_withfp_fit.x0)/Q_withfp_fit.A;

        figure
        plot((1:length(Q_trace_tofit)).',Q_trace_tofit)
        hold on
        scatter((1:length(Q_trace_tofit)).',Q_withfp_fit_result);
        title("Q trace with FP fitting")

%% Then fit MZI with Q trace
MZI_trace_local_start  = max(round(0.05*length(Q_trace)) , pos_peak - 10*linewidth_estimate);
MZI_local_local_end    = min(round(0.95*length(Q_trace)) , pos_peak + 10*linewidth_estimate);
MZI_trace_local        = MZI_trace_tofit(MZI_trace_local_start:MZI_local_local_end);
MZI_trace_local_phasor = hilbert(MZI_trace_local-mean(MZI_trace_local));
MZI_trace_local_phase  = [0;cumsum(mod(diff(angle(MZI_trace_local_phasor))+pi,2*pi)-pi)]+angle(MZI_trace_local_phasor(1));
MZI_period_local       = round(2*pi/mean( angle(MZI_trace_local_phasor(2:end)./MZI_trace_local_phasor(1:end-1) ) ) );

% MZI_fit_T = 4*pi*round(MZI_period_local/4) /( MZI_trace_local_phase(round(min(end/2 + MZI_period_local/4,end))) - MZI_trace_local_phase(round(max(end/2 - MZI_period_local/4,1))) );
MZI_fit_T = 4*pi*round(MZI_period_local/4) / ...
    ( MZI_trace_local_phase( round( min(length(MZI_trace_local_phase)/2 + MZI_period_local/4, length(MZI_trace_local_phase) )))...
    - MZI_trace_local_phase( round( max(length(MZI_trace_local_phase)/2 - MZI_period_local/4, 1                             ))) );

Q0=299792.458/lambda/( kappa0       /MZI_fit_T * MZI_FSR);
Q1=299792.458/lambda/((kappa-kappa0)/MZI_fit_T * MZI_FSR);
QL=299792.458/lambda/( kappa        /MZI_fit_T * MZI_FSR);


















%% MZI to Phase function
function phase = MZI2Phase(trace_MZI)
    trace_length = length(trace_MZI);
    trace_MZI_tofit = trace_MZI;
    % trace_MZI_tofit = sgolayfilt(trace_MZI, 1, 11);
    Base = (max(trace_MZI_tofit) + min(trace_MZI_tofit))/2;
    trace_MZI_phasor = hilbert(trace_MZI_tofit - Base); % use phasor for non-parametric fit

    trace_MZI_phase = [0; cumsum(mod(diff(angle(trace_MZI_phasor))+pi, 2*pi) - pi)] + angle(trace_MZI_phasor(1));
    % trace_MZI_phase = sgolayfilt(trace_MZI_phase, 1, 11);
    phase = sgolayfilt(trace_MZI_phase, 2, round(trace_length/40)*2 + 1);
    % phase = trace_MZI_phase;
end