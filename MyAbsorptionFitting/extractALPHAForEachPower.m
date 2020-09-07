close all
clear
clc
%%
% % %------20200819 Tantala-----------%
% %1535nm
% % filedirGolb = strcat("Z:\Qifan\Tantala\20200819-thermal-rawdata\Dev21\");
% wavelengthList     = [1540   1545   1551   1556   1561];%1535:10:1555;
% outputVoltage1List = [1.855  1.819  2.373  3.064  2.245];
% outputPower1List   = [1.154  1.122  1.860  2.298  1.894];%[1.221 1.637 1.846];%mW
% inputVoltage1List  = [2.960  3.665  3.643  3.916  3.457];%[1.77296 2.2588 2.4366]; %V
% inputPower1List    = [12.11  15.20  15.90  16.80  14.90];%[8.421 11.17 12.17];%mW
% outputVoltage2List = [1.767  2.020  2.313  3.003  2.527];%[0.89960 1.2781 1.1564]; %V
% outputPower2List   = [1.112  1.292  1.620  2.355  2.047];%[1.196 1.489 1.704];%mW
% inputVoltage2List  = [2.973  3.731  3.810  3.950  3.453];%[1.773 2.1937 2.4256]; %V
% inputPower2List    = [12.46  15.30  15.90  15.58  15.16];%[8.548 10.55 12.24];%mW
% % QtotList           = [1.501  1.307  2.027  1.413  1.688]*1e6;
% % QextList           = [9.465  5.879  7.543  4.255  5.897]*1e6;
% realwavelengthList = [1540.4 1545.1 1551.4 1556.2 1561.0];
% kerrOverTotalList  = [0.0353 0.0390 0.0332 0.0349 0.0353]/2;
% 
% count = 5;
%     wavelength = wavelengthList(count);
%     outputVoltage1 = outputVoltage1List(count); %V
%     outputPower1 = outputPower1List(count);%mW
%     inputVoltage1 = inputVoltage1List(count); %V
%     inputPower1 = inputPower1List(count);%mW
%     outputVoltage2 = outputVoltage2List(count); %V
%     outputPower2 = outputPower2List(count);%mW
%     inputVoltage2 = inputVoltage2List(count); %V
%     inputPower2 = inputPower2List(count);%mW
    
%     wavelength = 1541.9;
%     outputVoltage1 = 2.4; %V
%     outputPower1 = 3.196;%mW
%     inputPower1 = 24.30;%mW
%     outputVoltage2 = 2.1; %V
%     outputPower2 = 2.676;%mW
%     inputPower2 = 18.69;%mW
%       Q_data_filename = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Q-maxvpp-redo-1541.9nm.mat';
    
    wavelength = 1543.5;
    outputVoltage1 = 2.71; %V
    outputPower1 = 1.181;%mW
    inputPower1 = 7.820;%mW
    outputVoltage2 = 2.62; %V
    outputPower2 = 1.123;%mW
    inputPower2 = 7.737;%mW
    Q_data_filename = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Q-maxvpp-1543.5nm.mat';

%     wavelength = 1547;
%     outputVoltage1 = (2.106+2.16)/2; %V
%     outputPower1 = 2.764;%mW
%     inputPower1 = 37.63;%mW
%     outputVoltage2 = 1.01; %V
%     outputPower2 = 1.374;%mW
%     inputPower2 = 23.18;%mW
%     Q_data_filename = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Q-maxvpp-after-1546.65nm.mat';
    
    kerrOverTotal = 0.0353/2;
%%

filedirGlob = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Dev21\1543.5nm-02-mat';
powerList = 2.2:-0.3:0.3;

lambda = wavelength;

[mode_Q0, mode_Qe,~,~] = getQwithFP(Q_data_filename);


%%
close all

fitting_results = zeros(length(powerList),10);
fitting_results(:,1) = powerList';
for ii = 1:length(powerList)
    pp = powerList(ii);
    close all
    this_filename = strcat(filedirGlob,'\Sweep_20Hz_Power_',num2str(pp),'V.mat');
    fitting_results(ii,2:end) = fitTriwithFP(this_filename,mode_Q0, mode_Qe,lambda,1);
end

save(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');

%%
close all
% filedirGlob = 'C:\Users\leona\iCloudDrive\Work\data\1543.5nm-02-mat';
% load(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');
%     Qabs_est = 3 * 1e6;
    c = 299792458;
    % n0 = 2.0573;
    neff = 1.8373;
    n0 = neff;
    r = 109.5e-6;
    nT = 10.46e-6;
    % Aeff and dTdP from simulation
    Aeff = 1.0575e-12;
    dTdP = 613;%1685;%1570;
    
    
    power_corr_factor = (1 - abs( fitting_results(:,3) ) );
    
    PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;


    alpha_each_volt = fitting_results(:,end)/PoverV;
    Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./alpha_each_volt;
    
    Qabs_each_volt = Qabs_each_volt./power_corr_factor;
    
    
    n2_each_volt = 0.0353/2 * n0 * (2*pi*r*Aeff) * (2*pi*c/lambda*1e9)./Qabs_each_volt *dTdP * nT/c;
    


figure
plot(fitting_results(:,1),Qabs_each_volt/1e6);
xlabel('voltage / V');
ylabel('Q abs / M')
title('Qabs fitting result at different voltage')

figure

plot(fitting_results(:,1),n2_each_volt);
xlabel('voltage / V');
ylabel('n2');
title('n2 fitting result at different voltage')
