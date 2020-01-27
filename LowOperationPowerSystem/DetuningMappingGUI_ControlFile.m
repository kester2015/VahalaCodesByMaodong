global config;
config.PDPowerCorrectionRatio=122.1698;

p=mfilename('fullpath');
n=find(p=='\',1,'last');
addpath(genpath(p(1:n)));

Qint=260.3e6;
Qcouple=998.8e6;
Pth=11e-6;


EDFACorrectionRatio=0.48e-3*config.PDPowerCorrectionRatio/700e-3; % Ppumpinitial (taper power) / Pinitial (EDFA power)

Qloaded=1/(1/Qint+1/Qcouple);
config.VVFzMap=LowerOperationPowerObj(50,201,2*pi*3e14/1.55/Qloaded,Qloaded);
config.VVFzMap.Pth=Pth*config.PDPowerCorrectionRatio;
config.VVFzMap.EDFACorrectionRatio=EDFACorrectionRatio;

config.Qloaded=Qloaded;
config.VVFzMap.f=3e14/1.55;
config.VVFzMap.yita=Qloaded/Qcouple;
config.VVFzMap.Aeff=40e-12;
config.VVFzMap.L=2*pi*1.5e-3;
config.VVFzMap.D1=21893e6*2*pi;
config.VVFzMap.D2=12.12e3*2*pi;

% config.VVFzMap.LoadSolitonPowerData;
config.VVFzMap.LoadSolitonPowerDataFrommat;

config.EDFAResourceStr='TCPIP0::131.215.238.53::10001::SOCKET';
config.OsciResourceStr=[];
config.ESAResourceStr='GPIB0::11::INSTR';
config.OSAResourceStr='GPIB0::1::INSTR';
config.FGResourceStr='USB0::0x0957::0x2C07::MY52815193::0::INSTR';


DetuningMappingGUI();