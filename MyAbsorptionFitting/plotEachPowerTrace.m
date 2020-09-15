
close all

wavelengthList = 1535;%1535:10:1555;
highNoiseThreshold = 0.2;


filedirGolb = "Z:\Qifan\Tantala\20200819-thermal-rawdata\Dev21\"; % --20200819 Tantala ---
wavelengthList = [1540   1545   1551   1556   1561];

filedirGolb = "Z:\Qifan\AlGaAs\20200211\"; % --20200211 AlGaAs ---
wavelengthList = [1535 1540 1545 1550 1555 1560];

% filedirGolb = "Z:\Maodong\Measurement Data\Absorption project\20200130\";
% wavelengthList = [1540 1545];
% wavelengthList     = [1551 1553 1561 1564];
% filedirGolb = "D:\Measurement Data\Tantala-broadening\"; % --20200810 Tantala ---
% wavelengthList     = [1540   1545   1551   1556   1561];%1535:10:1555;

%filedirGolb = strcat("D:\Measurement Data\Absorption project\SiN\20200223\Row2Col1_Triangle\",num2str(wavelength));
% filedirGolb = "D:\Measurement Data\Absorption project\SiN\20200223\Row2Col1_Triangle\";

for wavelength = wavelengthList
    
    filedir = strcat(filedirGolb,num2str(wavelength),"nm-01-mat");
    matfiles = dir(strcat(filedir,'\*.mat') );
    % extractFreq = 5; % Hz
    FWHMList1 = zeros(length(matfiles),2);
    transList = zeros(length(matfiles),1);
%     plotnum = length(matfiles); % how many traces you want to plot
    plotnum = 15;

%     figure('Units', 'Normalized', 'OuterPosition', [2.1, 0.45, 0.55, 0.5]);
    figure;
    subplot(121)
    for ii = 1:round(length(matfiles)/plotnum):length(matfiles)
        filename = strcat(filedir, '\', matfiles(ii).name);
        [sweepFreq, EOMPower] = extractFreqAndPower(filename);
        if EOMPower < highNoiseThreshold
            continue;
        end

        load(filename,'timeAxis','Ch2');
        if length(Ch2) > 1e4
            timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
            Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
        end
        Ch2 = Ch2 + 3.09e-3;
        maxCh2 = median(Ch2);
    %     minCh2 = min(Ch2);
        normalCh2 = Ch2/maxCh2;
        plot(timeAxis,normalCh2);
        hold on    
    end
    title(strcat(num2str(wavelength),'nm', ', Not reversed'));
    xlabel('time / s')
    ylabel('Normalized transmission')


    FWHMList1 = zeros(length(matfiles),2);
    filedir = strcat(filedirGolb,num2str(wavelength),"nm-02-mat");
    subplot(122)
    for ii = 1:round(length(matfiles)/plotnum):length(matfiles)
        filename = strcat(filedir, '\', matfiles(ii).name);
        [sweepFreq, EOMPower] = extractFreqAndPower(filename);
        if EOMPower < highNoiseThreshold
            continue;
        end
        load(filename,'timeAxis','Ch2');
        if length(Ch2) > 1e4
            timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
            Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
        end
        Ch2 = Ch2 + 3.09e-3;
        maxCh2 = median(Ch2);
    %     minCh2 = min(Ch2); 
        normalCh2 = Ch2/maxCh2;
        plot(timeAxis,normalCh2);
        hold on    
    end
    title(strcat(num2str(wavelength),'nm', ', Reversed'));
    xlabel('time / s')
    ylabel('Normalized transmission')
    
    pause(1);
end