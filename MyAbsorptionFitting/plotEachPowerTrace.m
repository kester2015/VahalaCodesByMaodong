


wavelength = 1550;
filedir = strcat("D:\Measurement Data\Absorption project\20200201-new\",num2str(wavelength),"nm-01-mat");

matfiles = dir(strcat(filedir,'\*.mat') );
% extractFreq = 5; % Hz
FWHMList1 = zeros(length(matfiles),2);

transList = zeros(length(matfiles),1);

figure;

for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    
    load(filename,'timeAxis','Ch2');
    if length(Ch2) > 1e4
        timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
        Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
    end
    
    maxCh2 = max(Ch2);
%     minCh2 = min(Ch2);
    
    normalCh2 = Ch2/maxCh2;
    plot(timeAxis,normalCh2);
    hold on    
end
title(strcat(num2str(wavelength),'nm', ', Not reversed'));
xlabel('time / s')
ylabel('Normalized transmission')