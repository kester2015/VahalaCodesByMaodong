clear
close all
clc
c = 299792458;
%%
load('D:\Measurement\pulse pumping\20201123\OSA_Cavity15_PumpPower0.833_Dispersion7.8_RepRate17.91964GHz-1430-1700nm.mat');
    combPower=sgolayfilt(OSAPower,1,101); % baseline estimate, using slow-varying envelope
%     trace_length=length(OSAPower);
%     for index=2:trace_length
%         combPower(index)=max([combPower(index) combPower(index-1)*(1-10/trace_length)]);
%     end
%     for index=trace_length-1:-1:1
%         combPower(index)=max([combPower(index) combPower(index+1)*(1-10/trace_length)]);
%     end
%    combPower = -combPower;
%%
Q0 = 1.886; % M
Qe = 4.085; % M
lambda = 1550.4; % nm
Qt = Q0*Qe/(Q0+Qe);
kappa = (2*pi*c/(lambda*1e-9))/(Qt*1e6); % SI unit

FSR = 17924.02 * 1e6; % SI unit
disp_D2 = -10.2 * 1e3; % SI unit
disp_D3 = -87; % SI unit

%%
filedir = "D:\Measurement\pulse pumping\Simulation_20210112_para_sweep\";
nstep = 10e4;
tauR = 46e-12; % in s, round-trip time % for the ring is 224 GHz.
nt = 512;%2048;        % set the point number to be 2048
dt = tauR/nt;     % set the point number to be 2048
w = 2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied

EOPhase = 1.9/17*1e3*(-21.6e-27).*w.^2/2;

x0 = nt/2;
dx = 0.01*nt;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
gaussian = @(x,x0,dx)exp(-(x-x0)^2/2/dx^2);
pulse_train = @(x)sum(gaussian(x,x0,dx));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:nt);
% pulsePower = pulsePower.*exp(1i*EOPhase');


f1 = LLESolver('D1',0e-3,'D2',-0.0007,'D3',0.000,'pumpPower',2,'detuning',5,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
    'initState','random','solver','SSFT','modeNumber',nt);
f1.solve;
f1.plotAll_pulsed;

