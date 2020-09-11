
n2_1543 = sqrt(1.6685*1.6379)*1e-19;
n2_1551 = sqrt(1.6374*2.3275)*1e-19;

n2 = mean([n2_1543 n2_1551]);

tt = table2array(readtable('Z:\Qifan\Tantala\VNA experiment\20200909\kerroverthermal.xlsx'));
lambdaList = tt(:,1);
kerrOverTotalList = tt(:,2);
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

QabsList = (2*pi*c./lambdaList*1e9) * dTdP * nT * neff * (2*pi*r*Aeff) / c / n2 ./ alphaOverGList;


figure
scatter(lambdaList ,QabsList/1e6);
xlabel('lambda / nm');
ylabel('Q abs / M')
title('Qabs fitting result at different wavelength')
ylim([0 8])

