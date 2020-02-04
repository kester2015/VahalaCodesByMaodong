function [Base, FWHM] = getFWHM(filename)
load(filename,'timeAxis','Ch2','Ch3');

timeAxis = timeAxis(end/2:end);
Ch2 = Ch2(end/2:end);
Ch3 = Ch3(end/2:end);

if length(timeAxis) > 1e4
        timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
        Ch3= Ch3(1:round(length(Ch3)/1e4):end);
        Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
end
Ch2 = sgolayfilt(Ch2, 2, round(length(Ch2)/1000)*2 + 1);
phase = MZI_to_phase(Ch3(1:end));
MZI = Ch3(1:end);
Trans =  Ch2(1:end);
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