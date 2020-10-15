close all
clear
clc
%%
% % % ----------CODES CLEAN UP BEGINS HERE------------
%     wavelength = 1551.4;
%     lambda = wavelength;
%     outputVoltage1 = 2.68; %V
%     outputPower1 = 0.971;%mW
%     inputPower1 = 8.560;%mW
%     outputVoltage2 = 2.45; %V
%     outputPower2 = 0.898;%mW
%     inputPower2 = 8.726;%mW
%     Q_data_filename = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\Q-maxvpp-redo-1551.325nm.mat';
%     filedirGlob = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\1551.4nm-02-mat';
%     kerrOverTotal = 0.0174;
    
    
    wavelength = 1560;
    lambda = wavelength;
    outputVoltage1 = 2.71; %V
    outputPower1 = 1.181;%mW
    inputPower1 = 7.820;%mW
    outputVoltage2 = 2.62; %V
    outputPower2 = 1.123;%mW
    inputPower2 = 7.737;%mW
    Q_data_filename = 'Z:\Qifan\LN\20201008-Screen-Modes\No.-1\Q-measure-maxvpp-1560.05nm.mat';
    filedirGlob = 'Z:\Qifan\LN\20201008-thermal-rawdata\No.-1_test\1560nm-01-mat';
    kerrOverTotal = 0.0193;
%%

% filedirGlob = 'Z:\Qifan\Tantala\20200906-thermal-rawdata\Dev21\1551.4nm-01-mat';
% filedirGlob = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Dev21\1543.5nm-02-mat';
powerList = 2.0:-0.1:0.3;
powerList = [1.5 1 0.5 0]
lambda = wavelength;

[mode_Q0, mode_Qe,~,~] = getQwithFP(Q_data_filename);

%%
close all
sweep_voltage = 10;
fitting_results = zeros(length(powerList),10);
% fitting_results = zeros(1,7);

fitting_results(:,1) = powerList';
for ii = 1:length(powerList)
    pp = powerList(ii);
    close all
    this_filename = strcat(filedirGlob,'\Sweep_',num2str(sweep_voltage),'Hz_Power_',num2str(pp),'V.mat');
    temp = fitTriwithFP(this_filename,mode_Q0, mode_Qe,lambda,1);
    fitting_results(ii,2:end) = temp;
%     accept_ask = input("Do you accept this fitting result? (Yes:1, No:0): ");
%     if accept_ask == 1
%         fitting_results(end+1,1) = pp;
%         fitting_results(end+1,2:end) = temp;
%     end
   fprintf('voltage: %g ',pp);
end

save(strcat(filedirGlob,'\Fitting_results\coefficients_',num2str(sweep_voltage),'V.mat'),'fitting_results');

%%
% close all
% filedirGlob = 'C:\Users\leona\iCloudDrive\Work\data\1543.5nm-02-mat';
% load(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');
sweep_voltage = 10;

load(strcat(filedirGlob,'\Fitting_results\coefficients_',num2str(sweep_voltage),'V.mat'),'fitting_results');

%     Qabs_est = 3 * 1e6;
% % ------------- 20200819 Tantala --------------
    c = 299792458;
    % n0 = 2.0573;
    neff = 1.8373;% wavegudie neff
    n0 = neff;
    r = 109.5e-6;
    nT = 10.46e-6;
    % Aeff and dTdP from simulation
    Aeff = 1.0575e-12;
    %dTdP = 613;%1685;%1570;
    dTdP = 655; % on waveguide absorption loss. Thermal conductivity k_tantala used =50W/(m*k)
    correct_qabs = 0.94583; % Qabs = Qmaterial/correct_qabs, only part of abs limit is contributed by material.
    
    D1 = 2*pi*192504.13 * 1e6; % in Hz/2/pi (rad).
    
    
    
    
    power_corr_factor = (1 - abs( fitting_results(:,3) ) );
    
%     PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
%     PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;

   if str2double(filedirGlob(end-4)) == 1
        PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;
   elseif str2double(filedirGlob(end-4)) == 2
        PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
   end
   
    alpha_each_volt = fitting_results(:,end)/PoverV;
    
%     Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./((1-kerrOverTotal)*alpha_each_volt);
    Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./(                  alpha_each_volt);

    Qabs_each_volt = Qabs_each_volt./power_corr_factor;
    
    n2_each_volt  = 2*pi*neff*Aeff*(kerrOverTotal*alpha_each_volt)/(2*pi*c/lambda*1e9)/D1;
    
    
%     n2_each_volt = kerrOverTotal * n0 * (2*pi*r*Aeff) * (2*pi*c/lambda*1e9)./Qabs_each_volt *dTdP * nT/c;


% figure
scatter(fitting_results(:,2),Qabs_each_volt/1e6);
hold on
xlabel('OSC voltage / V');
ylabel('Q abs / M')
title('Qabs fitting result at different voltage')

% figure
% scatter(fitting_results(:,2),n2_each_volt);
% xlabel('OSC voltage / V');
% ylabel('n2');
% title('n2 fitting result at different voltage')
