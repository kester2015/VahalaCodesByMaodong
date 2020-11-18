    clear
    clc
    close all
    %%

filedirGlob = 'Z:\Qifan\thin SiN\20201016-thermal-rawdata\1560.17nm-01-mat';
load(strcat(filedirGlob,'\Fitting_results\coefficients_0.25V.mat'));
% resonance_pos_list = fitting_results(:,end-2);


range_left = 2500;
range_right = 5000;


%% paras used for characterizing power
wavelength = 1560.17;
lambda = wavelength;
outputVoltage1 = 2.969; %V
outputPower1 = 0.5255;%mW
inputPower1 = 1.714;%mW
outputVoltage2 = 2.853; %V
outputPower2 = 0.4817;%mW
inputPower2 = 1.694;%mW
%         Q_data_filename = strcat('Z:\Qifan\SiN\20201002-Screen-Modes\Q-measure-maxvpp-0.5Hz-1.7Vpp-',num2str(wavelength),'nm.mat');
% %         filedirGlob = strcat('Z:\Qifan\SiN\20201004-thermal-rawdata\No14\',num2str(wavelength),'nm-0',num2str(scan_round),'-mat');
%         filedirGlob = strcat('Z:\Qifan\SiN\20201002-thermal-rawdata\No14\',num2str(wavelength),'nm-02-mat');
kerrOverTotal = 0.303619;
    mode_Q0 = 208.5;%M
    mode_Qe = 456.3;%M
%%
WG_power_list = [];
res_shift_list = [];
figure;      
for ii = [9 10 11 12]%1:length(fitting_results(:,1))
    voltage = fitting_results(ii,1);
    resonance_pos = fitting_results(ii,end-2);
    data_filename = strcat(filedirGlob,'\Sweep_0.25Hz_Power_',num2str(voltage),'V.mat');
    load(data_filename,'timeAxis','Ch2','Ch3');
    if ~exist('timeAxis','var')
        load(data_filename,'data_matrix');
        timeAxis = data_matrix(:,1);
        Ch2 = data_matrix(:,2)+0.002;
        Ch3 = data_matrix(:,3);
    end
    MZI_FSR = 39.9553; % MHz

    sapoint = 1e6;
    if length(timeAxis) > sapoint
            timeAxis = timeAxis(1:round(length(timeAxis)/sapoint):end);
            Ch3= Ch3(1:round(length(Ch3)/sapoint):end);
            Ch2 = Ch2(1:round(length(Ch2)/sapoint):end);
    end
    
     %%
    MZI = Ch3(1:end);
    Trans =  Ch2(1:end);
%     Trans = Trans/2.5494*3.0068;

    if min(Trans)<0
            PD_background = min(Trans);
            Trans = Trans - PD_background;
            %warning(["transmission < 0 in rawdata, PD background %d mV are added. critical coupling assumed.", num2str(PD_background/0.001)]);
    end

    % Trans = Trans * sqrt(inputPower2 *outputPower2) * 1e-3 / sqrt(inputVoltage2 * outputVoltage2); % in unit of power;

    Trans_raw = Trans;

    MZI_phase = MZI2Phase(MZI);
    MZI_period_local       = round(2*pi/mean( diff(MZI_phase) ) );
    MZI_fit_T = 4*pi*round(MZI_period_local/4) / ...
            ( MZI_phase( round( min(length(MZI_phase)/2 + MZI_period_local/4, length(MZI_phase) )))...
            - MZI_phase( round( max(length(MZI_phase)/2 - MZI_period_local/4, 1                 ))) );
    
    x_freq = (MZI_phase /2/pi*2*pi / mean( diff(MZI_phase) )  ).';
    
    %% find resonance position
    step_x_freq = mean(diff(x_freq));
    resonance_idx = find(abs(x_freq-resonance_pos)<step_x_freq,1);
    
    [~,dip_pos_idx] = min(Trans_raw);
    res_shift_list(end+1) = (dip_pos_idx-resonance_idx)/MZI_fit_T*MZI_FSR;
    
    %%
%     power_corr_factor = ( 1 - abs( fitting_results(ii,4) ) );  
    power_corr_factor = 1;
    if str2double(filedirGlob(end-4)) == 1
        PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;
    elseif str2double(filedirGlob(end-4)) == 2
        PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
    end
    PoverV = PoverV/power_corr_factor;
    WG_power = fitting_results(ii,2) * PoverV;
    WG_power_list(end+1) = WG_power;
    
    
    %%
    plot_start = resonance_idx - range_left;
    plot_end = resonance_idx + range_right;
    
    x_freq_toplot = x_freq(plot_start:plot_end)-x_freq(resonance_idx);
    trans_toplot = Trans(plot_start:plot_end);
    plot(x_freq_toplot/MZI_fit_T*MZI_FSR,trans_toplot/max(trans_toplot),'DisplayName',sprintf('%.2g mW',WG_power*1e3))
    hold on

    shg
end
legend
xlabel('Detuning / MHz');
ylabel('Normalized Trans');

figure;
scatter(WG_power_list*1e3,res_shift_list)
hold on
ylabel('Resonance redshift / MHz');
xlabel('On-chip power / mW');
xlim([0 1.05*max(WG_power_list*1e3)])
ylim([0 1.05*max(res_shift_list)])
coeff = polyfit(WG_power_list*1e3,res_shift_list,1);
linear_fit = coeff(1)*WG_power_list*1e3 + coeff(2);
plot([WG_power_list*1e3 0],[linear_fit coeff(2)],'--','LineWidth',2.0);



%% MZI to Phase function
function phase = MZI2Phase(trace_MZI)
    trace_length = length(trace_MZI);
    trace_MZI_tofit = trace_MZI;
    % trace_MZI_tofit = sgolayfilt(trace_MZI, 1, 11);
    Base = (max(trace_MZI_tofit) + min(trace_MZI_tofit))/2;
    trace_MZI_phasor = hilbert(trace_MZI_tofit - Base); % use phasor for non-parametric fit

    trace_MZI_phase = [0; cumsum(mod(diff(angle(trace_MZI_phasor))+pi, 2*pi) - pi)] + angle(trace_MZI_phasor(1));
    % trace_MZI_phase = sgolayfilt(trace_MZI_phase, 1, 11);
    phase = sgolayfilt(trace_MZI_phase, 2, round(trace_length/40/20)*2 + 1);
    % phase = trace_MZI_phase;
end