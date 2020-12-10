

%% test case 1: D2 only
close all
c = LLESolver('D2',0.02,'D3',0,'pumpPower',50,'detuning',[-10 40],'NStep',50e4,'timeStep',2.5e-4/2);
c.solve;
c.plotAll;

%% test case 2: with Raman
d = LLESolver('D3',0.0001);
d.solve;
d.plotAll;
%% 