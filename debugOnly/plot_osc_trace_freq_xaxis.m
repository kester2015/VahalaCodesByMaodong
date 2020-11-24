close all
clear
clc
%%
load('Z:\Maodong\Projects\Pulse Pumping\AlGaAs\20201120\comb\zoom-in-pulse pumping-1550.1nm.mat')
figure
mzi_phase = MZI2Phase(Y(:,3));
mzi_fsr = 39.9553; % MHz
mzi_freq = mzi_phase/2/pi*mzi_fsr;
plot(mzi_freq, Y(:,4),'DisplayName','Trans');
hold on
plot(mzi_freq, Y(:,2)*0.75,'DisplayName','Comb');
xlabel('Freq / MHz (center 1550.1nm)');
ylabel('Voltage / V');
legend('location','best')
set(gca,'tickdir','out');
set(gca,'box','on')


