function [Base, FWHM] = getFWHM(filename)
load(filename,'timeAxis','Ch2','Ch3');

% timeAxis = timeAxis(end/2:end);
% Ch2 = Ch2(end/2:end);
% Ch3 = Ch3(end/2:end);

if length(timeAxis) > 1e4
        timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
        Ch3= Ch3(1:round(length(Ch3)/1e4):end);
        Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
end
Ch2 = sgolayfilt(Ch2, 2, round(length(Ch2)/1000)*2 + 1);
phase = MZI_to_phase(Ch3(1:end));
MZI = Ch3(1:end);
Trans =  Ch2(1:end);

%% FP background filter

Trans_raw = Trans;
fit_sine = fittype(' A0+B*cos((x-x1)/T*2*pi)','coefficients',{'A0','B','x1','T'});
Q_trace_freq = abs(fft(Trans_raw));

Q_trace_freq_temp = Q_trace_freq;
Q_trace_freq_temp(1) = 0;
[amp_fp,pos_fp] = max(Q_trace_freq_temp(1:round(end/2)));
fit_T_estimate = length(Q_trace_freq)/(pos_fp-1);
fit_B_estimate = amp_fp/length(Q_trace_freq);
fit_A0_estimate = mean(Trans_raw);

fp_fit = fit( (1:length(Trans_raw)).',Trans_raw,fit_sine,...
    'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate]);
fp_fit_result = fp_fit((1:length(Trans_raw)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);

Trans = Trans_raw./fp_fit_result;

%% Get dip
[dip_y, dip_x] = min(Trans);
Base = max(Trans);
mid_y = (dip_y+Base)/2;
mid_x = [min(find(Trans < mid_y)), max(find(Trans < mid_y))];
% figure
% hold on
% plot(phase, MZI);
% plot(phase, Trans);
% scatter(phase(dip_x), dip_y);
% plot(phase, Base*ones(size(Trans)));
% scatter(phase(mid_x), [mid_y mid_y]);
count = (phase(mid_x(2)) - phase(mid_x(1)))/2/pi;
FWHM = count;
%% Plot
% box on
% grid on
% title(strcat(num2str(count), ' periods in FWHM of transmission'));
end