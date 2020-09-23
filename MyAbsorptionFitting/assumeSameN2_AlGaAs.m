close all
clear
clc
%%
n2_1554 = sqrt(1.3592*1.8273)*1e-17;
n2_1560 = sqrt(2.4061*1.1336)*1e-17;

n2 = mean([n2_1554 n2_1560]);

% n2 = 6.223e-19;

tt = table2array(readtable('Z:\Qifan\AlGaAs\VNA experiment\20200916\kerroverthermal.xlsx'));
lambdaList = tt(:,1);
kerrOverTotalList = tt(:,2)./(tt(:,2)+1);
alphaOverGList = 1./kerrOverTotalList -1;

% QabsList = zeros(size(lambdaList));


    c = 299792458;
    neff = 3.3;
    n0 = neff;
    r = 719.38e-6;
    nT = 2.1913e-04;
    % Aeff and dTdP from simulation
    Aeff = 2.63e-13;
    dTdP = 90.7286;%88.354;%1685;%1570;
    
    D1 = 2*pi*17929.82 * 1e6; % in Hz/2/pi (rad).
    

QabsList = (2*pi*c./lambdaList*1e9) * dTdP * nT * neff * (2*pi*r*Aeff) / c / n2 ./ alphaOverGList;


figure
scatter(lambdaList ,QabsList/1e6);
hold on
scatter(lambdaList, tt(:,3),'*');
xlabel('lambda / nm');
ylabel('Q abs(WG) / M')
legend({'Q abs','Q0'})
title('Qabs fitting result at different wavelength')
ylim([0 4])

