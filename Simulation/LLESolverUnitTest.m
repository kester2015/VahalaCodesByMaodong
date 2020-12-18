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
% close all
% clear e1
e1 = LLESolver('detuning',5,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','RK');
e1.solve;
e1.plotAll;
%% test case 4: pulse pumping
% close all
% clear f1 f2 d1 d2
nstep = 10e4/5;
% first generate 
x0 = 512;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
pulse_train = @(x)sum(lorentian(x,x0,50));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:1024);
figure
plot(pulsePower)

% test begins here.
% anormalous, bright pulse
f1 = LLESolver('D2',+0.02,'D3',0,'pumpPower',10,'detuning',0,'NStep',nstep,'timeStep',5e-4,'pulsePump',pulsePower,...
    'initState','random','solver','RK','initState','random');
f1.solve;
f1.plotAll;
% normal disp, dark pulse(broader than bright pulse in time domain.)
f2 = LLESolver('D2',-0.02,'D3',0,'pumpPower',10,'detuning',0,'NStep',nstep,'timeStep',5e-4,'pulsePump',pulsePower,...
    'initState','random','solver','RK','initState','random');
f2.solve;
f2.plotAll;
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


