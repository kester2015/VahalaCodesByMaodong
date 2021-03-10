%% Open and Init
GPIBAddress = 0;
DeviceAddress = 20;
[ALM, ALMInfo] = ALM8164_Open(GPIBAddress, DeviceAddress);

%%
ALM8164_Init(ALM,ALMInfo);
%% Set Wavelength
ALM8164_SetWavelength(ALM,ALMInfo,1538.653);
%% Sweep
SweepParameters.DetectorRange = 0;
SweepParameters.OutputPower = 6;
SweepParameters.AvTime = 200e-6;
SweepParameters.StartWavelength = 1538.61;
SweepParameters.StopWavelength = 1538.653;
SweepParameters.Step = 0.0001;
SweepParameters.SweepSpeed = 0.5e-9;
[Wavelength,Power] = ALM8164_Sweep(ALM,ALMInfo,SweepParameters);
plot(Wavelength,Power);
xlim([min(Wavelength) max(Wavelength)]);

%% Close
ALM8164_Close(ALM,ALMInfo);
clear ALM ALMInfo