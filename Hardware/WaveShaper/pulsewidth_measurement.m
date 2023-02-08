filedir_global = 'Z:\Maodong\Projects\Pulse Pumping\AlGaAs\20220411\AUTOCORR\';

osc = TDS2024C();
osc.connect;

filename = 'disp2_-6.2_1'

osc.saveTrace( 1, strcat(filedir_global, filename) )
[dt_list, dt_error_list] = get_autocorr_FWHM( strcat(filedir_global,filename, '.mat') )
saveas(gcf, strcat(filedir_global,filename, '.fig') )
saveas(gcf, strcat(filedir_global,filename, '.png') )

osc.disconnect;

%%
% get_autocorr_FWHM('disp2_-3.0_220107_184521_bak.mat')
get_autocorr_FWHM( strcat(filedir_global,filename, '.mat') )
%%
function [electrical_pulse_width,electrical_pulse_width_error] = get_autocorr_FWHM(filename)

load(filename)

%%
pulse_time = X;
pulse_shape = Y;
fit_range = 30; % in numbers.

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
EOM_rep_rate = 17.4940e9;
electrical_pulse_width = ratio / EOM_rep_rate % electrical width

fit_error = confint(fit_obj,0.95);
fit_error_dx = abs(diff(fit_error(:,3)))/2; % one sided error
electrical_pulse_width_error = fit_error_dx/rep_time/EOM_rep_rate;

figure;
hold on
plot(pulse_time, pulse_shape);
plot(pulse_time,fit_result);
line([max(pulse_time(peak_pos)) max(pulse_time(peak_pos))], [-1 1]);
line([min(pulse_time(peak_pos)) min(pulse_time(peak_pos))], [-1 1]);
title(strcat('Input EOM pulse, electrical pulse width = ', num2str(electrical_pulse_width*1e12), 'ps') )


figure;
plot(14 + pulse_time/rep_time/EOM_rep_rate/1e-12, pulse_shape);
hold on
plot(14 + pulse_time/rep_time/EOM_rep_rate/1e-12,fit_result);
xlabel('Time (ps)')

title(strcat('Input EOM pulse, electrical pulse width = ', num2str(electrical_pulse_width*1e12), 'ps') )
end