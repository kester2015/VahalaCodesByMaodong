clc
clear
f = [0.1 0.2 0.3 0.5 0.8 1.0 1.5 2.0 2.5 3.0 4.0 5.0 7.0 8.0 10 13 15 20 ...
    30 50 80 100 300 500 800 1000];
load('Parameters.mat');
load('alpha.mat');
figure
kappa_t = [6:0.2:8]*2*pi;
for m = 1 : size(kappa_t, 2)
    res_error(m) = get_kappa_error(kappa_t(m)); % Square
end
hold on
plot(kappa_t/2/pi, res_error, '-s');
xlabel('\kappa_{t} (Hz)');
ylabel('Residual error');
COE = polyfit(kappa_t, res_error, 2);
plot(kappa_t/2/pi, polyval(COE, kappa_t));
[~, locs] = min(res_error);
kappa_std = sqrt(res_error(locs)/length(f))/sqrt(1/2*COE(1));
disp(['kappa_t error: ', num2str(kappa_std/2/pi)]);
% kappa_t = fminsearch(@(kappa_t) get_kappa_error(kappa_t), 70*2*pi, 'MaxFunEvals', 1);
% save('Res_error2.mat', 'kappa_t', 'res_error');
%%
kappa_t = 10*2*pi;
alpha = coe(1)*(kappa/2/eta/D1);
Q_abs = 1/n0*beta*omega0^2/D1/alpha/kappa_t/C;
Q_abs0 = 1/n0*beta*omega0^2/D1/alpha/C0;
c0 = 299792458;
l = 1e4*omega0/Q_abs/c0*n0*log10(exp(1));
l0 = 1e4*omega0/Q_abs0/c0*n0*log10(exp(1));
disp(['Q_abs form undercut: ', num2str(Q_abs/1e12), 'trillion']);
disp(['Intrinsic loss from undercut: ', num2str(l), 'dB/km']);
disp(['Q_abs form simulation: ', num2str(Q_abs0/1e9), 'billion']);
disp(['Intrinsic loss from simulation: ', num2str(l0), 'dB/km']);
for m = 1 : N
    for n = 1 : 3
        filename = strcat('D', num2str(m), '_', num2str(n), '.mat');
        [delta_p1, P_out1, v1(n)] = Get_delta(filename);
        [~, FWHM11(n)] = Get_FWHM(filename);
        FWHM11(n) = FWHM11(n)*FSR;
    end
    %%
    v(m) = mean(v1);
    v_std(m) = std(v1);
    FWHM1(m) = mean(FWHM11);
    FWHM1_std(m) = std(FWHM11);
    %%
    [delta_p2, P_out2, FWHM2(m)] = Get_dynamics(kappa_t, v(m));
    [dip_y1, dip_x1] = min(P_out1);
    delta_p1 = delta_p1 - delta_p1(dip_x1);
    [dip_y2, dip_x2] = min(P_out2);
    delta_p2 = delta_p2 - delta_p2(dip_x2);
    figure
    hold on
    plot(delta_p1, P_out1);
    plot(delta_p2, P_out2);
    xlabel('Detuning (MHz)');
    ylabel('Output power (mW)');
end
figure
loglog(f, v, 's');
xlabel('Scanning frequecny (Hz)');
ylabel('Scanning speed (MHz/s)');
%%
% close all
figure
errorbar(v, FWHM1/1e6, FWHM1_std/1e6, '-s');
set(gca,'XScale','log');
hold on
semilogx(v, FWHM2/1e6, '-s');
xlabel('Scanning speed (MHz/s)');
ylabel('FWHM (MHz)');
% save('Scanning_fitting.mat', 'v', 'FWHM1', 'FWHM2');