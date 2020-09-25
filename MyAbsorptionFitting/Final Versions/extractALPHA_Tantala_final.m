close all
clear
clc
%%
% Copy this file to Z:\Qifan\Tantala\Tantala final results\broadening measurement
% For finally backup.

%%
% % % ----------CODES CLEAN UP BEGINS HERE------------
    wavelength = 1551.4;
    lambda = wavelength;
    outputVoltage1 = 2.68; %V
    outputPower1 = 0.971;%mW
    inputPower1 = 8.560;%mW
    outputVoltage2 = 2.45; %V
    outputPower2 = 0.898;%mW
    inputPower2 = 8.726;%mW
    Q_data_filename = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\Q-maxvpp-redo-1551.325nm.mat';
    filedirGlob = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\1551.4nm-01-mat';
    kerrOverTotal = 0.0174;
    
    
%     wavelength = 1543.5;
%     lambda = wavelength;
%     outputVoltage1 = 2.71; %V
%     outputPower1 = 1.181;%mW
%     inputPower1 = 7.820;%mW
%     outputVoltage2 = 2.62; %V
%     outputPower2 = 1.123;%mW
%     inputPower2 = 7.737;%mW
%     Q_data_filename = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\Q-maxvpp-1543.5nm.mat';
%     filedirGlob = 'Z:\Qifan\Tantala\Tantala final results\broadening measurement\1543.5nm-01-mat';
%     kerrOverTotal = 0.0193;
%%

powerList = 2.0:-0.1:0.3;

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
% close all
load(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');
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
    
    
    power_corr_factor = (1 - abs( fitting_results(:,3) ) );
    

   if str2double(filedirGlob(end-4)) == 1
        PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;
   elseif str2double(filedirGlob(end-4)) == 2
        PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
   end
   
    alpha_each_volt = fitting_results(:,end)/PoverV;
    
%     Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./((1-kerrOverTotal)*alpha_each_volt);
    Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./( alpha_each_volt);

    Qabs_each_volt = Qabs_each_volt./power_corr_factor;
    
    n2_each_volt  = 2*pi*neff*Aeff*(kerrOverTotal*alpha_each_volt)/(2*pi*c/lambda*1e9)/D1;
    
    
    
%     n2_each_volt = kerrOverTotal * n0 * (2*pi*r*Aeff) * (2*pi*c/lambda*1e9)./Qabs_each_volt *dTdP * nT/c;


figure
scatter(fitting_results(:,2),Qabs_each_volt/1e6);
xlabel('OSC voltage / V');
ylabel('Q abs / M')
title('Qabs fitting result at different voltage')

figure
scatter(fitting_results(:,2),n2_each_volt);
xlabel('OSC voltage / V');
ylabel('n2');
title('n2 fitting result at different voltage')
