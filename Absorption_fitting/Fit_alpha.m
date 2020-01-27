clc
clear
%% Load and define parameters
load('Parameters.mat');
% 1 V AOM
% OSC (mV): 284.631 284.779 284.518 285.437 285.261 285.575
% In: 217.0 uW; Out: 138.6 uW
%% Fit FWHM 
for m = 1 : M
    for n = 1 : 3
        filename = strcat('M', num2str(m), '_', num2str(n), '.mat');
        [Base1(n), count(n)] = Get_FWHM(filename);
        FWHM1(n) = FSR*count(n)*2*pi;
%     alpha(m) = kappa/2/D1/eta*(FWHM(m)-kappa/2)/P_in(m);
    end
    Base(m) = mean(Base1);
    Base_std(m) = std(Base1);
    P_in(m) = Base(m)*V2P;
    P_in_std(m) = sqrt((Base_std(m)*V2P)^2 + (V2P_std*P_in(m))^2);
    FWHM(m) = mean(FWHM1);
    FWHM_std(m) = std(FWHM1);
end
figure
%% Linear fitting 
[coe, S] = polyfit(P_in, FWHM, 1);
% alpha_std = polyparci(coe, S, 0.683);
[~, alpha_std] = linfitxy(P_in, FWHM, P_in_std, FWHM_std);
alpha_std = alpha_std(1);
clc
figure
hold on
errorbar(P_in, FWHM/2/pi, FWHM_std/2/pi, 's');
plot(P_in, polyval(coe, P_in)/2/pi, '--');
disp(strcat('1mW on fiber ->', num2str(2*coe(1)/2/pi/1e6), '+\-', num2str(2*alpha_std/2/pi/1e6), 'MHz thermal broadening'));
disp(strcat(num2str(2*coe(1)*(kappa/2/eta/D1)/2/pi), 'Hz/mW in cavity'));
%% Hz/mW on fiber
% alpha = alpha/(kappa/4/eta/D1)/2/pi;
% figure
% plot(alpha);
% mean(alpha)
% alpha_var = sqrt(var(alpha));
% alpha = mean(alpha);
save('alpha.mat', 'coe', 'alpha_std');
alpha = coe(1)*(kappa/2/eta/D1);
Q_abs0 = 1/n0*beta*omega0^2/D1/alpha/C0;
c0 = 299792458;
l0 = 1e4*omega0/Q_abs0/c0*n0*log10(exp(1));
disp(['Q_abs form simulation: ', num2str(Q_abs0/1e12), '+\-', num2str(alpha_std/coe(1)*Q_abs0/1e12), 'trillion']);
disp(['Intrinsic loss from simulation: ', num2str(l0), 'dB/km']);
% save('Broadening_data.mat', 'P_in', 'FWHM');