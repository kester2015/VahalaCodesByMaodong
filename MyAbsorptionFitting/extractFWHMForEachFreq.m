close all
clear
clc

MZID1 = 39.9553; %MHz
%%

filedir = "D:\Measurement Data\Absorption project\20200130\1540nm-01-mat";
matfiles = dir(strcat(filedir,'\*.mat') );
extractFreq = 50; % Hz
FWHMList1 = zeros(length(matfiles),2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPowerinput] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        
        
        FWHM = FWHM*MZID1; %MHz
        
        
        load(filename,'Ch1','Ch4');
        Ch1 = max(Ch1);
        Ch4 = max(Ch4);
        
        EOMPower = sqrt(Ch1*Ch4)*sqrt(4.156*0.3374)/sqrt(1.76*1.82) ;
        
        FWHMList1(jj,:) = [EOMPower FWHM];
        
        jj = jj + 1;
    end
end
FWHMList1 = sortrows(FWHMList1,1);


FWHMList1 = FWHMList1(8:end-4,:)

%%

filedir = "D:\Measurement Data\Absorption project\20200130\1540nm-02-mat";
matfiles = dir(strcat(filedir,'\*.mat') );
extractFreq = 50; % Hz
FWHMList2 = zeros(length(matfiles),2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPowerinput] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        
        
        FWHM = FWHM*MZID1; %MHz
        
        load(filename,'Ch1','Ch4');
        Ch1 = max(Ch1);
        Ch4 = max(Ch4);
        
        EOMPower = sqrt(Ch1*Ch4)*sqrt(4.204*0.2839)/sqrt(1.746*1.565) ;
        
        FWHMList2(jj,:) = [EOMPower FWHM];
        
        jj = jj + 1;
    end
end
FWHMList2 = sortrows(FWHMList2,1);


FWHMList2 = FWHMList2(3:end-4,:)

%%
% extractFreq = 30; % Hz
% FWHMList2 = zeros(6,2);
% jj = 1;
% for ii = 1:length(matfiles)
%     filename = strcat(filedir, '\', matfiles(ii).name);
%     [sweepFreq, EOMPower] = extractFreqAndPower(filename);
%     if sweepFreq == extractFreq
%         [~,FWHM] = getFWHM(filename);
%         FWHMList2(jj,:) = [EOMPower FWHM];
%         jj = jj + 1;
%     end
% end
% FWHMList2 = sortrows(FWHMList2,1);
% 
% %%
% extractFreq = 50; % Hz
% FWHMList3 = zeros(6,2);
% jj = 1;
% for ii = 1:length(matfiles)
%     filename = strcat(filedir, '\', matfiles(ii).name);
%     [sweepFreq, EOMPower] = extractFreqAndPower(filename);
%     if sweepFreq == extractFreq
%         [~,FWHM] = getFWHM(filename);
%         FWHMList3(jj,:) = [EOMPower FWHM];
%         jj = jj + 1;
%     end
% end
% FWHMList3 = sortrows(FWHMList3,1);

%%
hh = figure;
scatter(FWHMList1(:,1),FWHMList1(:,2),'LineWidth',2.0);
hold on
scatter(FWHMList2(:,1),FWHMList2(:,2),'LineWidth',2.0);
hold on
% plot(FWHMList3(:,1),FWHMList3(:,2),'LineWidth',2.0);
% hold on
% legend({'10Hz','30Hz','50Hz'});
legend({'before reverse','after reverse'});
xlabel('waveguide Power / mW');
ylabel('FWHM / MHz');

% resultdataFileName1 = strcat(filedir,'\','FWHM.fig');
% resultdataFileName2 = strcat(filedir,'\','FWHM.png');
% savefig(hh,resultdataFileName1);
% saveas(hh,resultdataFileName2);

%% fitting begins here

coeff1 = polyfit(FWHMList1(:,1),FWHMList1(:,2),1);
coeff2 = polyfit(FWHMList2(:,1),FWHMList2(:,2),1);
FWHMfit1 = coeff1(1)*FWHMList1(:,1)+coeff1(2);
FWHMfit2 = coeff2(1)*FWHMList2(:,1)+coeff2(2);
plot(FWHMList1(:,1),FWHMfit1,'--','LineWidth',2.0);
hold on
plot(FWHMList2(:,1),FWHMfit2,'--','LineWidth',2.0);
meanSlope = sqrt( coeff1(1)* coeff2(1) ) % in MHz/mW


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
