
n2_1543 = sqrt(2.3026*2.3497)*1e-19;
n2_1551 = sqrt(2.3624*3.2699)*1e-19;

n2 = mean([n2_1543 n2_1551]);

% n2 = 6.223e-19;

tt = table2array(readtable('Z:\Qifan\Tantala\VNA experiment\20200909\kerroverthermal.xlsx'));
lambdaList = tt(:,1);
kerrOverTotalList = tt(:,2)./(tt(:,2)+1);
alphaOverGList = 1./kerrOverTotalList -1;

% QabsList = zeros(size(lambdaList));


c = 299792458;
% n0 = 2.0573;
neff = 1.8373;
n0 = neff;
r = 109.5e-6;
nT = 10.46e-6;
% Aeff and dTdP from simulation
Aeff = 1.0575e-12;
dTdP = 613;%1685;%1570;


D1 = 2*pi*192504.13 * 1e6; % in Hz/2/pi (rad).


% QabsList = (2*pi*c./lambdaList*1e9) * dTdP * nT * neff * (2*pi*r*Aeff) / c / n2 ./ alphaOverGList;
kabsList = (2*pi*c./lambdaList*1e9) *D1*n2 ./ (2*pi*neff*Aeff*dTdP* nT*(2*pi*c./lambdaList*1e9)/neff ) .*alphaOverGList; 

QabsList = (2*pi*c./lambdaList*1e9)./kabsList;


figure
scatter(lambdaList ,QabsList/1e6);
hold on
scatter(lambdaList, tt(:,3),'*');
xlabel('lambda / nm');
ylabel('Q abs(WG) / M')
legend({'Q abs','Q0'})
title('Qabs fitting result at different wavelength')
ylim([0 8])
