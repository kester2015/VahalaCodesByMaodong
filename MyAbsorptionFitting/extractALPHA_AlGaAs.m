close all
% clear
clc
MZI_FSR = 39.9553; % MHz
%%
% % % % ------------ 20200915 redo AlGaAs -----------
%
    wavelength = 1535.4;
    lambda = wavelength;
    outputVoltage1 = 2.551; %V
    outputPower1 = 0.4539;%mW
    inputPower1 = 3.846;%mW
    outputVoltage2 = 2.600; %V
    outputPower2 = 0.4311;%mW
    inputPower2 = 3.750;%mW
    Q_data_filename = 'Z:\Qifan\AlGaAs\20200915-thermal-rawdata\redo-after-1535.4nm.mat';
    filedirGlob = 'Z:\Qifan\AlGaAs\20200915-thermal-rawdata\No5\1535.4nm-01-mat';
    kerrOverTotal = 0.0681;
%%

% filedirGlob = 'Z:\Qifan\Tantala\20200906-thermal-rawdata\Dev21\1551.4nm-01-mat';
% filedirGlob = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Dev21\1543.5nm-02-mat';
powerList = 2.0:-0.1:0.3;

load(Q_data_filename,'data_matrix');
Q_obj = Q_trace_fit(data_matrix(:,2),data_matrix(:,3),MZI_FSR,wavelength, 0.4,'fanomzi'); % 0.4 is sensitivity
mode_Q = Q_obj.get_Q;
mode_Q0 = mode_Q(1)
mode_Qe = mode_Q(2)


%%
close all

fitting_results = zeros(length(powerList),7);
fitting_results(:,1) = powerList';
for ii = 1:length(powerList)
    pp = powerList(ii);
    close all
    this_filename = strcat(filedirGlob,'\Sweep_20Hz_Power_',num2str(pp),'V.mat');
    fitting_results(ii,2:end) = fitTriFlatBG(this_filename,mode_Q0, mode_Qe,lambda,1);
end

save(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');

%%
% close all
% filedirGlob = 'C:\Users\leona\iCloudDrive\Work\data\1543.5nm-02-mat';
load(strcat(filedirGlob,'\Fitting_results\coefficients.mat'),'fitting_results');

% % ------------- 20200915 redo AlGaAs --------------
    c = 299792458;
    neff = 3.3;
    n0 = neff;
    r = 719.38e-6;
    nT = 2.1913e-04;
    % Aeff and dTdP from simulation
    Aeff = 2.63e-13;
    dTdP = 88.354;%1685;%1570;
    
    %%
    
    power_corr_factor = 1;
    
   if str2double(filedirGlob(end-4)) == 1
        PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;
   elseif str2double(filedirGlob(end-4)) == 2
        PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
   end


    alpha_each_volt = fitting_results(:,end)/PoverV;
    Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./alpha_each_volt;
    
    Qabs_each_volt = Qabs_each_volt./power_corr_factor;
    
    
    n2_each_volt = kerrOverTotal * n0 * (2*pi*r*Aeff) * (2*pi*c/lambda*1e9)./Qabs_each_volt *dTdP * nT/c;

    

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

            figure
            scatter(fitting_results(:,2),fitting_results(:,3));
            hold on
            scatter(fitting_results(:,2),fitting_results(:,4));
            xlabel('OSC voltage / V');
            ylabel('Q / M');
            title('Check Q0 and Qe for different power')
            legend({'Q0','Qe'},'location','best')
            
            
            results_each_volt = [fitting_results(:,2), Qabs_each_volt/1e6, n2_each_volt ];
            tt = strfind(filedirGlob,'\');
            file_tosave = strcat(filedirGlob(1:tt(end)),num2str(lambda),'nm-',filedirGlob(end-5:end-4),'.mat');
            save(file_tosave,'results_each_volt');