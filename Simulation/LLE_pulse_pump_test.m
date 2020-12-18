clear
close all
clc

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
% Ein_pulse = ones(size(EOPhase));

x0 = nt/2;
dx = 0.01*nt;
lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
gaussian = @(x,x0,dx)exp(-(x-x0)^2/2/dx^2);
pulse_train = @(x)sum(gaussian(x,x0,dx));
pulsePower = arrayfun(@(x)50*pulse_train(x), 1:nt);
pulsePower = pulsePower.*exp(1i*EOPhase');
% 
% f4 = LLESolver('D1',0e-3,'D2',-0.2,'D3',0,'pumpPower',50,'detuning',[0 50],'NStep',nstep*2,'timeStep',5e-4/2,'pulsePump',Ein_pulse,...
%     'initState','random','solver','SSFT','modeNumber',nt);
% f4.solve;
% f4.plotAll;
% f4.plotPulseCompare;

% f4 = LLESolver('D1',0e-3,'D2',-0.2,'D3',0,'pumpPower',50,'detuning',[0 50],'NStep',nstep*2,'timeStep',5e-4/2,'pulsePump',Ein_pulse,...
%     'initState','random','solver','SSFT','modeNumber',nt);
% f4.solve;
% f4.plotAll;
% f4.plotPulseCompare;

% % 4 side peaks on freq domain
f4 = LLESolver('D1',5e1,'D2',-0.16,'D3',0,'pumpPower',6,'detuning',4,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
    'initState','random','solver','SSFT','modeNumber',nt);
f4.solve;
f4.plotAll;
f4.plotPulseCompare;

% % dual side on freq domain
% f4 = LLESolver('D1',0e-3,'D2',-0.1,'D3',0,'pumpPower',6,'detuning',[0 10],'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
%     'initState','randomPhase','solver','SSFT','modeNumber',nt);
% f4.solve;
% f4.plotAll;
% f4.plotPulseCompare;

% % dual side on time scale peak
% f4 = LLESolver('D1',0e-3,'D2',0.016,'D3',0,'pumpPower',6,'detuning',4,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
%     'initState','random','solver','SSFT','modeNumber',nt);
% f4.solve;
% f4.plotAll;
% f4.plotPulseCompare;