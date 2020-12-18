close all
clear
clc
%% test case 0: basic soliton exists stablely
b1 = LLESolver(); % Check default setup, SSFT solver
b1.solve;
b1.plotAll;

b2 = LLESolver('solver','RK'); % Check default setup, Runge Kutta Solver
b2.solve;
b2.plotAll;

b3 = LLESolver('D2',0.02,'D3',0,'NStep',10e4,'timeStep',5e-5,'detuning',30,'pumpPower',100); % Change to D3=0 in default setup
b3.solve;
b3.plotAll;
%% test case 1: D2 only, soliton formation
% clear c b1 b2 b3
% close all
c = LLESolver('D2',0.02,'D3',0,'pumpPower',50,'detuning',[-10 40],'NStep',10e4,'timeStep',2.5e-4,...
    'initState','random','solver','RK');
c.solve;
% c.plotPhiAbsAll;
c.plotAll;

time_unit = 1;
figure
subplot(211)
plot(abs(c.phiResult(:,time_unit)));
subplot(212)
plot(abs(c.phiResult_Freq(:,time_unit)));
%% test case 2: check two solvers
% test case 2.1: 
% close all
% clear d1 d2
% split step Fourier transform solver
d1 = LLESolver('detuning',10,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','SSFT');
d1.solve;
d1.plotAll;
% runge kutta solver
d2 = LLESolver('detuning',10,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','RK');
d2.solve;
d2.plotAll;
%% test case 3: Breather
% larger power, smaller detuning, can give breather.
close all
clear e1
e1 = LLESolver('detuning',5,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','RK','initState','soliton');
e1.solve;
e1.plotAll;
%% test case 4: pulse pumping
close all
clear f1 f2 d1 d2

nstep = 10e4;
% detuning = [linspace(-10,50,nstep/2),linspace(50,50,nstep/2)];
% first generate 
mode_number = 1024;
x0 = mode_number/2;
dx = 0.05*mode_number;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
gaussian = @(x,x0,dx)exp(-(x-x0)^2/2/dx^2);

pulse_train = @(x)sum(gaussian(x,x0,dx));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:mode_number);
figure
plot(pulsePower)
pause(1)

% test begins here.
% anormalous, bright pulse
% f1 = LLESolver('D2',+0.02,'D3',0,'pumpPower',1000,'detuning',[-10 10],'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
%     'initState','random','solver','RK','modeNumber',mode_number);
% f1.solve;
% f1.plotAll;

f3 = LLESolver('D1',2e-3,'D2',+0.02,'D3',0,'pumpPower',200,'detuning',[-10 50],'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
    'initState','random','solver','SSFT','modeNumber',mode_number);
f3.solve;
f3.plotAll;
% % normal disp, dark pulse(broader than bright pulse in time domain.)
% f2 = LLESolver('D2',-0.02,'D3',0,'pumpPower',50,'detuning',[-10 40],'NStep',nstep,'timeStep',5e-4,'pulsePump',pulsePower,...
%     'initState','random','solver','RK','initState','random');
% f2.solve;
% f2.plotAll;

figure
plot(abs(f3.phiResult(:,end)))
hold on
plot(pulsePower/max(pulsePower)*max(abs(f3.phiResult(:,end))))

% set(gca,'yscale','log')

%% pulse pump: double side peak
% nstep = 5e4;
% detuning = [linspace(-10,50,nstep/2),linspace(50,50,nstep/2)];
% first generate 
nstep = 10e4;

mode_number = 1024;
x0 = mode_number/2;
dx = 0.03*mode_number;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
gaussian = @(x,x0,dx)exp(-(x-x0)^2/2/dx^2);

pulse_train = @(x)sum(gaussian(x,x0,dx));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:mode_number);
figure
plot(pulsePower)
pause(1)

close all
f1_1 = LLESolver('D2',+0.02,'D3',0,'pumpPower',200,'detuning',[-10 50],'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
    'initState','random','solver','SSFT','modeNumber',mode_number);
f1_1.solve;
f1_1.plotAll;
f1_1.plotPulseCompare;
%% pulse pumping debug with silica code
D2 = +0.0014;
clear
close all
nstep = 10e4;
tauR=46e-12; % in s, round-trip time % for the ring is 224 GHz.
nt=2048;        % set the point number to be 2048
dt=tauR/nt;     % set the point number to be 2048
w=2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied

PComb=25/15*1e-3; % 3 mW per comb line
NComb=7;   % half number of the comb line
EOComb=zeros(length(w),1);
EOComb(1:NComb+1)=sqrt(PComb);
EOComb(length(w)-NComb+1:length(w))=sqrt(PComb);
EOPhase=1.9/17*1e3*(-21.6e-27).*w.^2/2;
Ein_pulse = fftshift(fft(EOComb.*exp(1i*EOPhase)));
Ein_pulse = ones(size(EOPhase));
f4 = LLESolver('D2',0.02,'D3',0,'pumpPower',20,'detuning',3,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',Ein_pulse,...
    'initState','random','solver','SSFT','modeNumber',nt);
f4.solve;
f4.plotAll;
f4.plotPulseCompare;

% e1 = LLESolver('detuning',5,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','RK');


%% single side peak 
close all
f1_2 = LLESolver('D1',2e-3,'D2',+0.02,'D3',0,'pumpPower',200,'detuning',[-10 50],'NStep',1e5,'timeStep',5e-4/5,'pulsePump',pulsePower,...
    'initState','random','solver','SSFT','modeNumber',mode_number);
f1_2.solve;
f1_2.plotAll;
f1_2.plotPulseCompare;

%% test case 5: with dispersive wave
% close all
% clear
bb=5;%crossing mode number; cite Herr PRL paper.
aa=1; %deviation from the mode dispersion curve. In units of kappa.
cross_disp = @(mu) aa/2./(mu-bb-0.5);
g1 = LLESolver('NStep',60e4,'timeStep',2.5e-4/2,...
    'detuning',[-10 30], 'pumpPower',40, 'D2',0.02,'D3',0,...
    'initState','random','arbiDisp',cross_disp);
g1.solve;
g1.plotAll;


