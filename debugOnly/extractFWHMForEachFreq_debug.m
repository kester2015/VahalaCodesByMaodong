close all
clear
clc
%%
MZID1 = 39.9553; %MHz

% % %------20200820 Tantala-----------%
%1535nm
filedirGolb = strcat("D:\Tantala\20200820-thermal-rawdata\Dev21\");
wavelengthList     = [1551   1561   1553   1564];%1535:10:1555;
outputVoltage1List = [2.332  1.876  2.522  0.951];
outputPower1List   = [1.403  1.399  1.658  0.4556];%[1.221 1.637 1.846];%mW
inputVoltage1List  = [3.490  3.335  3.625  2.513];%[1.77296 2.2588 2.4366]; %V
inputPower1List    = [15.80  14.62  15.43  11.71];%[8.421 11.17 12.17];%mW
outputVoltage2List = [2.018  1.780  2.574  1.062];%[0.89960 1.2781 1.1564]; %V
outputPower2List   = [1.183  1.379  1.739  0.5243];%[1.196 1.489 1.704];%mW
inputVoltage2List  = [3.497  3.329  3.528  2.448];%[1.773 2.1937 2.4256]; %V
inputPower2List    = [15.03  15.29  16.06  10.61];%[8.548 10.55 12.24];%mW
% QtotList           = [2.096  1.644  1.806  0.5354]*1e6;
% QextList           = [8.754  6.114  7.413  1.482]*1e6;
% -----20200830 update with FP-fano fitting-----
QtotList           = [2.134  1.819  1.569  0.544]*1e6;
QextList           = [9.013  7.579  6.012  1.500]*1e6;
realwavelengthList = [1551.4 1561.0  1553.05 1564.3];
kerrOverTotalList  = [0.0332 0.0353  0.0332  0.0353]/2;
% 
% count = 1:length(wavelengthList);

% %------20200819 Tantala-----------%
% 1535nm
filedirGolb = strcat("D:\Tantala\20200819-thermal-rawdata\Dev21\");
wavelengthList     = [1540   1545   1551   1556   1561];%1535:10:1555;
outputVoltage1List = [1.855  1.819  2.373  3.064  2.245];
outputPower1List   = [1.154  1.122  1.860  2.298  1.894];%[1.221 1.637 1.846];%mW
inputVoltage1List  = [2.960  3.665  3.643  3.916  3.457];%[1.77296 2.2588 2.4366]; %V
inputPower1List    = [12.11  15.20  15.90  16.80  14.90];%[8.421 11.17 12.17];%mW
outputVoltage2List = [1.767  2.020  2.313  3.003  2.527];%[0.89960 1.2781 1.1564]; %V
outputPower2List   = [1.112  1.292  1.620  2.355  2.047];%[1.196 1.489 1.704];%mW
inputVoltage2List  = [2.973  3.731  3.810  3.950  3.453];%[1.773 2.1937 2.4256]; %V
inputPower2List    = [12.46  15.30  15.90  15.58  15.16];%[8.548 10.55 12.24];%mW
% QtotList           = [1.501  1.307  2.027  1.413  1.688]*1e6;
% QextList           = [9.465  5.879  7.543  4.255  5.897]*1e6;
% 20200829, update with FP fitting
QtotList           = [1.46  1.16  2.04  1.34  1.53]*1e6;
QextList           = [9.37  4.33  7.04  4.16  5.04]*1e6;
realwavelengthList = [1540.4 1545.1 1551.4 1556.2 1561.0];
kerrOverTotalList  = [0.0353 0.0390 0.0332 0.0349 0.0353]/2;

count = 1:length(wavelengthList);


wavelengthList     = wavelengthList(count);%1535:10:1555;
outputVoltage1List = outputVoltage1List(count);
outputPower1List   = outputPower1List(count);%[1.221 1.637 1.846];%mW
inputVoltage1List  = inputVoltage1List(count);%[1.77296 2.2588 2.4366]; %V
inputPower1List    = inputPower1List(count);%[8.421 11.17 12.17];%mW
outputVoltage2List = outputVoltage2List(count);%[0.89960 1.2781 1.1564]; %V
outputPower2List   = outputPower2List(count);%[1.196 1.489 1.704];%mW
inputVoltage2List  = inputVoltage2List(count);%[1.773 2.1937 2.4256]; %V
inputPower2List    = inputPower2List(count);%[8.548 10.55 12.24];%mW
QtotList           = QtotList(count);
QextList           = QextList(count);
realwavelengthList = realwavelengthList(count);
kerrOverTotalList  = kerrOverTotalList(count);

Q0List             = (QtotList.*QextList)./(QextList-QtotList);
%%

matfileStart = 20; 
for count = 1:length(wavelengthList)
    %%
    wavelength = wavelengthList(count);
    outputVoltage1 = outputVoltage1List(count); %V
    outputPower1 = outputPower1List(count);%mW
    inputVoltage1 = inputVoltage1List(count); %V
    inputPower1 = inputPower1List(count);%mW
    outputVoltage2 = outputVoltage2List(count); %V
    outputPower2 = outputPower2List(count);%mW
    inputVoltage2 = inputVoltage2List(count); %V
    inputPower2 = inputPower2List(count);%mW


    

    %%
    figure;
    subplot(211);

    % ----------- not reversed ----------
    filedir = strcat(filedirGolb,num2str(wavelength),"nm-01-mat");
    matfiles = dir(strcat(filedir,'\*.mat') );
    matfilesName = {matfiles.name};
        for pp = 1:length(matfiles)
            [~, matfiles(pp).voltage] = extractFreqAndPower(matfilesName{pp});
        end
    [~, pos] = sort( [matfiles.voltage] );

    FWHMList1 = zeros( length(matfiles), 2);
    
    
    for ii = 1:length(matfiles)  %------------------------------>>>NEED CHOOSE START POINT!!, 1 by default.
        filename = strcat(filedir, '\', matfiles(pos(ii)).name);
            [Ch2,FWHM] = getFWHM(filename);

            FWHM = FWHM*MZID1; %MHz
            load(filename,'Ch1');
%             if ii == 1
%                 Ch1_background = mean(Ch1);
%             end
            Ch1 = max(Ch1);% - Ch1_background;
%             Ch4 = max(Ch4);
%             Ch2 = max(Ch2);

            EOMPower = sqrt(Ch1*Ch2)*sqrt(outputPower1*inputPower1)/sqrt(outputVoltage1*inputVoltage1) ;

            FWHMList1(ii,:) = [EOMPower FWHM];

            line(EOMPower, FWHM, 'marker','o',... 
                                 'Color','blue',...
                                 'userdata',{filename,ii},...
                                 'ButtonDownFcn',@plotThisOSCTrace);
%             ylim([0 600]);
    end
%     FWHMList1 = sortrows(FWHMList1,1);
%     legend({'before reverse','after reverse'});
    xlabel('waveguide Power / mW');
    ylabel('FWHM / MHz');
    title(strcat(num2str(wavelength),'nm'));
    hold on


    %----- reverse -----%
    filedir = strcat(filedirGolb,num2str(wavelength),"nm-02-mat");
    matfiles = dir(strcat(filedir,'\*.mat') );
    matfilesName = {matfiles.name};
        for pp = 1:length(matfiles)
            [~, matfiles(pp).voltage] = extractFreqAndPower(matfilesName{pp});
        end
    [~, pos] = sort( [matfiles.voltage] );
    FWHMList2 = zeros(length(matfiles),2);
    
    for ii = 1:length(matfiles) %------------------------------>>>NEED CHOOSE START POINT!!, 1 by default.
        filename = strcat(filedir, '\', matfiles(pos(ii)).name);
            [Ch2,FWHM] = getFWHM(filename);
            FWHM = FWHM*MZID1; %MHz

            load(filename,'Ch1');
%             if ii == 1
%                 Ch1_background = mean(Ch1);
%             end
            Ch1 = max(Ch1);% - Ch1_background;
%             Ch4 = max(Ch4);
%             Ch2 = max(Ch2);

            EOMPower = sqrt(Ch1*Ch2)*sqrt(outputPower2*inputPower2)/sqrt(outputVoltage2*inputVoltage2) ;

            FWHMList2(ii,:) = [EOMPower FWHM];
            line( EOMPower, FWHM, 'marker','*',... 
                                 'Color','red',...
                                 'userdata',{filename,ii},...
                                 'ButtonDownFcn',@plotThisOSCTrace);
%              ylim([0 600]);
    end
    
    xlabel('waveguide Power / mW');
    ylabel('FWHM / MHz');
    title(strcat(num2str(wavelength),'nm'));
    hold on
    
    %% fitting begins here
    subplot(212)
    fitStartPower = 1.0; % lowest wg power to fit, ensure triangle appears.
    fitEndPower = 3.5; % highest wg power to fit, ensure no comb appears.
    FWHMList1forfit = FWHMList1(FWHMList1(:,1)>fitStartPower,:);
    FWHMList2forfit = FWHMList2(FWHMList2(:,1)>fitStartPower,:);
    FWHMList1forfit = FWHMList1forfit(FWHMList1forfit(:,1)<fitEndPower,:);
    FWHMList2forfit = FWHMList2forfit(FWHMList2forfit(:,1)<fitEndPower,:);
    coeff1 = polyfit(FWHMList1forfit(:,1),FWHMList1forfit(:,2),1);
    coeff2 = polyfit(FWHMList2forfit(:,1),FWHMList2forfit(:,2),1);
    FWHMfit1 = coeff1(1)*FWHMList1forfit(:,1)+coeff1(2);
    FWHMfit2 = coeff2(1)*FWHMList2forfit(:,1)+coeff2(2);
    
    scatter(FWHMList1forfit(:,1),FWHMList1forfit(:,2),'LineWidth',2.0);
    hold on
    scatter(FWHMList2forfit(:,1),FWHMList2forfit(:,2),'LineWidth',2.0);
    hold on
    plot(FWHMList1forfit(:,1),FWHMfit1,'--','LineWidth',2.0);
    hold on
    plot(FWHMList2forfit(:,1),FWHMfit2,'--','LineWidth',2.0);
    meanSlope(count) = sqrt( coeff1(1)* coeff2(1) ) % in MHz/mW
    xlabel('waveguide Power / mW');
    ylabel('FWHM / MHz');
    title(strcat(num2str(wavelength),'nm'));
    pause(1);
    saveas(gcf,strcat(filedirGolb,num2str(wavelength),'nm.fig'));
    saveas(gcf,strcat(filedirGolb,num2str(wavelength),'nm.png'));
end
save(strcat(filedirGolb,'meanSlope.mat'),'meanSlope');

% %%
% % % %------20200819 Tantala-----------%
% %1535nm
% filedirGolb = strcat("D:\Tantala\20200819-thermal-rawdata\Dev21\");
% wavelengthList     = [1540   1545   1551   1556   1561];%1535:10:1555;
% outputVoltage1List = [1.855  1.819  2.373  3.064  2.245];
% outputPower1List   = [1.154  1.122  1.860  2.298  1.894];%[1.221 1.637 1.846];%mW
% inputVoltage1List  = [2.960  3.665  3.643  3.916  3.457];%[1.77296 2.2588 2.4366]; %V
% inputPower1List    = [12.11  15.20  15.90  16.80  14.90];%[8.421 11.17 12.17];%mW
% outputVoltage2List = [1.767  2.020  2.313  3.003  2.527];%[0.89960 1.2781 1.1564]; %V
% outputPower2List   = [1.112  1.292  1.620  2.355  2.047];%[1.196 1.489 1.704];%mW
% inputVoltage2List  = [2.973  3.731  3.810  3.950  3.453];%[1.773 2.1937 2.4256]; %V
% inputPower2List    = [12.46  15.30  15.90  15.58  15.16];%[8.548 10.55 12.24];%mW
% QtotList           = [1.501  1.307  2.027  1.413  1.688]*1e6;
% QextList           = [9.465  5.879  7.543  4.255  5.897]*1e6;
% realwavelengthList = [1540.4 1545.1 1551.4 1556.2 1561.0];
% kerrOverTotalList  = [0.0353 0.0390 0.0332 0.0349 0.0353]/2;

%%
c = 299792458;
n0 = 2.0573;
neff = 1.8373;
n0 = neff;
r = 109.5e-6;
nT = 10.46e-6;
% Aeff and dTdP from simulation
Aeff = 1.0575e-12;
dTdP = 613;%1685;%1570;

n2List = zeros(1,length(wavelengthList));
QabsAndKerrList = n2List;
n2TOTList = n2List;
QabsList = n2List;
load(strcat(filedirGolb,'meanSlope.mat'),'meanSlope');
% 

% meanSlope(5) = meanSlope(4);
% QextList(5) = 13.9725e6;
% QtotList(5) = 0.7*QtotList(5);
% realwavelengthList(5) = realwavelengthList(1);
% kerrOverTotalList(5) = kerrOverTotalList(1);
for count = 1:length(wavelengthList)
    %%
    
    wavelength = realwavelengthList(count);
    
    %% Calculate n2 here
    Qtot = QtotList(count);
    Qext = QextList(count);

    lambda = wavelength * 1e-9; % normalize ti SI unit
    omega=c/lambda*2*pi;
    
    kappa = c/lambda/Qtot*2*pi; % in rad/s
    ita = Qtot/Qext;
    
    alpha = meanSlope(count)*2*pi*1e6/1e-3* kappa/2/ita ;
    QabsAndKerr = nT * dTdP *(2*pi*c/lambda)^2/n0/alpha;
    QabsAndKerrList(count) = QabsAndKerr;
    
    kerrOverTotal = kerrOverTotalList(count);
    g=(kerrOverTotal)*alpha;
    n2=g*n0^2*Aeff*2*pi*r/omega/c;
    n2List(count) = n2;
    
%             % ------Test with n2kerr from paper arxiv: 2007.12958------
%             g=1*alpha;
%             n2TOT=g*n0^2*Aeff*2*pi*r/omega/c;
%             n2TOTList(count) = n2TOT;
%             n2Kerr = 6.223e-19;
%             kerrOverTotal = n2Kerr/n2TOT;
%             kerrOverTotalList(count) = kerrOverTotal;
%             % -----Temp test code ends, 20200805-----

    Qabs = QabsAndKerr/(1-kerrOverTotal);
    QabsList(count) = Qabs;
    
end

figure;
scatter(wavelengthList,n2List,'LineWidth',2.0);
% hold on
% scatter(wavelengthList,n2ListOC,'LineWidth',2.0);
xlabel('wavelength / nm');
ylabel('n2 / m^2/W');
title("n2 for different wavelength");
% legend({'under couple'})
% legend({'under couple','over couple'})

figure;
scatter(wavelengthList,QabsList,'LineWidth',2.0);
hold on
% scatter(wavelengthList,QabsListOC,'LineWidth',2.0);
xlabel('wavelength / nm');
ylabel('Qabs');
% ylim([0 10]*1e6)
title("Qabs for different wavelength");
% legend({'under couple'})
% legend({'under couple','over couple'})

%%
% c = 299792458;
% lambda = 1555e-9;
% omega=c/lambda*2*pi;
% n0=3.3;
% kappa = c/lambda/1.248e6*2*pi; % in rad/s
% ita = 1.248/5.307;
% r = 719.38e-6;
% Aeff = 2.63e-13;
% 
% 
% 
% alpha = meanSlope*2*pi*1e6/1e-3* kappa/2/ita ;
% 
% QabsAndKerr = 2.3e-4*88.354*(2*pi*c/lambda)^2/n0/alpha;
% kerrOverTotal = 0.9266;
% g=(1-kerrOverTotal)*alpha;
% Qabs = QabsAndKerr/kerrOverTotal;
% n2=g*n0^2*Aeff*2*pi*r/omega/c;

%% Cross check with Changlin's paper arXiv:1909.09778
% c = 299792458;
% lambda = 1550e-9;
% Aeff = 2.63e-13;
% Qtotal = 0.63e6;
% Qint = 1.26e6;
% kappa = c/lambda/Qtotal*2*pi;
% ita = 1 - Qtotal/Qint;
% D1 = 1e12*2*pi;
% omega0 = 2*pi*193e12;
% n0 = 3.3;
% n2 = 2.6e-17;
% 
% 
% Pth = pi*n0*kappa^2*Aeff/4/omega0/n2/D1/ita;
% Pth/1e-6

%%
function plotThisOSCTrace(gcbo,EventData,handles)
    userdata = get(gcbo,'userdata');
    filename = userdata{1};
    index = userdata{2}
    plotOSCTraces(filename);
    getFWHM(filename,1);
end