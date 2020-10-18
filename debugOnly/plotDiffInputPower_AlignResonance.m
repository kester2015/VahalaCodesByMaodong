    clear
    clc
%     close
    %%

filedirGlob = 'Z:\Qifan\thin SiN\20201016-thermal-rawdata\1560.17nm-01-mat';
load(strcat(filedirGlob,'\Fitting_results\coefficients_0.25V.mat'));
% resonance_pos_list = fitting_results(:,end-2);
figure;

range_left = 5000;
range_right = 5000;

for ii = [9 10 11 12 13]%1:length(fitting_results(:,1))
    voltage = fitting_results(ii,1);
    resonance_pos = fitting_results(ii,end-2);
    data_filename = strcat(filedirGlob,'\Sweep_0.25Hz_Power_',num2str(voltage),'V.mat');
    load(data_filename,'timeAxis','Ch2','Ch3');
    if ~exist('timeAxis','var')
        load(data_filename,'data_matrix');
        timeAxis = data_matrix(:,1);
        Ch2 = data_matrix(:,2);
        Ch3 = data_matrix(:,3) + 0.03;
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
    
    %%
    step_x_freq = mean(diff(x_freq));
    resonance_idx = find(abs(x_freq-resonance_pos)<step_x_freq,1);
    
    %%
    plot_start = resonance_idx - range_left;
    plot_end = resonance_idx + range_right;
    
    x_freq_toplot = x_freq(plot_start:plot_end)-x_freq(resonance_idx);
    trans_toplot = Trans(plot_start:plot_end);
    plot(x_freq_toplot,trans_toplot/max(trans_toplot),'DisplayName',strcat(num2str(voltage),'V'))
    hold on

    shg
end

legend

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