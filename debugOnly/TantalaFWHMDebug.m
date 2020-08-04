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

        figure
        plot((1:length(Q_trace)).',Q_trace)
        hold on
        scatter((1:length(Q_trace)).',fp_fit_result);
        title("FP fitting")



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
