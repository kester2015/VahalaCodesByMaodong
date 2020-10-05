close all
clear
clc
MZI_FSR = 39.9553; % MHz
%%
% % % % ------------ 20200930 SiN-----------
for scan_round = [2 1]
for sweep_voltage = [0.5]
for wavelength = [1550.2 1555] %[1544.1 1552.2 1556.4 1560.9 1564.8]

        % % % ------------1541 
%         wavelength = 1544.1;
        lambda = wavelength;
        outputVoltage1 = 2.6137; %V
        outputPower1 = 0.2154;%mW
        inputPower1 = 1.071;%mW
        outputVoltage2 = 1.9865; %V
        outputPower2 = 0.1530;%mW
        inputPower2 = 1.063;%mW
        Q_data_filename = strcat('Z:\Qifan\SiN\20201004-Screen-Modes\Q-measure-maxvpp-0.5Hz-1.7Vpp-',num2str(wavelength),'nm.mat');
        filedirGlob = strcat('Z:\Qifan\SiN\20201004-thermal-rawdata\No14\1544.1nm-01-mat');

        filedirGlob = strcat('Z:\Qifan\SiN\20201004-thermal-rawdata\No14\',num2str(wavelength),'nm-0',num2str(scan_round),'-mat');

        kerrOverTotal = 1/(1+1);


    %%

    % filedirGlob = 'Z:\Qifan\Tantala\20200906-thermal-rawdata\Dev21\1551.4nm-01-mat';
    % filedirGlob = 'Z:\Qifan\Tantala\20200905-thermal-rawdata\Dev21\1543.5nm-02-mat';
    powerList = 2.0:-0.1:0.3;
    powerList = 0.1:+0.1:2.0;
    [mode_Q0, mode_Qe,~,~] = getQwithFP(Q_data_filename);



    %%
    close all
    % sweep_voltage = 1;
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
    load(strcat(filedirGlob,'\Fitting_results\coefficients_',num2str(sweep_voltage),'V.mat'),'fitting_results');

    % % ------------- 20200915 redo AlGaAs --------------
    % fitting_results = zeros(size(fitres1))
    % fitting_results(1,:) = fitres1;
    % fitting_results(2,:) = fitres2;

        c = 299792458;
        neff = 1.8889;
        n0 = neff;


        nT = 2.6307e-05;
        % Aeff and dTdP from simulation
        Aeff = 1.498e-12;
        dTdP = 95.3;%88.354;%1685;%1570;

        D1 = 2*pi*40.528*1e9; % in Hz/2/pi (rad).


        power_corr_factor = 1;

    %     power_corr_factor = (1 - abs( fitting_results(:,3) ) );    


       if str2double(filedirGlob(end-4)) == 1
            PoverV = (sqrt(inputPower1*outputPower1)*1e-3)/outputVoltage1;
       elseif str2double(filedirGlob(end-4)) == 2
            PoverV = (sqrt(inputPower2*outputPower2)*1e-3)/outputVoltage2;
       end


        alpha_each_volt = fitting_results(:,end)/PoverV;
        Qabs_each_volt = nT * dTdP *(2*pi*c/lambda*1e9)^2/n0./alpha_each_volt;

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
    % 
    %             figure
    %             scatter(fitting_results(:,2),fitting_results(:,3));
    %             hold on
    %             scatter(fitting_results(:,2),fitting_results(:,4));
    %             xlabel('OSC voltage / V');
    %             ylabel('Q / M');
    %             title('Check Q0 and Qe for different power')
    %             legend({'Q0','Qe'},'location','best')


                results_each_volt = [fitting_results(:,2), Qabs_each_volt/1e6, n2_each_volt ];
                tt = strfind(filedirGlob,'\');
                file_tosave = strcat(filedirGlob(1:tt(end)),num2str(lambda),'nm-',filedirGlob(end-5:end-4),'.mat');
                save(file_tosave,'results_each_volt');

end
end
end