close all
clear
clc

MZID1 = 39.9553; %MHz


% n2List = zeros(length(wavelengthList),1);
% QabsList = zeros(length(wavelengthList),1);


% %------20200804 Tantala-----------%
% wavelengthList = [1536 1540 1544 1548 1552 1555 1560 1564];%1535:10:1555;
count = 1;%1535nm
filedirGolb = strcat("Z:\Maodong\Tantala\20200804-thermal-rawdata\");
wavelengthList     = [1536    1540   1544   1548    1552    1555    1560    1564   ];%1535:10:1555;
outputVoltage1List = [1.255   1.273  2.315  1.322   1.469   2.145   2.047   2.145  ];%[0.97773 1.2649 1.1053]; %V
outputPower1List   = [0.05752 0.1407 0.1357 0.1738  0.09438 0.07548 0.08051 0.07689];%[1.221 1.637 1.846];%mW
inputVoltage1List  = [4.015   0.308  2.833  2.794   2.257   1.485   1.673   1.778  ];%[1.77296 2.2588 2.4366]; %V
inputPower1List    = [1.882   2.776  3.103  2.495   1.704   1.268   1.699   1.567  ];%[8.421 11.17 12.17];%mW
outputVoltage2List = [1.343   1.101  2.077  0.161   1.484   2.505   2.250   2.130  ];%[0.89960 1.2781 1.1564]; %V
outputPower2List   = [0.05572 0.1312 0.1102 0.03747 0.08528 0.09905 0.07946 0.08120];%[1.196 1.489 1.704];%mW
inputVoltage2List  = [4.224   0.308  2.822  2.810   1.747   1.792   1.670   1.787  ];%[1.773 2.1937 2.4256]; %V
inputPower2List    = [1.775   2.972  2.597  2.883   1.473   1.746   1.497   1.777  ];%[8.548 10.55 12.24];%mW
% QtotList         = [1.035   0.7445 1.2    0.8831  0.922   0.3973  0.8875  1.568  ]*1e6;
% QextList         = [2.07    1.769  3.224  4.61    2.907   0.7945  1.934   4.745  ]*1e6;
% -----updated with FP fitting------
QtotList           = [1.1     0.729  1.21   0.962   0.905   0.363   0.845   1.63   ]*1e6;
QextList           = [2.2     1.72   3.27   2.86    2.87    0.727   1.95    4.89   ]*1e6;

realwavelengthList = [1536.25 1540.4 1544.1 1548.15 1552.1  1555.75 1560    1564];

kerrOverTotalList  = [0       0      0      0       0       0       0       0      ];
% kerrOverTotalList = 1 - [0.9319 0.9030 0.9299 0.8982 0.9003 0.9080 0.8970];
% fitStartPower = 0.3; % lowest wg power to fit, ensure triangle appears.
% fitEndPower = 2; % highest wg power to fit, ensure no comb appears.

% %------20200211-----------%
% wavelengthList = 1535:5:1565;
% filedirGolb = strcat("D:\Measurement Data\Absorption project\20200211\");
% outputVoltage1List = [525 517 605 624 440 368 503]*1e-3; %V
% outputPower1List = [821.9 811.3 931.2 1008 662.2 646.5 781.3] *1e-3;%mW
% inputVoltage1List = [2.14 1.71 1.996 2.04 1.932 1.30 1.71]; %V
% inputPower1List = [5.405 4.330 5.172 5.264 5.058 3.594 4.584];%mW
% outputVoltage2List = [520 504 605 607 413 312.8 455.5]*1e-3; %V
% outputPower2List = [775.4 808.0 933.9 990.7 635.8 497.8 737.7]*1e-3;%mW
% inputVoltage2List = [2.15 1.72 1.99 2.05 1.932 1.25 1.70]; %V
% inputPower2List = [5.342 4.414 5.075 5.388 4.925 3.383 4.605];%mW
% 
% QtotList = [0.7888 1.297 0.797 1.331 1.203 1.112 1.284]*1e6;
% QextList = [5.945 4.588 4.52 4.501 3.262 3.378 3.081]*1e6;
% 
% kerrOverTotalList = 1 - [0.9319 0.9030 0.9299 0.8982 0.9003 0.9080 0.8970];
% 
% kerrOverTotalList = [0.0810 0.166 0.0844 0.199 0.1202 0.1076 0.1208];
% 
% kerrOverTotalList = [0.0830 0.1196 0.0865 0.1231 0.1234 0.1104 0.1239]; 
% 
% kerrOverTotalList = [0.0825 0.1187 0.0852 0.1235 0.1236 0.1103 0.1243];

%------20200204-----------%
% outputVoltage1List = [475.87 511.71 472.40 439.27 461.33 448.20]*1e-3; %V
% outputPower1List = [796.2 800.5 803.6 684.6 792.0 711.0] *1e-3;%mW
% inputVoltage1List = [1.762423 1.9325 1.73319 1.64303 1.70415 1.60438]; %V
% inputPower1List = [4.554 5.049 4.768 4.283 4.813 4.239];%mW
% outputVoltage2List = [488.71 485.60 462.80 445.91 472.87 450.10]*1e-3; %V
% outputPower2List = [780.2 791.0 742.2 733.6 755.5 749.4]*1e-3;%mW
% inputVoltage2List = [1.75927 1.9318 1.72166 1.71949 1.68182 1.58624]; %V
% inputPower2List = [4.537 5.208 4.115 4.622 4.631 4.455];%mW

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
    hh = figure;
    subplot(211)
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
            [~,FWHM] = getFWHM(filename);

            FWHM = FWHM*MZID1; %MHz
            load(filename,'Ch1','Ch4');
            if ii == 1
                Ch1_background = mean(Ch1);
            end
            Ch1 = max(Ch1) - Ch1_background;
            Ch4 = max(Ch4);

            EOMPower = sqrt(Ch1*Ch4)*sqrt(outputPower1*inputPower1)/sqrt(outputVoltage1*inputVoltage1) ;

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
            [~,FWHM] = getFWHM(filename);
            FWHM = FWHM*MZID1; %MHz

            load(filename,'Ch1','Ch4');
            if ii == 1
                Ch1_background = mean(Ch1);
            end
            Ch1 = max(Ch1) - Ch1_background;
            Ch4 = max(Ch4);

            EOMPower = sqrt(Ch1*Ch4)*sqrt(outputPower2*inputPower2)/sqrt(outputVoltage2*inputVoltage2) ;

            FWHMList2(ii,:) = [EOMPower FWHM];
            line(EOMPower, FWHM, 'marker','*',... 
                                 'Color','red',...
                                 'userdata',{filename,ii},...
                                 'ButtonDownFcn',@plotThisOSCTrace);
%              ylim([0 600]);
    end

%     FWHMList2 = sortrows(FWHMList2,1);

    
    % hh = figure;
    % scatter(FWHMList1(:,1),FWHMList1(:,2),'LineWidth',2.0);
    % hold on
    % scatter(FWHMList2(:,1),FWHMList2(:,2),'LineWidth',2.0);
    % hold on

    % plot(FWHMList3(:,1),FWHMList3(:,2),'LineWidth',2.0);
    % hold on
    % legend({'10Hz','30Hz','50Hz'});
%     legend({'before reverse','after reverse'});
    xlabel('waveguide Power / mW');
    ylabel('FWHM / MHz');
    title(strcat(num2str(wavelength),'nm'));
    hold on
    % resultdataFileName1 = strcat(filedir,'\','FWHM.fig');
    % resultdataFileName2 = strcat(filedir,'\','FWHM.png');
    % savefig(hh,resultdataFileName1);
    % saveas(hh,resultdataFileName2);

    
    %% fitting begins here
%     outliers = 0;%excludedata()
%     FWHMList1forfit = rmoutliers(FWHMList1,'movmedian',6);
%     FWHMList2forfit = rmoutliers(FWHMList2,'movmedian',6);

%     hh = figure;
    subplot(212)
%     fitIndex1 = 30:41;
%     fitIndex2 = 30:41;
%     FWHMList1forfit = FWHMList1(fitIndex1,:);
%     FWHMList2forfit = FWHMList2(fitIndex2,:);
    fitStartPower = 0.3; % lowest wg power to fit, ensure triangle appears.
    fitEndPower = 2; % highest wg power to fit, ensure no comb appears.
    if wavelength < 1549 && wavelength > 1547 % 1548nm needs seperate start power
        fitStartPower = 0.55; 
    elseif wavelength < 1541 && wavelength > 1539 % 1540nm needs seperate start power
        fitStartPower = 0.7;
    end
    FWHMList1forfit = FWHMList1(FWHMList1(:,1)>fitStartPower,:);
    FWHMList2forfit = FWHMList2(FWHMList2(:,1)>fitStartPower,:);
    FWHMList1forfit = FWHMList1forfit(FWHMList1forfit(:,1)<fitEndPower,:);
    FWHMList2forfit = FWHMList2forfit(FWHMList2forfit(:,1)<fitEndPower,:);
%     FWHMList1forfit = FWHMList1;
%     FWHMList2forfit = FWHMList2;
    scatter(FWHMList1forfit(:,1),FWHMList1forfit(:,2),'LineWidth',2.0);
    hold on
    scatter(FWHMList2forfit(:,1),FWHMList2forfit(:,2),'LineWidth',2.0);
    hold on
    coeff1 = polyfit(FWHMList1forfit(:,1),FWHMList1forfit(:,2),1);
    coeff2 = polyfit(FWHMList2forfit(:,1),FWHMList2forfit(:,2),1);
    FWHMfit1 = coeff1(1)*FWHMList1forfit(:,1)+coeff1(2);
    FWHMfit2 = coeff2(1)*FWHMList2forfit(:,1)+coeff2(2);
    plot(FWHMList1forfit(:,1),FWHMfit1,'--','LineWidth',2.0);
    hold on
    plot(FWHMList2forfit(:,1),FWHMfit2,'--','LineWidth',2.0);
    meanSlope(count) = sqrt( coeff1(1)* coeff2(1) ) % in MHz/mW
    xlabel('waveguide Power / mW');
    ylabel('FWHM / MHz');
    title(strcat(num2str(wavelength),'nm'));
    pause(1);

end
save(strcat(filedirGolb,'meanSlope.mat'),'meanSlope');


%% ------------20200804 Tantala ---------
c = 299792458;
n0 = 2.275;
r = 43.4e-6;
nT = 8.8e-6;
% Aeff and dTdP from simulation
Aeff = 0.934e-12;
dTdP = 1685;%1570;
for count = 1:length(wavelengthList)
    %%
    load(strcat(filedirGolb,'meanSlope.mat'),'meanSlope');
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
    
            % ------Test with n2kerr from paper arxiv: 2007.12958------
            g=1*alpha;
            n2TOT=g*n0^2*Aeff*2*pi*r/omega/c;
            n2TOTList(count) = n2TOT;
            n2Kerr = 6.223e-19;
            kerrOverTotal = n2Kerr/n2TOT;
            kerrOverTotalList(count) = kerrOverTotal;
            % -----Temp test code ends, 20200805-----

    Qabs = QabsAndKerr/(1-kerrOverTotal);
    QabsList(count) = Qabs;
    
    
%     %% Calculate n2 over coupling here
%     Qtot = QtotList(count);
%     Qext = QextList(count);
% 
%     c = 299792458;
%     lambda = wavelength * 1e-9; % normalize ti SI unit
%     omega=c/lambda*2*pi;
%     n0=2.8639;
%     kappa = c/lambda/Qtot*2*pi; % in rad/s
%     ita = 1 - Qtot/Qext;
%     r = 719.38e-6;
%     Aeff = 2.540e-13;
% 
%     alpha = meanSlope(count)*2*pi*1e6/1e-3* kappa/2/ita ;
% 
%     kerrOverTotal = kerrOverTotalList(count);
%     g=(kerrOverTotal)*alpha;
%     n2=g*n0^2*Aeff*2*pi*r/omega/c;
% 
%     n2ListOC(count) = n2 * 0.8737;
% 
%     nT = 2.3e-4;
%     dTdP = 88.354;
%     QabsAndKerr = nT * dTdP *(2*pi*c/lambda)^2/n0/alpha;
%     Qabs = QabsAndKerr/(1-kerrOverTotal);
% 
%     QabsListOC(count) = Qabs;

end


% %% ------------2020020? ---------
% for count = 1:length(wavelengthList)
%     %%
%     load(strcat(filedirGolb,'meanSlope.mat'),'meanSlope');
%     wavelength = wavelengthList(count);
%     
%     %% Calculate n2 here
%     Qtot = QtotList(count);
%     Qext = QextList(count);
% 
%     c = 299792458;
%     lambda = wavelength * 1e-9; % normalize ti SI unit
%     omega=c/lambda*2*pi;
%     n0 = 2.8639;
%     kappa = c/lambda/Qtot*2*pi; % in rad/s
%     ita = Qtot/Qext;
%     r = 719.38e-6;
%     Aeff = 2.540e-13;
% 
%     alpha = meanSlope(count)*2*pi*1e6/1e-3* kappa/2/ita ;
% 
%     kerrOverTotal = kerrOverTotalList(count);
%     g=(kerrOverTotal)*alpha;
%     n2=g*n0^2*Aeff*2*pi*r/omega/c;
% 
%     n2List(count) = n2 * 0.8737;
% 
%     nT = 2.3e-4;
%     dTdP = 88.354;
%     QabsAndKerr = nT * dTdP *(2*pi*c/lambda)^2/n0/alpha;
%     
%     Qabs = QabsAndKerr/(1-kerrOverTotal);
%     QabsList(count) = Qabs;
%     
%     
%     %% Calculate n2 over coupling here
%     Qtot = QtotList(count);
%     Qext = QextList(count);
% 
%     c = 299792458;
%     lambda = wavelength * 1e-9; % normalize ti SI unit
%     omega=c/lambda*2*pi;
%     n0=2.8639;
%     kappa = c/lambda/Qtot*2*pi; % in rad/s
%     ita = 1 - Qtot/Qext;
%     r = 719.38e-6;
%     Aeff = 2.540e-13;
% 
%     alpha = meanSlope(count)*2*pi*1e6/1e-3* kappa/2/ita ;
% 
%     kerrOverTotal = kerrOverTotalList(count);
%     g=(kerrOverTotal)*alpha;
%     n2=g*n0^2*Aeff*2*pi*r/omega/c;
% 
%     n2ListOC(count) = n2 * 0.8737;
% 
%     nT = 2.3e-4;
%     dTdP = 88.354;
%     QabsAndKerr = nT * dTdP *(2*pi*c/lambda)^2/n0/alpha;
%     Qabs = QabsAndKerr/(1-kerrOverTotal);
% 
%     QabsListOC(count) = Qabs;
% 
% end

%%

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
ylim([0 10]*1e6)
title("Qabs for different wavelength");
% legend({'under couple'})
% legend({'under couple','over couple'})

%%
% tt = rmoutliers(FWHMList1,'movmedian',6);
% close all;
% scatter(tt(:,1),tt(:,2),'LineWidth',2.0);
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
end
