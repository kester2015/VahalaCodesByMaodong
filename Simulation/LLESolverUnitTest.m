close all
clear
clc
%% test case 0: basic soliton
b = LLESolver('D2',0.02,'D3',0,'NStep',10e4,'timeStep',5e-5,'detuning',30,'pumpPower',100);
b.solve;
b.plotAll;
%% test case 1: D2 only
clear c
close all
c = LLESolver('D2',0.02,'D3',0,'pumpPower',50,'detuning',[-10 40],'NStep',50e4,'timeStep',2.5e-4/2,...
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
close all
clear d1 d2
% split step Fourier transform solver
% d1 = LLESolver('detuning',10,'pumpPower',40,'D3',0.0001,'NStep',1e5,'solver','SSFT');
% d1.solve;
% d1.plotAll;
% runge kutta solver
d2 = LLESolver('detuning',5,'pumpPower',40,'D3',0.000,'NStep',1e5,'solver','RK');
d2.solve;
d2.plotAll;
% check at different evolution time
% time_unit = 2;
% figure
% subplot(211)
% plot(abs(d1.phiResult(:,time_unit)));
% subplot(212)
% plot(abs(d1.phiResult_Freq(:,time_unit)));
% title('split step Fourier transform solver')
% % %
% figure
% subplot(211)
% plot(abs(d2.phiResult(:,time_unit)));
% subplot(212)
% plot(abs(d2.phiResult_Freq(:,time_unit)));
% title('runge kutta solver')
%% test case 3: pulse pumping
close all
clear d1 d2
nstep = 10e4/5;

x0 = 512;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
pulse_train = @(x)sum(lorentian(x,x0,50));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:1024);
figure
plot(pulsePower)

% test begins here.
% This gives a reasonable result
f1 = LLESolver('D2',+0.02,'D3',0,'pumpPower',10,'detuning',0,'NStep',nstep,'timeStep',5e-4,'pulsePump',pulsePower,...
    'initState','random','solver','RK','initState','random');
f1.solve;
f1.plotAll;
% this is somewhat abnormal
f2 = LLESolver('D2',-0.02,'D3',0,'pumpPower',10,'detuning',0,'NStep',nstep,'timeStep',5e-4,'pulsePump',pulsePower,...
    'initState','random','solver','RK','initState','random');
f2.solve;
f2.plotAll;
%%


