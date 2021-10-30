ws = FinisarWaveshaper();
ws.connect;
osc = TDS2024C();
osc.connect;
filedir_glob = strcat('Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\AutoCorrelators\',datestr(now,'yyyymmdd'),'-autocorr\');

%%
% close all
% 
% filedir_glob = strcat('Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\AutoCorrelators\',datestr(now,'yyyymmdd'),'-autocorr\');
% 
% center = 193.33;
% bandpass = 0.8 ; %THz
% 
% disp2 = -6.15;
% 
% disp3 = 0.5;
% 
% ws.thirdDispersion(disp2, disp3, center );
% ws.bandPass(center-bandpass/2, center+bandpass/2);
% % 
% OSA_to_inverse_file = 'Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\20211018\AN_No13\EO input\EOComb-17493730kHz-2PM-beforeWSInverse-afterWG-AM0.0V.mat';
% load(OSA_to_inverse_file)
% ws.userdata.OSA_to_inverse_file = OSA_to_inverse_file;
% ws.inverseAtten(OSAWavelength, OSAPower,-25,[center-bandpass/2, center+bandpass/2])
% 
% ws.plot_status('nm')
% ws.write2WS

%%
close all
disp2 = 2%6.50;
disp3 = 0%0.2;

center = 193.33;
bandpass = 0.35 ; %THz
ws.thirdDispersion(disp2, disp3, center );
% OSA_to_inverse_file = 'Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\20211019\AN_No13\EO input\EOComb-17490340kHz-2PM-beforeWSInverse-afterWG-AM0.6V.mat';
% load(OSA_to_inverse_file)
ws.userdata.OSA_to_inverse_file = OSA_to_inverse_file;
% ws.inverseAtten(avelength-0.0, OSAPower,-22,[center-bandpass/2, center+bandpass/2])
% ws.bandPass(center-bandpass/2, center+bandpass/2)
ws.plot_status('nm')
ws.write2WS;

%  filedir = strcat(filedir_glob,'good_disp23\');
filedir = strcat(filedir_glob,'test_disp23\');

filename = sprintf('disp2_%.3f_disp3_%.3f__bp_%.3f_THz_cen_%.3f_THz',disp2,disp3, bandpass, center );
 pause(5)

osc.saveTrace( 1, strcat(filedir, filename) );
%  pause(1)
%  osc.saveTrace( 1, strcat(filedir, filename) ); % save 2 traces for backup

close all
get_autocorr_FWHM(strcat(filedir, filename,'.mat'))

% save(strcat(filedir,filename,'_waveshaper_obj.mat'),'ws')
%%
get_autocorr_FWHM(strcat(filedir, filename,'.mat'))


%%
close all
% filedir = strcat('Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\20211017\AN_No13\CombOut-2Sol\Detun4_EOComb_17493730_kHz',"\");
filedir = strcat(filedir_glob,'test_disp23\');
% filedir = 'Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\20211019\AN_No13\CombOut-2Sol\Detun3_EOComb_17493111_kHz\autocorr-left\'
filedir = 'Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\20211019\AN_No13\CombOut-2Sol\autocorr-test\'

filename = sprintf('disp2_%.3f_disp3_%.3f__bp_%.3f_THz_cen_%.3f_THz',disp2,disp3, bandpass, center );
osc.saveTrace( 1, strcat(filedir,'', filename) );
[dt,~] = get_autocorr_FWHM(strcat(filedir,'', filename,'.mat'))
saveas(gcf, strcat(filedir,'', 'dt_',num2str(dt/1e-12,'%.3f'),'_ps_',filename,'.png') )
% osc.saveTrace( 1, strcat(filedir,'tests\', filename) );
% get_autocorr_FWHM(strcat(filedir,'tests\', filename,'.mat'))
%%
[dt,~] = get_autocorr_FWHM( strcat(filedir,'', filename,'.mat') );

% get_autocorr_FWHM('Z:\Maodong\Projects\Pulse Pumping\Anello_SiN_10G\AutoCorrelators\20211015-autocorr\test_disp23\disp2_-6.100_disp3_0.500__bp_0.800_THz_cen_193.330_THz_211015_175318_bak.mat')
%%
ws.disconnect;


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
EOM_rep_rate = 21.5e9;
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