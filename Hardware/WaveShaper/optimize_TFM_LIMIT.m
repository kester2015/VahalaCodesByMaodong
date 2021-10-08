close all
% osc = TDS2024C();
% osc.connect;
% ws = FinisarWaveshaper();
% ws.connect;

filedir_glob = 'Z:\Maodong\Projects\Pulse Pumping\AlGaAs\AutoCorrelators\20211007-autocorr-TFM-LIMIT'

center = 193.37;
bandpass = [0.8: -0.05:0.25 ] ; %THz
disp2 = -5.9;
disp3 = 0.7;

OSA_to_inverse_file = 'Z:\Maodong\Projects\Pulse Pumping\AlGaAs\20211007\AN_No13\EO input\EOComb-17493511kHz-2PM-beforeWSInverse.mat';
load(OSA_to_inverse_file)
ws.userdata.OSA_to_inverse_file = OSA_to_inverse_file;

bp = max(bandpass);
ws.inverseAtten(OSAWavelength, OSAPower,-11,[center-bp/2, center+bp/2])
ws.thirdDispersion(disp2, disp3, center)
ws.plot_status
ws.write2WS
filedir = strcat(filedir_glob,'\',sprintf('disp2_%.2f_disp3_%.2f', disp2,disp3),'\');
%%
for ii = 1:length(bandpass)
    close all
    bp = bandpass(ii);
    filename = sprintf('bp_%.3f_THz',bp );
    
    ws.inverseAtten(OSAWavelength, OSAPower,-12,[center-bp/2, center+bp/2])
    ws.plot_status;
    
    pause(0.1)
    state = ws.write2WS;
    if ~state == 0
        error("write to waveshaper failed")
%     elseif state == 0
%         sound(sin(0.25*1:1500)); % sound flag write success
    end
    
    pause(1)
    osc.saveTrace( 1, strcat(filedir, filename) );
    pause(1)
    osc.saveTrace( 1, strcat(filedir, filename) ); % save 2 traces for backup
end

save(strcat(filedir,'waveshaper_obj.mat'),'ws')

bp = max(bandpass);
ws.inverseAtten(OSAWavelength, OSAPower,-11,[center-bp/2, center+bp/2])
ws.thirdDispersion(disp2, disp3, center)
ws.plot_status
ws.write2WS

%%
close all
dt_list = zeros(size(bandpass));
dt_error_list = dt_list; % half sided error

for ii = 1:length(bandpass)
    bp = bandpass(ii);
    filename = sprintf('bp_%.3f_THz.mat',bp );
    
    [dt_list(ii), dt_error_list(ii)] = get_autocorr_FWHM( strcat(filedir,filename) );
    
end

tflimited = @(x) 2*fzero(@(x)sinc(x).^2-0.5,0.1) * x;
figure
hold on
errorbar(1./bandpass,2*dt_list/1e-12,2*dt_error_list/1e-12,'o','DisplayName','EO pulse width')
plot(1./bandpass,tflimited(1./bandpass),'--','DisplayName','Transform limited')
xlabel('Inverse EO Comb Bandwidth (1/THz)')
ylabel('Pulse FWHM (ps)')
legend('location','best')
xlim([0 Inf])
ylim([0 Inf])


%%
function [electrical_pulse_width,electrical_pulse_width_error] = get_autocorr_FWHM(filename)

load(filename)

%%
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
EOM_rep_rate = 17.5e9;
electrical_pulse_width = ratio / EOM_rep_rate % electrical width

fit_error = confint(fit_obj,0.95);
fit_error_dx = abs(diff(fit_error(:,3)))/2; % one sided error
electrical_pulse_width_error = fit_error_dx/rep_time/EOM_rep_rate;

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