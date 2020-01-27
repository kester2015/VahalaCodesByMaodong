function [Base, FWHM] = Get_FWHM(filename)
load(filename);
if length(data1) > 1e4
        data1 = data1(1:round(length(data1)/1e4):end);
        data2 = data2(1:round(length(data2)/1e4):end);
        data5 = data5(1:round(length(data5)/1e4):end);
end
data5 = sgolayfilt(data5, 2, round(length(data5)/1000)*2 + 1);
phase = MZI_to_phase(data2(1:end));
MZI = data2(1:end);
Trans =  data5(1:end);
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